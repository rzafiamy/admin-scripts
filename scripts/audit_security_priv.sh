#!/bin/bash
# File: /usr/local/bin/audit_security.sh
# Purpose: Audit Ubuntu system for top 100+ security and privacy checks
# Author: Paolo’s curious AI auditor 🧠
# Note: Run with sudo for full checks

# --- COLOR SETUP ---
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
NC="\033[0m" # No color

PASSED="✅"
FAILED="❌"
WARN="⚠️"
INFO="ℹ️"

echo -e "${CYAN}🔐 Ubuntu Security & Privacy Audit (v100+)${NC}"
echo "-----------------------------------------------"
echo "Performing comprehensive security audit..."
echo ""

LOG_FILE="/var/log/audit_security_$(date +'%Y-%m-%d').log"
rm -f "$LOG_FILE" &>/dev/null
touch "$LOG_FILE"
echo "Security Audit Log - $(date)" > "$LOG_FILE"
echo "---------------------------------" >> "$LOG_FILE"

CHECK_NUM=0

check() {
  local description="$1"
  local command="$2"
  local invert="$3"
  local result
  
  ((CHECK_NUM++))
  
  eval "$command" &>/dev/null
  local exit_code=$?
  
  if [ $exit_code -eq 0 ]; then
    if [ "$invert" == "true" ]; then
      printf "${RED}%-4s %-75s ${FAILED}${NC}\n" "$CHECK_NUM." "$description"
      echo "$CHECK_NUM. $description : FAIL" >> "$LOG_FILE"
    else
      printf "${GREEN}%-4s %-75s ${PASSED}${NC}\n" "$CHECK_NUM." "$description"
      echo "$CHECK_NUM. $description : PASS" >> "$LOG_FILE"
    fi
  else
    if [ "$invert" == "true" ]; then
      printf "${GREEN}%-4s %-75s ${PASSED}${NC}\n" "$CHECK_NUM." "$description"
      echo "$CHECK_NUM. $description : PASS" >> "$LOG_FILE"
    else
      printf "${RED}%-4s %-75s ${FAILED}${NC}\n" "$CHECK_NUM." "$description"
      echo "$CHECK_NUM. $description : FAIL" >> "$LOG_FILE"
    fi
  fi
}

# --- AUDIT CHECKS ---

echo -e "${BLUE}🧱 System Integrity & Updates${NC}"
check "System is 64-bit" "[[ $(uname -m) == 'x86_64' ]]"
check "Kernel is hardened (CONFIG_HARDENED_USERCOPY=y)" "grep -q 'CONFIG_HARDENED_USERCOPY=y' /boot/config-$(uname -r)"
check "Secure Boot enabled" "[ -d /sys/firmware/efi ] && LC_ALL=C mokutil --sb-state | grep -qi enabled"
check "No outdated packages" "LC_ALL=C apt list --upgradable 2>/dev/null | grep -v 'Listing... Done' | wc -l | grep -q '^0$'"
check "Automatic updates enabled" "grep -q 'APT::Periodic::Unattended-Upgrade \"1\";' /etc/apt/apt.conf.d/20auto-upgrades"
check "Security updates repo present" "grep -q 'security.ubuntu.com' /etc/apt/sources.list"
check "No unsupported repositories (PPAs)" "! grep -q 'ppa.launchpad.net' /etc/apt/sources.list /etc/apt/sources.list.d/*"
check "Package integrity checked (debsums)" "command -v debsums && debsums_out=$(debsums -c 2>&1); [ -z \"$debsums_out\" ]"
check "No prelink installed" "! dpkg -l | grep -q prelink"
check "AppArmor enabled" "LC_ALL=C aa-status | grep -q 'profiles are in enforce mode'"
check "SELinux not installed (AppArmor is default)" "! dpkg -l | grep -q selinux"

