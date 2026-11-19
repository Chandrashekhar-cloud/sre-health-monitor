#!/bin/bash

# SRE Health Monitor - Slack Alert Functions

send_slack_alert() {
    local title="$1"
    local message="$2"
    local ts
    local now
    local cooldown
    local alert_key
    local state_file
    local last_alert

    ts=$(date "+%Y-%m-%d %H:%M:%S")
    now=$(date +%s)
    cooldown=$((${ALERT_COOLDOWN_MINUTES:-30} * 60))

    alert_key=$(printf '%s' "$title" | tr '[:upper:] ' '[:lower:]_')

    # Separate state for dry-run testing
    if [ "${DRY_RUN:-false}" = true ]; then
        state_file="/tmp/health_monitor.dryrun.state"
    else
        state_file="/tmp/health_monitor.state"
    fi

    last_alert=0

    if [ -f "$state_file" ]; then
        last_alert=$(awk -F'|' -v key="$alert_key" '$1 == key {print $2}' "$state_file" | tail -n 1)
        last_alert=${last_alert:-0}
    fi

    if (( now - last_alert < cooldown )); then
        echo "[COOLDOWN] $title suppressed. Try again after cooldown."
        return
    fi

    if [ "${DRY_RUN:-false}" = true ]; then
        echo "[DRY-RUN] Would send alert: $title - $message"
        printf '%s|%s\n' "$alert_key" "$now" >> "$state_file"
        return
    fi

    if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
        echo "[ALERT - Slack not configured] $title: $message"
        return
    fi

    curl -s -X POST "$SLACK_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{ \"attachments\": [{ \"color\": \"danger\", \
        \"title\": \"$title\", \"text\": \"$message\", \
        \"fields\": [{\"title\":\"Host\",\"value\":\"$SERVER_NAME\",\"short\":true},
        {\"title\":\"Time\",\"value\":\"$ts\",\"short\":true}],
        \"footer\":\"Linux SRE Health Monitor\" }] }" > /dev/null

    printf '%s|%s\n' "$alert_key" "$now" >> "$state_file"
    echo -e "${RED}[SLACK ALERT SENT]${RESET} $title"
}

send_slack_summary() {
    local cpu="$1"
    local ram="$2"
    local disk="$3"

    if [ "${DRY_RUN:-false}" = true ]; then
        echo "[DRY-RUN] Would send daily summary: CPU=${cpu}%, RAM=${ram}%, Disk=${disk}%"
        return
    fi

    if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
        echo "[SUMMARY - Slack not configured] CPU=${cpu}%, RAM=${ram}%, Disk=${disk}%"
        return
    fi

    curl -s -X POST "$SLACK_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{ \"attachments\": [{ \"color\": \"good\",
        \"title\": \"Daily Health Summary - $SERVER_NAME\",
        \"fields\": [{\"title\":\"CPU\",\"value\":\"${cpu}%\",\"short\":true},
        {\"title\":\"RAM\",\"value\":\"${ram}%\",\"short\":true},
        {\"title\":\"Disk\",\"value\":\"${disk}%\",\"short\":true}],
        \"footer\":\"$(date +%Y-%m-%d)\" }] }" > /dev/null
}
