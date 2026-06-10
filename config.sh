#!/bin/bash

# SRE Health Monitor - Configuration

# Alert thresholds
CPU_THRESHOLD=80
RAM_THRESHOLD=85
DISK_THRESHOLD=90

# Slack webhook URL - paste yours here
SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# Log and report paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/logs/health.log"
REPORT_DIR="$SCRIPT_DIR/reports"

# Server name for alerts
SERVER_NAME=$(hostname)

# Terminal colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"
