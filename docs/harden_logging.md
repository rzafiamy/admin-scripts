# Logs & Monitoring Hardening (`harden_logging.sh`)

This document describes `scripts/harden_logging.sh`, a script that enforces secure logging and auditing configuration on Debian/Ubuntu systems.

## Purpose

Setup and enable `auditd`, load robust audit rules, secure log file permissions, and harden shell history handling. The script helps ensure critical events are logged and audit rules are enforced.

## Quick facts

- Inputs: none (must be run as root)
- Outputs: audit rules at `/etc/audit/rules.d/99-hardening.rules`, a bash history hardening script at `/etc/profile.d/bash_history_hardening.sh`, and a log at `/var/log/harden_logging_YYYY-MM-DD.log`
- Behavior: installs `auditd` if missing, enables and starts the service, writes rules, secures logs, and protects Bash history settings.

## Prerequisites

- Run as root. The script uses `apt`, `systemctl`, `augenrules`, and manipulates files under `/etc` and `/var/log`.

## Usage

```bash
sudo bash scripts/harden_logging.sh
```

## What it does

- Ensures `auditd` is installed, enabled, and running.
- Writes a set of audit rules to monitor important files and actions (passwd/shadow changes, sudoers modifications, login events, permission changes, module loads, time changes, and network bind calls).
- Loads the audit rules and makes the audit configuration immutable.
- Secures `/var/log` file and directory permissions (files -> 640, dirs -> 750) and sets ownership to `root:adm`.
- Adds a `/etc/profile.d/bash_history_hardening.sh` to harden Bash history behavior (append-only, time format, readonly variables).

## Verification

Check audit service and rules:

```bash
sudo systemctl status auditd
sudo auditctl -l   # list loaded rules
```

Verify log permissions:

```bash
ls -ld /var/log
find /var/log -type f -exec ls -l {} \; | head
```

Verify bash history hardening file exists:

```bash
sudo cat /etc/profile.d/bash_history_hardening.sh
```

## Troubleshooting

- The script expects a system with `apt` and `systemd`. On non-Debian systems, package installation lines will fail.
- If `augenrules --load` fails, check the syntax of `/etc/audit/rules.d/99-hardening.rules` and inspect the log file at `/var/log/harden_logging_YYYY-MM-DD.log`.
- Changing `/var/log` permissions is intrusive — validate that log rotation and other services can still write logs after the change.

## Security considerations

- Audit rules are powerful and can generate large volumes of logs. Tune them to your environment to avoid disk exhaustion.
- The script makes audit configuration immutable (`-e 2`) — this prevents runtime changes until reboot. Be sure rules are correct before enforcing immutability.

## License

See repository `LICENSE`.
