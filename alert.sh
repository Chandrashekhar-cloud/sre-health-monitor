#!/bin/bash

# SRE Health Monitor - Slack Alert Functions

send_slack_alert() {
local title=$1
local message=$2
local ts=$(date "+%Y-%m-%d %H:%M:%S")

# Skip if not configured
if [[ "$SLACK_WEBHOOK" == *"YOUR/WEBHOOK"* ]]; then
echo -e " [ALERT - Slack not configured] $title: $message"
return
fi

curl -s -X POST "$SLACK_WEBHOOK" \
-H "Content-Type: application/json" \
-d "{ \"attachments\": [{ \"color\": \"danger\", \
\"title\": \"$title\", \"text\": \"$message\", \
\"fields\": [{\"title\":\"Host\",\"value\":\"$SERVER_NAME\",\"short\":true},
{\"title\":\"Time\",\"value\":\"$ts\",\"short\":true}],
\"footer\":\"Linux SRE Health Monitor\" }] }" > /dev/null

echo -e " ${RED}[SLACK ALERT SENT]${RESET} $title"
}

send_slack_summary() {
local cpu=$1
local ram=$2
local disk=$3

curl -s -X POST "$SLACK_WEBHOOK" \
-H "Content-Type: application/json" \
-d "{ \"attachments\": [{ \"color\": \"good\",
\"title\": \"Daily Health Summary - $SERVER_NAME\",
\"fields\": [{\"title\":\"CPU\",\"value\":\"${cpu}%\",\"short\":true},
{\"title\":\"RAM\",\"value\":\"${ram}%\",\"short\":true},
{\"title\":\"Disk\",\"value\":\"${disk}%\",\"short\":true}],
\"footer\":\"$(date +%Y-%m-%d)\" }] }" > /dev/null
}
