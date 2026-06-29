# 🚀 Linux SRE Health Monitor

![Linux](https://img.shields.io/badge/Linux-Ubuntu-E95420?style=for-the-badge\&logo=ubuntu)
![Bash](https://img.shields.io/badge/Bash-Scripting-121011?style=for-the-badge\&logo=gnubash)
![GitHub](https://img.shields.io/badge/GitHub-Repository-181717?style=for-the-badge\&logo=github)
![Status](https://img.shields.io/badge/Project-Completed-success?style=for-the-badge)
![SRE](https://img.shields.io/badge/SRE-Monitoring-blue?style=for-the-badge)

A production-style Linux monitoring solution built with **Bash**, **Cron**, **Linux utilities**, **Slack Webhooks**, and **HTML reporting**.

The project continuously monitors system health, generates daily reports, logs metrics, and sends alerts when configured thresholds are breached.

---

# 📌 Features

✅ CPU Monitoring

✅ RAM Monitoring

✅ Disk Usage Monitoring

✅ Load Average Monitoring

✅ Network Statistics

✅ Process Monitoring

✅ Real-Time Slack Alert Notifications

✅ HTML Dashboard Reports

✅ Automated Logging

✅ Cron-based Scheduling

---

# 🏗️ Architecture

```text
+-------------------+
|     Cron Jobs     |
+---------+---------+
          |
          v
+-------------------+
|   monitor.sh      |
+---------+---------+
          |
          +-------------------+
          |                   |
          v                   v
+----------------+   +----------------+
| health.log     |   | Slack Alerts   |
+----------------+   +----------------+
          |
          v
+-------------------+
|   report.sh       |
+---------+---------+
          |
          v
+-------------------+
| HTML Dashboard    |
+-------------------+
```

---

# 📂 Project Structure

```text
sre-health-monitor/
│
├── config.sh
├── monitor.sh
├── alert.sh
├── report.sh
├── install.sh
│
├── logs/
│   └── health.log
│
├── reports/
│   └── report_YYYY-MM-DD.html
│
├── screenshots/
│   ├── monitor-output.png
│   ├── html-report.png
│   ├── slack-alert.png
│   └── github-repo.png
│
└── README.md
```

---

# 📸 Screenshots

## Terminal Monitoring Dashboard

Live terminal dashboard displaying CPU, RAM, Disk Usage, Load Average, Network Statistics, and Running Processes.

![Monitor Output](screenshots/monitor-output.png)

---

## HTML Health Report

Automatically generated HTML dashboard providing a visual overview of system health metrics and recent logs.

![HTML Report](screenshots/html-report.png)

---

## Slack Alert Notifications

Real-time alerts generated through Slack Webhooks whenever configured CPU, RAM, or Disk thresholds are exceeded.

![Slack Alert](screenshots/slack-alert.png)

---

## GitHub Repository

Source code repository containing monitoring scripts, configuration files, report generation modules, alert integrations, and project documentation.

![GitHub Repository](screenshots/github-repo.png)

---

# ⚙️ Technologies Used

| Technology     | Purpose                |
| -------------- | ---------------------- |
| Bash           | Automation             |
| Linux          | Monitoring Environment |
| Cron           | Scheduling             |
| Slack Webhooks | Alerting               |
| HTML/CSS       | Reporting              |
| Git & GitHub   | Version Control        |

---

# 🚦 Monitored Metrics

| Metric        | Threshold      |
| ------------- | -------------- |
| CPU Usage     | 80%            |
| RAM Usage     | 85%            |
| Disk Usage    | 90%            |
| Load Average  | CPU Core Count |
| Network RX/TX | Logged         |
| Process Count | Logged         |

---

# 🖥️ Running the Project

```bash
git clone https://github.com/Chandrashekhar-cloud/sre-health-monitor.git

cd sre-health-monitor

chmod +x *.sh

./monitor.sh

./report.sh
```

---

# 📊 Sample Output

```text
================================================
 Linux SRE Health Monitor
 Host: codespaces-f4661b
================================================

--- System Metrics ---
CPU Usage : 42% [OK]
RAM Usage : 22% (1775MB/7944MB) [OK]
Load Average : 1.21 (2 cores)

--- Storage ---
/ : 33% [OK]

--- Network ---
Network (eth0) : RX:6816.0MB TX:66.1MB

--- Processes ---
Processes : 22 running
```
# 🎯 Resume Highlights

- Built an automated Linux health monitoring solution using Bash scripting.
- Implemented real-time monitoring for CPU, RAM, Disk Usage, Load Average, Network Statistics, and Running Processes.
- Developed HTML dashboards for system health visualization and reporting.
- Integrated Slack Webhook notifications for real-time CPU, RAM, and Disk threshold alerts.
- Designed structured logging and automated report generation workflows.
- Implemented configurable monitoring thresholds for production-style alerting.
- Developed and tested the solution in a Linux environment using GitHub Codespaces.

---
# 🚀 Future Enhancements

- Docker Container Monitoring
- Kubernetes Health Monitoring
- Prometheus Metrics Export
- Grafana Dashboard Integration
- Microsoft Teams Alert Integration
- Telegram Alert Integration
- Multi-Server Monitoring
- Historical Trend Analysis

---

# 👨‍💻 Author

**Chandrashekhar H S**

GitHub: https://github.com/Chandrashekhar-cloud

---

⭐ If you found this project useful, consider giving it a star
