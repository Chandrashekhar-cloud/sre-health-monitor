#!/bin/bash

# SRE Health Monitor - Installer

# Usage: bash install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=================================="
echo " SRE Health Monitor - Installer"
echo "=================================="

# Check dependencies
echo "[1/4] Checking dependencies..."

for cmd in curl awk df free top ps nproc ip; do
command -v $cmd &>/dev/null || { echo "Missing: $cmd"; exit 1; }
done

echo " OK"

# Set permissions
echo "[2/4] Setting permissions..."

chmod +x "$SCRIPT_DIR"/*.sh

echo " OK"

# Create directories
echo "[3/4] Creating directories..."

mkdir -p "$SCRIPT_DIR/logs" "$SCRIPT_DIR/reports"

echo " OK"

# Setup cron
echo "[4/4] Adding cron jobs..."

MON_CRON="*/5 * * * * $SCRIPT_DIR/monitor.sh >> $SCRIPT_DIR/logs/cron.log 2>&1"
REP_CRON="0 8 * * * $SCRIPT_DIR/report.sh >> $SCRIPT_DIR/logs/cron.log 2>&1"

(crontab -l 2>/dev/null | grep -v "sre-health-monitor"; echo "$MON_CRON"; echo "$REP_CRON") | crontab -

echo " OK"

echo ""
echo "=================================="
echo " Installation Complete!"
echo " 1. Edit config.sh - add Slack webhook"
echo " 2. Run: ./monitor.sh"
echo " 3. Logs: tail -f logs/health.log"
echo "=================================="