echo -e "\n${BLUE}👤 User & Authentication${NC}"
check "No UID 0 users except root" "[[ $(awk -F: '($3 == 0) {print $1}' /etc/passwd | wc -l) -eq 1 ]]"
check "No users with empty passwords" "! awk -F: '($2 == \"\") {print $1}' /etc/shadow | grep ."
check "Root account password locked" "LC_ALL=C passwd -S root | grep -q ' L '"
check "User home directories permissions (750)" "! find /home -mindepth 1 -maxdepth 1 -type d ! -perm 750 | grep ."
check "User .ssh directories permissions (700)" "! find /home/*/.ssh -type d ! -perm 700 2>/dev/null | grep ."
check "User authorized_keys files permissions (600)" "! find /home/*/.ssh/authorized_keys -type f ! -perm 600 2>/dev/null | grep ."
check "User .netrc files permissions (600)" "! find /home/*/.netrc -type f ! -perm 600 2>/dev/null | grep ."
check "No .rhosts files" "! find / -name .rhosts 2>/dev/null | grep ."
check "Default umask is 027 or stricter" "grep -E 'UMASK\s+027' /etc/login.defs"
check "Sudo timeout <= 15 minutes" "grep -qE 'timestamp_timeout\s*=\s*(1[0-5]|[0-9])' /etc/sudoers /etc/sudoers.d/*"
check "Sudo requires 'tty_tickets'" "grep -q 'Defaults.*tty_tickets' /etc/sudoers /etc/sudoers.d/*"
check "Sudo logs all actions" "grep -q 'Defaults.*logfile=' /etc/sudoers /etc/sudoers.d/*"
check "No 'NOPASSWD' in sudoers" "! grep -r 'NOPASSWD' /etc/sudoers /etc/sudoers.d/*"

echo -e "\n${BLUE}🔑 Password Policy (PAM)${NC}"
check "Strong password policy (minlen>=12)" "grep -E 'minlen\s*=\s*(1[2-9]|[2-9][0-9])' /etc/security/pwquality.conf"
check "Password policy: dcredit (digit)" "grep -E 'dcredit\s*=\s*-1' /etc/security/pwquality.conf"
check "Password policy: ucredit (uppercase)" "grep -E 'ucredit\s*=\s*-1' /etc/security/pwquality.conf"
check "Password policy: lcredit (lowercase)" "grep -E 'lcredit\s*=\s*-1' /etc/security/pwquality.conf"
check "Password policy: ocredit (special)" "grep -E 'ocredit\s*=\s*-1' /E /etc/security/pwquality.conf"
check "Password history (remember=5)" "grep -q 'password.*pam_pwhistory.so.*remember=5' /etc/pam.d/common-password"
check "Password complexity (pam_pwquality) enabled" "grep -q 'password.*requisite.*pam_pwquality.so' /etc/pam.d/common-password"
check "Lockout on 5 failed attempts (pam_tally2)" "grep -q 'auth.*required.*pam_tally2.so.*deny=5' /etc/pam.d/common-auth"
check "Password hashing algorithm is SHA512" "grep -q 'SHA512' /etc/pam.d/common-password"
check "Password min days (PASS_MIN_DAYS=1)" "grep -q '^PASS_MIN_DAYS\s*1' /etc/login.defs"
check "Password max days (PASS_MAX_DAYS=90)" "grep -q '^PASS_MAX_DAYS\s*90' /etc/login.defs"
check "Password warn age (PASS_WARN_AGE=7)" "grep -q '^PASS_WARN_AGE\s*7' /etc/login.defs"

