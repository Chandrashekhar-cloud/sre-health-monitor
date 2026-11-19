#!/bin/bash

# SRE Health Monitor - Main Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=false
CONFIG_FILE="$SCRIPT_DIR/config/thresholds.conf"

usage() {
    echo "Usage: $0 [--dry-run] [--config PATH] [--help]"
    echo "  --dry-run     Simulate alerts without sending Slack messages"
    echo "  --config      Specify a configuration file"
    echo "  --help        Display this help message"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            export DRY_RUN=true
            shift
            ;;
        --config)
            if [[ $# -lt 2 ]]; then
                echo "Error: --config requires a file path" >&2
                exit 1
            fi
            CONFIG_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
done

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: Configuration file not found: $CONFIG_FILE" >&2
    exit 1
fi
# shellcheck disable=SC1090
source "$CONFIG_FILE"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/config.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/alert.sh"

# Logging function
log() {
    echo "[$(TZ=Asia/Kolkata date '+%Y-%m-%d %H:%M:%S IST')] [$1] $2" >> "$LOG_FILE"
}

# Status icon based on value vs threshold
status_icon() {
local val=$1 thresh=$2

if [ "$val" -ge "$thresh" ]; then
echo -e "${RED}[CRITICAL]${RESET}"
elif [ "$val" -ge $((thresh - 15)) ]; then
echo -e "${YELLOW}[WARNING] ${RESET}"
else
echo -e "${GREEN}[OK] ${RESET}"
fi
}

# Print dashboard header
print_header() {
clear
echo -e "${BOLD}${CYAN}"
echo "================================================"
echo " Linux SRE Health Monitor"
echo " Host: $(hostname)"
echo " Time: $(date)"
echo "================================================"
echo -e "${RESET}"
}

# CPU check
check_cpu() {
    local cpu icon
    cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
    icon=$(status_icon "$cpu" "$CPU_THRESHOLD")

    echo -e " CPU Usage : ${BOLD}${cpu}%${RESET} $icon"
    log "INFO" "CPU: ${cpu}%"

    if [ "$cpu" -ge "$CPU_THRESHOLD" ]; then
        send_slack_alert "HIGH CPU ALERT" "CPU is ${cpu}% on $SERVER_NAME"
        log "ALERT" "CPU breach: ${cpu}%"
    fi
}

# RAM check
check_ram() {
    local total used pct icon
    total=$(free -m | awk '/^Mem:/{print $2}')
    used=$(free -m | awk '/^Mem:/{print $3}')
    pct=$(echo "$used $total" | awk '{printf "%d", ($1/$2)*100}')

    icon=$(status_icon "$pct" "$RAM_THRESHOLD")

    echo -e " RAM Usage : ${BOLD}${pct}% (${used}MB/${total}MB)${RESET} $icon"
    log "INFO" "RAM: ${pct}% (${used}MB/${total}MB)"

    if [ "$pct" -ge "$RAM_THRESHOLD" ]; then
        send_slack_alert "HIGH RAM ALERT" "RAM is ${pct}% on $SERVER_NAME"
        log "ALERT" "RAM breach: ${pct}%"
    fi
}

# Disk check
check_disk() {
echo -e " Disk Usage:"

df -P | tail -n +2 | awk '$NF != "/Docker/host"' | while read -r fs blocks used avail pct mnt; do

# Ignore virtual, read-only and special filesystems
case "$fs" in
    tmpfs|udev|devtmpfs|overlay|squashfs) continue ;;
esac

# Ignore mount paths that are not useful for host disk monitoring
case "$mnt" in
    /Docker/host|/snap/*|/usr/lib/wsl/*|/mnt/wsl/*|/mnt/wslg/*|/init|/run/*|/run)
        continue
        ;;
esac

num=$(echo "$pct" | tr -d '%')
icon=$(status_icon "$num" "$DISK_THRESHOLD")

echo -e " $mnt : ${BOLD}$pct${RESET} $icon"
log "INFO" "Disk $mnt: $pct"

if [ "$num" -ge "$DISK_THRESHOLD" ]; then
    send_slack_alert "HIGH DISK ALERT" "Disk $mnt is $pct full on $SERVER_NAME"
    log "ALERT" "Disk breach: $mnt at $pct"
fi

done
}

# Load average check
check_load() {
    local load cores
    load=$(uptime | awk -F"load average:" '{print $2}' | cut -d, -f1 | tr -d " ")
    cores=$(nproc)

    echo -e " Load Average : ${BOLD}${load}${RESET} (${cores} cores)"
    log "INFO" "Load: $load Cores: $cores"
}

# Network stats
check_network() {
    local iface rx tx rx_mb tx_mb

    iface=$(ip route | awk '/default/ {print $5; exit}')
    rx=$(awk -v iface="$iface" '$1 ~ iface":" {print $2}' /proc/net/dev)
    tx=$(awk -v iface="$iface" '$1 ~ iface":" {print $10}' /proc/net/dev)

    rx_mb=$(awk -v rx="$rx" 'BEGIN {printf "%.1f", rx/1024/1024}')
    tx_mb=$(awk -v tx="$tx" 'BEGIN {printf "%.1f", tx/1024/1024}')

    echo -e " Network ($iface) : ${BOLD}RX:${rx_mb}MB TX:${tx_mb}MB${RESET}"
    log "INFO" "Network $iface RX:${rx_mb}MB TX:${tx_mb}MB"
}

# Process count
check_processes() {
    local count
    count=$(ps aux | wc -l)

    echo -e " Processes : ${BOLD}${count} running${RESET}"
    echo -e " Top 5 CPU:"

    ps aux --sort=-%cpu | awk 'NR>1 && NR<=6 {printf " %-25s %s%%\n", $11, $3}'

    log "INFO" "Processes: $count"
}

# MAIN
main() {

mkdir -p "$(dirname "$LOG_FILE")" "$REPORT_DIR"

print_header

echo -e "${BOLD}${BLUE}--- System Metrics ---${RESET}"
check_cpu
check_ram
check_load

echo ""

echo -e "${BOLD}${BLUE}--- Storage ---${RESET}"
check_disk

echo ""

echo -e "${BOLD}${BLUE}--- Network ---${RESET}"
check_network

echo ""

echo -e "${BOLD}${BLUE}--- Processes ---${RESET}"
check_processes

echo ""

echo -e "${DIM}Log: $LOG_FILE | $(date)${RESET}"

log "INFO" "Check complete"
bash "$(dirname "$0")/report.sh"
}

main
