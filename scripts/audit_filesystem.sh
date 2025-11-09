#!/bin/bash
# File: /usr/local/bin/audit_filesystem.sh
# Purpose: Audit and report file-system security issues (checks 88–95)

LOG_FILE="/var/log/audit_filesystem_$(date +'%Y-%m-%d').log"
GREEN="\033[1;32m"; RED="\033[1;31m"; YELLOW="\033[1;33m"; CYAN="\033[1;36m"; NC="\033[0m"
PASSED="✅"; FAILED="❌"; WARN="⚠️"

echo -e "${CYAN}🧱 File-System Security Audit${NC}"
echo "Scanning for insecure permissions, SUID/SGID, and core-dump risks..."
echo "Detailed results saved to: $LOG_FILE"
echo ""

> "$LOG_FILE"

report() {
  local id="$1"; local desc="$2"; local status="$3"
  local color="$4"
  printf "${color}%-5s %-70s%s${NC}\n" "$id." "$desc" "$status"
}

# 88. No world-writable files
WWF=$(find / -xdev -type f -perm -0002 2>/dev/null)
if [ -z "$WWF" ]; then
  report 88 "No world-writable files" "$PASSED" "$GREEN"
else
  echo "$WWF" > "$LOG_FILE"
  report 88 "No world-writable files" "$FAILED" "$RED"
fi

# 89. No world-writable directories
WWD=$(find / -xdev -type d -perm -0002 ! -path "/tmp" 2>/dev/null)
if [ -z "$WWD" ]; then
  report 89 "No world-writable directories" "$PASSED" "$GREEN"
else
  echo -e "\n[World-writable directories]" >> "$LOG_FILE"
  echo "$WWD" >> "$LOG_FILE"
  report 89 "No world-writable directories" "$FAILED" "$RED"
fi

# 90. No unowned files
UNOWNED=$(find / -xdev \( -nouser -o -nogroup \) 2>/dev/null)
if [ -z "$UNOWNED" ]; then
  report 90 "No unowned files" "$PASSED" "$GREEN"
else
  echo -e "\n[Unowned files]" >> "$LOG_FILE"
  echo "$UNOWNED" >> "$LOG_FILE"
  report 90 "No unowned files" "$FAILED" "$RED"
fi

# 91. No SUID binaries
SUIDS=$(find / -xdev -perm -4000 2>/dev/null)
if [ -z "$SUIDS" ]; then
  report 91 "No SUID binaries" "$PASSED" "$GREEN"
else
  echo -e "\n[SUID binaries]" >> "$LOG_FILE"
  echo "$SUIDS" >> "$LOG_FILE"
  report 91 "No SUID binaries" "$WARN" "$YELLOW"
fi

# 92. No SGID binaries
SGIDS=$(find / -xdev -perm -2000 2>/dev/null)
if [ -z "$SGIDS" ]; then
  report 92 "No SGID binaries" "$PASSED" "$GREEN"
else
  echo -e "\n[SGID binaries]" >> "$LOG_FILE"
  echo "$SGIDS" >> "$LOG_FILE"
  report 92 "No SGID binaries" "$WARN" "$YELLOW"
fi

# 93–95. Core-dump restrictions
SYSCTL_CORE=$(sysctl kernel.core_pattern 2>/dev/null | awk '{print $3}')
LIMITS_DUMP=$(grep -E "core" /etc/security/limits.conf /etc/security/limits.d/* 2>/dev/null)
SYSTEMD_CORE=$(systemctl show systemd-coredump | grep -E 'Storage=' | awk -F= '{print $2}')

PASS_CORE=1
if [[ "$SYSCTL_CORE" == "core" || "$SYSCTL_CORE" == "core.%p" ]]; then PASS_CORE=0; fi
if echo "$LIMITS_DUMP" | grep -q -E 'hard core 0'; then ((PASS_CORE+=1)); fi
if echo "$SYSTEMD_CORE" | grep -q 'none'; then ((PASS_CORE+=1)); fi

if [ "$PASS_CORE" -ge 2 ]; then
  report 93 "Core dumps restricted" "$PASSED" "$GREEN"
  report 94 "Core dumps disabled (systemd)" "$PASSED" "$GREEN"
  report 95 "Core dump SUID disabled" "$PASSED" "$GREEN"
else
  report 93 "Core dumps restricted" "$FAILED" "$RED"
  report 94 "Core dumps disabled (systemd)" "$FAILED" "$RED"
  report 95 "Core dump SUID disabled" "$FAILED" "$RED"
fi

echo ""
echo -e "${CYAN}🗂️  Detailed results saved to:${NC} $LOG_FILE"
echo -e "${GREEN}✨ File-system audit complete.${NC}"
