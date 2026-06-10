#!/bin/bash

# SRE Health Monitor - HTML Report Generator

source "$(dirname "$0")/config.sh"

generate_report() {

local ts=$(date "+%Y-%m-%d %H:%M:%S")
local date=$(date +%Y-%m-%d)
local report="$REPORT_DIR/report_${date}.html"

local cpu=$(top -bn1 | grep "Cpu(s)" | awk "{print int(\$2)}")

local ram_t=$(free -m | awk "/^Mem:/{print \$2}")
local ram_u=$(free -m | awk "/^Mem:/{print \$3}")
local ram_p=$(echo "$ram_u $ram_t" | awk "{printf \"%d\", (\$1/\$2)*100}")

local disk=$(df / | awk "NR==2{print \$5}" | tr -d "%")

local load=$(uptime | awk -F"load average:" "{print \$2}" | cut -d, -f1 | tr -d " ")

local procs=$(ps aux | wc -l)

cpu_col=$([ "$cpu" -ge 80 ] && echo "#f78166" || ([ "$cpu" -ge 60 ] && echo "#e3b341" || echo "#3fb950"))
ram_col=$([ "$ram_p" -ge 85 ] && echo "#f78166" || ([ "$ram_p" -ge 70 ] && echo "#e3b341" || echo "#3fb950"))
disk_col=$([ "$disk" -ge 90 ] && echo "#f78166" || ([ "$disk" -ge 75 ] && echo "#e3b341" || echo "#3fb950"))

mkdir -p "$REPORT_DIR"

cat > "$report" << HTMLEOF
<!DOCTYPE html><html><head><title>SRE Health Report</title>
<style>
body{background:#0d1117;color:#c9d1d9;font-family:monospace;padding:24px;margin:0}
h1{color:#58a6ff;border-bottom:1px solid #30363d;padding-bottom:12px}
.grid{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin:20px 0}
.card{background:#161b22;border:1px solid #30363d;border-radius:8px;padding:20px;text-align:center}
.val{font-size:48px;font-weight:bold;margin:10px 0}
.lbl{color:#8b949e;font-size:13px}
.log{background:#161b22;padding:16px;border-radius:8px;overflow:auto;max-height:280px;font-size:12px}
footer{color:#8b949e;font-size:11px;margin-top:20px}
</style></head><body>

<h1>Linux SRE Health Report</h1>

<p>Host: <strong>$SERVER_NAME</strong> | Generated: <strong>$ts</strong></p>

<div class="grid">
<div class="card"><div class="lbl">CPU Usage</div>
<div class="val" style="color:$cpu_col">${cpu}%</div>
<div class="lbl">Threshold: 80%</div></div>

<div class="card"><div class="lbl">RAM Usage</div>
<div class="val" style="color:$ram_col">${ram_p}%</div>
<div class="lbl">${ram_u}MB / ${ram_t}MB</div></div>

<div class="card"><div class="lbl">Disk Usage</div>
<div class="val" style="color:$disk_col">${disk}%</div>
<div class="lbl">Threshold: 90%</div></div>
</div>

<div class="grid">
<div class="card"><div class="lbl">Load Average</div>
<div class="val" style="color:#58a6ff">$load</div></div>

<div class="card"><div class="lbl">Processes</div>
<div class="val" style="color:#d2a8ff">$procs</div></div>

<div class="card"><div class="lbl">Status</div>
<div class="val" style="color:#3fb950">OK</div>
<div class="lbl">Monitor Active</div></div>
</div>

<h2 style="color:#3fb950">Recent Logs</h2>

<div class="log"><pre>$(tail -30 "$LOG_FILE" 2>/dev/null || echo "No logs yet")</pre></div>

<footer>Linux SRE Health Monitor | github.com/Chandrashekhar-cloud/sre-health-monitor</footer>

</body></html>
HTMLEOF

echo "Report generated: $report"
}

generate_report