echo -e "\n${BLUE}🔒 SSH Server Hardening (sshd_config)${NC}"
check "SSH: Root login disabled" "grep -qE '^[[:space:]]*PermitRootLogin\s+no' /etc/ssh/sshd_config"
check "SSH: Password authentication disabled" "grep -qE '^[[:space:]]*PasswordAuthentication\s+no' /etc/ssh/sshd_config"
check "SSH: Empty passwords disabled" "grep -qE '^[[:space:]]*PermitEmptyPasswords\s+no' /etc/ssh/sshd_config"
check "SSH: Protocol 2 only" "grep -qE '^[[:space:]]*Protocol\s+2' /etc/ssh/sshd_config"
check "SSH: X11 forwarding disabled" "grep -qE '^[[:space:]]*X11Forwarding\s+no' /etc/ssh/sshd_config"
check "SSH: Max auth tries limited (<=4)" "grep -qE '^[[:space:]]*MaxAuthTries\s+[1-4]' /etc/ssh/sshd_config"
check "SSH: Login grace time limited (<=60)" "grep -qE '^[[:space:]]*LoginGraceTime\s+([1-5][0-9]|60)$' /etc/ssh/sshd_config"
check "SSH: Client alive interval set" "grep -qE '^[[:space:]]*ClientAliveInterval\s+[0-9]+' /etc/ssh/sshd_config"
check "SSH: Client alive count set (<=3)" "grep -qE '^[[:space:]]*ClientAliveCountMax\s+[0-3]' /etc/ssh/sshd_config"
check "SSH: Runs in non-privileged mode" "grep -qE '^[[:space:]]*UsePrivilegeSeparation\s+sandbox' /etc/ssh/sshd_config"
check "SSH: Warning banner enabled" "grep -qE '^[[:space:]]*Banner\s+.+' /etc/ssh/sshd_config"
check "SSH: Only strong Ciphers used" "grep -qE '^[[:space:]]*Ciphers\s+aes' /etc/ssh/sshd_config"
check "SSH: Only strong MACs used" "grep -qE '^[[:space:]]*MACs\s+hmac-sha2' /etc/ssh/sshd_config"
check "SSH: Only strong KexAlgorithms used" "grep -qE '^[[:space:]]*KexAlgorithms\s+diffie-hellman' /etc/ssh/sshd_config"
check "SSH: Port is not default (22)" "grep -qE '^[[:space:]]*Port\s+(?!22).*' /etc/ssh/sshd_config"
check "SSH: Access limited to specific users/groups" "grep -qE '^[[:space:]]*(AllowUsers|AllowGroups)' /etc/ssh/sshd_config"
check "SSH: HostbasedAuthentication disabled" "grep -qE '^[[:space:]]*HostbasedAuthentication\s+no' /etc/ssh/sshd_config"
check "SSH: PAM enabled" "grep -qE '^[[:space:]]*UsePAM\s+yes' /etc/ssh/sshd_config"

echo -e "\n${BLUE}🌐 Network & Firewall${NC}"
check "UFW (Uncomplicated Firewall) active" "LC_ALL=C ufw status | grep -q 'Status: active'"
check "UFW: Default deny incoming" "LC_ALL=C ufw status | grep -q 'deny (incoming)'"
check "UFW: Default allow outgoing" "LC_ALL=C ufw status | grep -q 'allow (outgoing)'"
check "UFW: SSH rate limiting enabled" "LC_ALL=C ufw status | grep -q 'Limit.*ssh' || LC_ALL=C ufw status | grep -q 'Limit.*22/tcp'"
check "No open ports except essential (e.g., 22)" "LC_ALL=C ss -tlpn | grep LISTEN | wc -l | grep -qE '^[1-5]$'"
check "NFS server not running" "! systemctl is-active nfs-server"
check "Samba server not running" "! systemctl is-active smbd"
check "CUPS (printing) server not running" "! systemctl is-active cups"
check "Avahi daemon (zeroconf) not running" "! systemctl is-active avahi-daemon"
check "No legacy services (telnet, rsh)" "! dpkg -l | grep -E 'telnetd|rsh-server'"

