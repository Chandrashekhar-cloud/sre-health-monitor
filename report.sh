#!/bin/bash

# SRE Health Monitor - HTML Report Generator
# shellcheck disable=SC1091
source "$(dirname "$0")/config.sh"

generate_report() {

local ts cpu ram_t ram_u ram_p disk load procs report

ts=$(TZ=Asia/Kolkata date "+%Y-%m-%d %H:%M:%S IST")
cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
ram_t=$(free -m | awk '/^Mem:/{print $2}')
ram_u=$(free -m | awk '/^Mem:/{print $3}')
ram_p=$(echo "$ram_u $ram_t" | awk '{printf "%d", ($1/$2)*100}')
disk=$(df / | awk 'NR==2{print $5}' | tr -d "%")
load=$(uptime | awk -F"load average:" '{print $2}' | cut -d, -f1 | tr -d " ")
procs=$(ps aux | wc -l)

if [ "$cpu" -ge 80 ]; then
    cpu_col="#f78166"
elif [ "$cpu" -ge 60 ]; then
    cpu_col="#e3b341"
else
    cpu_col="#3fb950"
fi

if [ "$ram_p" -ge 85 ]; then
    ram_col="#f78166"
elif [ "$ram_p" -ge 70 ]; then
    ram_col="#e3b341"
else
    ram_col="#3fb950"
fi

if [ "$disk" -ge 90 ]; then
    disk_col="#f78166"
elif [ "$disk" -ge 75 ]; then
    disk_col="#e3b341"
else
    disk_col="#3fb950"
fi

mkdir -p "$REPORT_DIR"
report="$REPORT_DIR/report_$(date +%Y-%m-%d).html"
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
explorer.exe "$(wslpath -w "$report")"
}

generate_report
