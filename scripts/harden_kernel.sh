#!/bin/bash
# File: /usr/local/bin/harden_kernel.sh
# Purpose: Apply kernel (sysctl) hardening parameters for privacy and security
# Author: Paolo’s vigilant AI 🧠

LOG_FILE="/var/log/harden_kernel_$(date +'%Y-%m-%d').log"
SYSCTL_CONF="/etc/sysctl.d/99-hardening.conf"

GREEN="\033[1;32m"; CYAN="\033[1;36m"; NC="\033[0m"

echo -e "${CYAN}🧠 Kernel Hardening (sysctl)${NC}"
echo "Applying kernel-level security controls..."
echo "Changes logged to $LOG_FILE"
echo ""

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)."
  exit 1
fi

cat > "$SYSCTL_CONF" <<EOF
# Kernel Hardening Configuration

# 65. Disable IPv4 forwarding
net.ipv4.ip_forward = 0

# 66. Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

# 67. Disable secure ICMP redirects
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# 68. Disable source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# 69. Log suspicious packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# 70. Ignore broadcast ICMP requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# 71. Ignore bogus ICMP errors
net.ipv4.icmp_ignore_bogus_error_responses = 1

# 72. Enable SYN cookies
net.ipv4.tcp_syncookies = 1

# 73. Disable IPv6 (optional)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# 74. Disable IPv6 redirects
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# 75. Disable IPv6 source routing
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# 76. Enable ASLR (Address Space Layout Randomization)
kernel.randomize_va_space = 2

# 77. Prevent TCP/IP spoofing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# 78. ExecShield (modern equivalent: memory protection via NX)
kernel.exec-shield = 1
kernel.kptr_restrict = 2

# 79. Restrict dmesg access
kernel.dmesg_restrict = 1

# 80. Hide kernel pointers in /proc
kernel.kptr_restrict = 2
EOF

sysctl --system >> "$LOG_FILE" 2>&1

echo ""
echo -e "${GREEN}✅ Kernel hardening applied and persisted in:${NC} $SYSCTL_CONF"
echo "🗂️  Log: $LOG_FILE"
echo ""
echo -e "${CYAN}🔍 Verify settings:${NC}"
echo "Run: sudo sysctl -a | grep -E 'ip_forward|redirect|source_route|rp_filter|randomize_va_space|kptr_restrict'"
