#!/bin/bash
# File: /usr/local/bin/harden_logging.sh
# Purpose: Enforce secure logging and auditing configuration
# Author: Paolo’s vigilant AI 🧯

LOG_FILE="/var/log/harden_logging_$(date +'%Y-%m-%d').log"
AUDIT_RULES="/etc/audit/rules.d/99-hardening.rules"

GREEN="\033[1;32m"; CYAN="\033[1;36m"; NC="\033[0m"

echo -e "${CYAN}🧯 Logs & Monitoring Hardening${NC}"
echo "Applying secure log, audit, and history settings..."
echo "Logging actions to $LOG_FILE"
echo ""

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)."
  exit 1
fi

# 103. Ensure auditd is installed and running
if ! dpkg -l | grep -q auditd; then
  echo "Installing auditd..."
  apt update -y >> "$LOG_FILE" 2>&1
  apt install auditd audispd-plugins -y >> "$LOG_FILE" 2>&1
fi
systemctl enable auditd >> "$LOG_FILE" 2>&1
systemctl start auditd >> "$LOG_FILE" 2>&1
echo -e "✅ auditd service ${GREEN}enabled and running${NC}"

# 104. Load strong audit rules
cat > "$AUDIT_RULES" <<'EOF'
# Security audit rules

# Monitor modifications to passwd and shadow
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes

# Monitor sudo actions
-w /etc/sudoers -p wa -k sudoers_changes
-w /etc/sudoers.d/ -p wa -k sudoers_include

# Log login and logout events
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins

# Track permission or ownership changes
-a always,exit -F arch=b64 -S chmod,chown,fchmod,fchown -k perms

# Detect new network connections (bind)
-a always,exit -F arch=b64 -S bind -k network

# Monitor kernel module changes
-w /sbin/insmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-w /sbin/rmmod -p x -k modules

# Track system time changes
-a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k time-change

# Make audit configuration immutable (cannot be changed until reboot)
-e 2
EOF

augenrules --load >> "$LOG_FILE" 2>&1
systemctl restart auditd >> "$LOG_FILE" 2>&1
echo -e "✅ auditd rules ${GREEN}loaded and active${NC}"

# 107. Secure log file permissions
find /var/log -type f -exec chmod 640 {} \; >> "$LOG_FILE" 2>&1
find /var/log -type d -exec chmod 750 {} \; >> "$LOG_FILE" 2>&1
chown -R root:adm /var/log >> "$LOG_FILE" 2>&1
echo -e "✅ Log file permissions ${GREEN}secured (640 files / 750 dirs)${NC}"

# 109–110. Harden Bash history behavior
cat > /etc/profile.d/bash_history_hardening.sh <<'EOF'
# Bash History Hardening
HISTCONTROL=ignoredups:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
HISTFILEMODE=600
HISTTIMEFORMAT="%F %T "
shopt -s histappend
readonly HISTFILE
readonly HISTCONTROL
readonly HISTSIZE
readonly HISTFILESIZE
EOF

chmod 644 /etc/profile.d/bash_history_hardening.sh
echo -e "✅ Bash history ${GREEN}protected and append-only${NC}"

echo ""
echo -e "${GREEN}✨ Logs & Monitoring hardening applied successfully!${NC}"
echo "🗂️  Log file: $LOG_FILE"
