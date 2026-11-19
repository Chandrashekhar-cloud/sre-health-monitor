# 🚀 Linux SRE Health Monitor

![Linux](https://img.shields.io/badge/Linux-Ubuntu-E95420?style=for-the-badge&logo=ubuntu)
![Bash](https://img.shields.io/badge/Bash-Scripting-121011?style=for-the-badge&logo=gnubash)
![ShellCheck](https://img.shields.io/badge/ShellCheck-Verified-success?style=for-the-badge)
![SRE](https://img.shields.io/badge/SRE-Monitoring-blue?style=for-the-badge)

A modular Linux system health monitoring solution built using **Bash scripting and Linux utilities** to monitor system resources, detect threshold breaches, generate alerts, and produce automated HTML health reports.

The project provides configurable monitoring thresholds, command-line options, dry-run alert simulation, and per-alert cooldown functionality to reduce repetitive notifications.

---

## 📌 Problem Statement

System administrators and Site Reliability Engineers need to continuously monitor system resources to identify performance issues before they affect application availability.

Manually checking CPU utilization, memory consumption, disk usage, network statistics, and running processes can be time-consuming.

This project automates Linux system health monitoring through Bash scripts, providing resource visibility, threshold-based alerts, monitoring logs, and HTML reports.

---

## 🎯 Project Objectives

- Automate Linux system health monitoring.
- Identify CPU, memory, and disk utilization issues.
- Monitor system load, network statistics, and running processes.
- Generate alerts when configured thresholds are exceeded.
- Reduce repetitive notifications using alert cooldown.
- Support safe testing through dry-run execution.
- Generate HTML reports for system health analysis.

---

## ✨ Key Features

### System Monitoring
- CPU utilization monitoring.
- RAM utilization monitoring.
- Disk usage monitoring.
- System load average monitoring.
- Network traffic statistics (RX/TX).
- Running process monitoring.

### Alert Management
- Configurable monitoring thresholds.
- Slack webhook alert integration.
- Dry-run mode for testing alerts without sending messages.
- Per-alert cooldown mechanism.
- Separate cooldown tracking for individual alert types.

### Reporting and Logging
- Automated HTML health report generation.
- Timestamped monitoring logs.
- System resource status reporting.
- Historical monitoring information through log files.

### Engineering Features
- Modular Bash script architecture.
- Command-line argument support.
- Custom configuration file support.
- ShellCheck static analysis.
- Linux command-line utilities.

---

## 🏗️ System Architecture

```text
                  Linux System
                       |
                       v
                  monitor.sh
                       |
          +------------+------------+
          |            |            |
          v            v            v
         CPU          RAM          Disk
      Monitoring   Monitoring   Monitoring
          |            |            |
          +------------+------------+
                       |
             +---------+---------+
             |         |         |
             v         v         v
           Load     Network   Processes
        Monitoring  Statistics Monitoring
             |         |         |
             +---------+---------+
                       |
                       v
                    alert.sh
                       |
              +--------+--------+
              |                 |
              v                 v
          Dry-Run          Slack Webhook
              |                 |
              +--------+--------+
                       |
                       v
                 Alert Cooldown
                       |
                       v
                   report.sh
                       |
                       v
                 HTML Health Report
                       |
                       v
                  health.log
