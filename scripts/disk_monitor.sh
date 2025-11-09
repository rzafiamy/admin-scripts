#!/bin/bash
# File: pro_disk_monitor.sh
# Purpose: Beautiful Disk Monitoring Dashboard with Color, Emoji, and Progress
# Author: Paolo’s AI Engineer 🧠

# ────────────────────────────────
# 🎨 Colors & Styles
# ────────────────────────────────
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
MAGENTA="\033[1;35m"
BLUE="\033[1;34m"
BOLD="\033[1m"
NC="\033[0m"

# ────────────────────────────────
# 🌀 Helpers
# ────────────────────────────────
draw_line() { printf "%s\n" "───────────────────────────────────────────────"; }

progress_bar() {
  local progress=$1
  local width=30
  local filled=$((progress * width / 100))
  local empty=$((width - filled))
  printf "["
  printf "%${filled}s" | tr " " "█"
  printf "%${empty}s" | tr " " "░"
  printf "] %3d%%\r" "$progress"
}

# ────────────────────────────────
# 🧮 Section 1: Physical Disks
# ────────────────────────────────
clear
echo -e "${CYAN}💽 ${BOLD}System Disk Overview${NC}"
draw_line

for i in $(seq 0 100 25 50 75 100); do progress_bar "$i"; sleep 0.1; done
echo ""

echo -e "\n${YELLOW}📦 Physical Disks and Partitions${NC}"
draw_line
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT | awk 'NR==1 || NF==4' | column -t
echo ""
tree_output=$(lsblk -o NAME,SIZE,TYPE,MOUNTPOINT --tree)
if command -v tree &> /dev/null; then
  echo -e "${MAGENTA}🌲 Disk Tree Layout${NC}"
  lsblk -o NAME,SIZE,TYPE,MOUNTPOINT --tree
else
  echo -e "${MAGENTA}🌲 Disk Hierarchy${NC}"
  echo "$tree_output"
fi

# ────────────────────────────────
# 🧠 Section 2: Filesystem Usage
# ────────────────────────────────
echo -e "\n${BLUE}🧠 Filesystem Usage Summary${NC}"
draw_line
printf "${BOLD}%-15s %-15s %-15s${NC}\n" "Mount Path" "Used" "Total Size"
for path in / /home /var /tmp; do
  if [ -d "$path" ]; then
    used=$(df -h "$path" | awk 'NR==2 {print $3}')
    size=$(df -h "$path" | awk 'NR==2 {print $2}')
    percent=$(df -h "$path" | awk 'NR==2 {print $5}' | tr -d '%')
    if (( percent > 80 )); then color=$RED; elif (( percent > 60 )); then color=$YELLOW; else color=$GREEN; fi
    printf "${color}%-15s %-15s %-15s${NC}\n" "$path" "$used" "$size"
  fi
done

# ────────────────────────────────
# 🔍 Section 3: Disk Details
# ────────────────────────────────
echo -e "\n${MAGENTA}🔍 Disk Monitoring Information${NC}"
draw_line
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL | column -t

# ────────────────────────────────
# 🧾 Summary
# ────────────────────────────────
echo -e "\n${GREEN}✅ ${BOLD}Scan Complete${NC}"
draw_line
echo -e "${CYAN}$(date)${NC}"
echo -e "Report saved to ${BOLD}/tmp/pro_disk_report.log${NC}"
draw_line

lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT > /tmp/pro_disk_report.log
