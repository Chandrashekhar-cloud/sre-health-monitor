#!/bin/bash

# SRE Health Monitor - Main Script

source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/alert.sh"

# Logging function
log() {
echo "[$(date "+%Y-%m-%d %H:%M:%S")] [$1] $2" >> "$LOG_FILE"
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
local cpu=$(top -bn1 | grep "Cpu(s)" | awk "{print int(\$2)}")
local icon=$(status_icon $cpu $CPU_THRESHOLD)

echo -e " CPU Usage : ${BOLD}${cpu}%${RESET} $icon"
log "INFO" "CPU: ${cpu}%"

if [ "$cpu" -ge "$CPU_THRESHOLD" ]; then
send_slack_alert "HIGH CPU ALERT" "CPU is ${cpu}% on $SERVER_NAME"
log "ALERT" "CPU breach: ${cpu}%"
fi
}

# RAM check
check_ram() {
local total=$(free -m | awk "/^Mem:/{print \$2}")
local used=$(free -m | awk "/^Mem:/{print \$3}")
local pct=$(echo "$used $total" | awk "{printf \"%d\", (\$1/\$2)*100}")

local icon=$(status_icon $pct $RAM_THRESHOLD)

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

df -h | grep -vE "^Filesystem|tmpfs|udev" | while read fs size used avail pct mnt; do

local num=$(echo $pct | tr -d %)
local icon=$(status_icon $num $DISK_THRESHOLD)

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
local load=$(uptime | awk -F"load average:" "{print \$2}" | cut -d, -f1 | tr -d " ")
local cores=$(nproc)

echo -e " Load Average : ${BOLD}${load}${RESET} (${cores} cores)"
log "INFO" "Load: $load Cores: $cores"
}

# Network stats
check_network() {

local iface=$(ip route | grep default | awk "{print \$5}" | head -1)

local rx=$(cat /proc/net/dev | grep "$iface" | awk "{print \$2}")
local tx=$(cat /proc/net/dev | grep "$iface" | awk "{print \$10}")

local rx_mb=$(echo "$rx" | awk "{printf \"%.1f\", \$1/1024/1024}")
local tx_mb=$(echo "$tx" | awk "{printf \"%.1f\", \$1/1024/1024}")

echo -e " Network ($iface) : ${BOLD}RX:${rx_mb}MB TX:${tx_mb}MB${RESET}"

log "INFO" "Network $iface RX:${rx_mb}MB TX:${tx_mb}MB"
}

# Process count
check_processes() {

local count=$(ps aux | wc -l)

echo -e " Processes : ${BOLD}${count} running${RESET}"

echo -e " Top 5 CPU:"

ps aux --sort=-%cpu | awk "NR>1 && NR<=6 {printf \" %-25s %s%%\n\", \$11, \$3}"

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
}

main
