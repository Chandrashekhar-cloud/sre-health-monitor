# 🚀 Linux SRE Health Monitor

![Linux](https://img.shields.io/badge/Linux-Ubuntu-E95420?style=for-the-badge&logo=ubuntu)
![Bash](https://img.shields.io/badge/Bash-Scripting-121011?style=for-the-badge&logo=gnubash)
![ShellCheck](https://img.shields.io/badge/ShellCheck-Verified-success?style=for-the-badge)
![SRE](https://img.shields.io/badge/SRE-Monitoring-blue?style=for-the-badge)

A modular Linux system health monitoring solution built using **Bash scripting, Linux utilities, Cron, Slack Webhooks, and HTML reporting**.

The project monitors essential system resources, detects threshold breaches, generates HTML health reports, and maintains structured monitoring logs.

It includes configurable monitoring thresholds, command-line options, dry-run alert simulation, and per-alert cooldown to reduce repetitive notifications.

---

## 📌 Key Features

- CPU utilization monitoring
- RAM utilization monitoring
- Disk usage monitoring
- System load average monitoring
- Network traffic statistics (RX/TX)
- Running process monitoring
- Configurable monitoring thresholds
- Slack webhook alert integration
- Dry-run mode for safe alert testing
- Per-alert cooldown mechanism
- Automated HTML health report generation
- Timestamped monitoring logs
- Command-line configuration support
- ShellCheck-verified shell scripts

---

## 🏗️ Architecture

```text
              Linux System
                   |
                   v
             monitor.sh
                   |
       +-----------+-----------+
       |           |           |
       v           v           v
      CPU         RAM         Disk
   Monitoring  Monitoring  Monitoring
       |           |           |
       +-----------+-----------+
                   |
          Network & Processes
                   |
                   v
              alert.sh
                   |
          +--------+--------+
          |                 |
          v                 v
      Dry-Run          Slack Alerts
          |
          v
      Cooldown
                   |
                   v
              report.sh
                   |
                   v
             HTML Report
                   |
                   v
              health.log