echo -e "\n${BLUE}🧠 Kernel Hardening (sysctl)${NC}"
check "Kernel: IP forwarding disabled" "sysctl net.ipv4.ip_forward | grep -q '0'"
check "Kernel: ICMP redirects disabled" "sysctl net.ipv4.conf.all.accept_redirects | grep -q '0'"
check "Kernel: Secure ICMP redirects disabled" "sysctl net.ipv4.conf.all.secure_redirects | grep -q '0'"
check "Kernel: ICMAP source route disabled" "sysctl net.ipv4.conf.all.accept_source_route | grep -q '0'"
check "Kernel: Log suspicious packets" "sysctl net.ipv4.conf.all.log_martians | grep -q '1'"
check "Kernel: Broadcast ICMP requests ignored" "sysctl net.ipv4.icmp_echo_ignore_broadcasts | grep -q '1'"
check "Kernel: Bogus ICMP responses ignored" "sysctl net.ipv4.icmp_ignore_bogus_error_responses | grep -q '1'"
check "Kernel: SYN cookies enabled" "sysctl net.ipv4.tcp_syncookies | grep -q '1'"
check "Kernel: IPv6 disabled (optional privacy)" "sysctl net.ipv6.conf.all.disable_ipv6 | grep -q '1'"
check "Kernel: IPv6 redirects disabled" "sysctl net.ipv6.conf.all.accept_redirects | grep -q '0'"
check "Kernel: IPv6 source route disabled" "sysctl net.ipv6.conf.all.accept_source_route | grep -q '0'"
check "Kernel: ASLR enabled" "sysctl kernel.randomize_va_space | grep -q '2'"
check "Kernel: Prevents TCP/IP spoofing" "sysctl net.ipv4.conf.all.rp_filter | grep -q '1'"
check "Kernel: ExecShield enabled" "grep -q 'CONFIG_EXECSHIELD=y' /boot/config-$(uname -r)"
check "Kernel: dmesg restricted" "sysctl kernel.dmesg_restrict | grep -q '1'"
check "Kernel: kptr_restrict enabled" "sysctl kernel.kptr_restrict | grep -q '2'"

echo -e "\n${BLUE}🔒 File System & Permissions${NC}"
check "Separate /tmp partition" "LC_ALL=C mount | grep -q ' /tmp '"
check "/tmp mounted with noexec,nosuid,nodev" "LC_ALL=C mount | grep ' /tmp ' | grep -q 'noexec,nosuid,nodev'"
check "Separate /var partition" "LC_ALL=C mount | grep -q ' /var '"
check "/var mounted with nodev,nosuid" "LC_ALL=C mount | grep ' /var ' | grep -q 'nodev,nosuid'"
check "Separate /home partition" "LC_ALL=C mount | grep -q ' /home '"
check "/home mounted with nodev" "LC_ALL=C mount | grep ' /home ' | grep -q 'nodev'"
check "Sticky bit set on /tmp" "find /tmp -maxdepth 0 -perm /1000 | grep -q /tmp"
check "No world-writable files" "! find / -xdev -type f -perm -0002 2>/dev/null | grep ."
check "No world-writable directories" "! find / -xdev -type d -perm -0002 ! -perm -1000 2>/dev/null | grep ."
check "No unowned files" "! find / -xdev -nouser -o -nogroup 2>/dev/null | grep ."
check "No SUID binaries" "! find / -xdev -type f -perm -4000 2>/dev/null | grep ."
check "No SGID binaries" "! find / -xdev -type f -perm -2000 2>/dev/null | grep ."
check "Core dumps restricted" "grep -q 'hard\s+core\s+0' /etc/security/limits.conf"
check "Core dumps disabled (systemd)" "grep -q 'Storage=none' /etc/systemd/coredump.conf"
check "Core dump SUID disabled" "sysctl fs.suid_dumpable | grep -q '0'"
check "Permissions on /etc/shadow (0640)" "stat -c %a /etc/shadow | grep -q '640'"
check "Permissions on /etc/gshadow (0640)" "stat -c %a /etc/gshadow | grep -q '640'"
check "Permissions on /etc/passwd (0644)" "stat -c %a /etc/passwd | grep -q '644'"
check "Permissions on /etc/group (0644)" "stat -c %a /etc/group | grep -q '644'"
check "Permissions on /etc/sudoers (0440)" "stat -c %a /etc/sudoers | grep -q '440'"
check "cron.allow exists" "test -f /etc/cron.allow"
check "at.allow exists" "test -f /etc/at.allow"

echo -e "\n${BLUE}🧯 Logs & Monitoring${NC}"
check "auditd service running" "systemctl is-active auditd"
check "auditd rules loaded" "auditctl -l | grep -q 'rules loaded'"
check "rsyslog service running" "systemctl is-active rsyslog"
check "Logrotate installed" "dpkg -l | grep -q logrotate"
check "Log permissions secure" "find /var/log -type f -perm /006 2>/dev/null | grep -q -v ."
check "Login auditing enabled (/var/log/auth.log)" "test -f /var/log/auth.log"
check "Bash history protected (readonly)" "grep -q 'readonly HISTFILE' /etc/profile"
check "Bash history appends" "grep -q 'shopt -s histappend' /etc/bash.bashrc"

echo -e "\n${BLUE}🧠 Privacy & Telemetry${NC}"
check "ubuntu-report removed" "! dpkg -l | grep -q ubuntu-report"
check "apport (crash reporting) removed" "! dpkg -l | grep -q apport"
check "whoopsie (crash reporting) removed" "! dpkg -l | grep -q whoopsie"
check "popularity-contest removed" "! dpkg -l | grep -q popularity-contest"
check "motd-news disabled" "! systemctl is-enabled motd-news.timer"
check "Canonical Livepatch disabled" "! systemctl is-active canonical-livepatch.service"
check "Snap telemetry off" "! snap get system reporting | grep -q true"
check "Location service off (geoclue)" "! systemctl is-active geoclue"

echo -e "\n${BLUE}🧰 Miscellaneous Hardening${NC}"
check "Compilers restricted to admins" "! find /usr/bin /usr/local/bin -type f \( -name 'gcc' -o -name 'g++' -o -name 'cc' \) 2>/dev/null | xargs -r stat -c '%G' | grep -qv 'root\|admin_group_name'"
check "USB storage disabled (optional)" "grep -q 'install usb-storage /bin/true' /etc/modprobe.d/blacklist-usb.conf"
check "No rogue SUID binaries (bash, nmap, etc)" "! find / -perm -4000 -type f 2>/dev/null | grep -q -E '/(bash|nmap|netcat|nc)$'"
check "System accounts cannot login" "awk -F: '($1!=\"root\" && $1!=\"sync\" && $1!=\"shutdown\" && $1!=\"halt\" && $3<1000 && $7!=\"/usr/sbin/nologin\" && $7!=\"/bin/false\") {print $1}' /etc/passwd | grep -q -v ."

echo -e "\n${YELLOW}📋 Summary${NC}"
PASSED_COUNT=$(grep -c " : PASS" "$LOG_FILE")
FAILED_COUNT=$(grep -c " : FAIL" "$LOG_FILE")
TOTAL=$((PASSED_COUNT + FAILED_COUNT))

if [ "$TOTAL" -gt 0 ]; then
  PERCENT=$((100 * PASSED_COUNT / TOTAL))
else
  PERCENT=0
fi

echo -e "${GREEN}✅ Passed: $PASSED_COUNT${NC}"
echo -e "${RED}❌ Failed: $FAILED_COUNT${NC}"
echo -e "${CYAN}📊 Score: $PERCENT%${NC} ($PASSED_COUNT/$TOTAL)"
echo ""
echo -e "${YELLOW}🗂️  Detailed log saved to:${NC} $LOG_FILE"
echo -e "${BLUE}🔧 Recommendations:${NC} Investigate failed checks and apply security best practices."
echo ""
echo -e "${CYAN}✨ Audit complete. Stay private, stay secure!${NC}"