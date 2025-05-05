#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis
CLOCK="🕒"
NETWORK="🌐"
ARROW_RIGHT="➡️"
PORT="🔌"
SERVICE="🛠️"

# Function to get service name from port
get_service() {
    local port=$1
    case $port in
        80) echo "HTTP";;
        443) echo "HTTPS";;
        22) echo "SSH";;
        21) echo "FTP";;
        25) echo "SMTP";;
        53) echo "DNS";;
        *) echo "Unknown";;
    esac
}

# Function to print header
print_header() {
    clear
    printf "${CYAN}┌──────────────────────────────────────────────────────────────┐${NC}\n"
    printf "${CYAN}│ ${NETWORK} Network Connection Monitor ${NETWORK} ${NC}\n"
    printf "${CYAN}└──────────────────────────────────────────────────────────────┘${NC}\n"
    printf "${BLUE}%-12s %-10s %-18s %-18s %-10s %-10s${NC}\n" \
           "${CLOCK} Date" "Time" "Source IP" "Dest IP" "${PORT} Port" "${SERVICE} Service"
    printf "${YELLOW}%-12s %-10s %-18s %-18s %-10s %-10s${NC}\n" \
           "---------" "-------" "----------------" "----------------" "-------" "--------"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: This script requires root privileges. Run with sudo.${NC}"
        exit 1
    fi
}

# Function to get connections
get_connections() {
    local connections=""
    local debug_info=""

    # Try conntrack for forwarded traffic
    if command -v conntrack >/dev/null; then
        debug_info="Using conntrack\n"
        connections=$(conntrack -L 2>/dev/null | grep -E 'tcp|udp' | awk '
            {
                src_ip=""; dst_ip=""; dport=""
                for (i=1; i<=NF; i++) {
                    if ($i ~ /^src=/) src_ip=substr($i,5)
                    if ($i ~ /^dst=/) dst_ip=substr($i,5)
                    if ($i ~ /^dport=/) dport=substr($i,7)
                }
                if (src_ip && dst_ip && dport) {
                    print strftime("%Y-%m-%d"), strftime("%H:%M:%S"), src_ip, dst_ip, dport
                }
            }' | sort -u)
    else
        debug_info="conntrack not found\n"
    fi

    # Fallback to ss for local connections
    if [ -z "$connections" ] && command -v ss >/dev/null; then
        debug_info="${debug_info}Using ss\n"
        connections=$(ss -tunap 2>/dev/null | awk '
            NR>1 && $1 ~ /^(tcp|udp)$/ {
                split($5, src, ":"); 
                split($6, dst, ":"); 
                if (src[2] && dst[2]) {
                    print strftime("%Y-%m-%d"), strftime("%H:%M:%S"), src[1], dst[1], dst[2]
                }
            }' | sort -u)
    else
        debug_info="${debug_info}ss not found or no connections\n"
    fi

    # Fallback to netstat
    if [ -z "$connections" ] && command -v netstat >/dev/null; then
        debug_info="${debug_info}Using netstat\n"
        connections=$(netstat -tunap 2>/dev/null | grep -E 'tcp|udp' | awk '
            {
                split($4, src, ":"); 
                split($5, dst, ":"); 
                if (src[2] && dst[2]) {
                    print strftime("%Y-%m-%d"), strftime("%H:%M:%S"), src[1], dst[1], dst[2]
                }
            }' | sort -u)
    else
        debug_info="${debug_info}netstat not found or no connections\n"
    fi

    # Fallback to tcpdump for raw packet capture
    if [ -z "$connections" ] && command -v tcpdump >/dev/null; then
        debug_info="${debug_info}Using tcpdump\n"
        connections=$(timeout 1 tcpdump -i any -nn 'tcp or udp' 2>/dev/null | awk '
            /IP/ {
                split($3, src, "\\."); split($5, dst, "\\.");
                src_ip=src[1]"."src[2]"."src[3]"."src[4];
                dst_ip=dst[1]"."dst[2]"."dst[3]"."dst[4];
                dport=dst[5];
                if (src_ip && dst_ip && dport) {
                    print strftime("%Y-%m-%d"), strftime("%H:%M:%S"), src_ip, dst_ip, dport
                }
            }' | sort -u)
    else
        debug_info="${debug_info}tcpdump not found or no packets captured\n"
    fi

    # If still no connections, show debug info
    if [ -z "$connections" ]; then
        echo -e "${RED}No connections found. Debug info:\n${debug_info}${NC}"
        echo "date time src_ip dst_ip port" # Dummy line to avoid empty output
    else
        echo -e "${YELLOW}Debug info:\n${debug_info}${NC}" >&2
        echo "$connections" | tail -n 20
    fi
}

# Main loop
check_root
while true; do
    print_header

    # Get connections
    connections=$(get_connections)

    # Read connections into array
    IFS=$'\n' read -d '' -r -a lines <<< "$connections"

    # Print each connection
    for line in "${lines[@]}"; do
        read -r date time src_ip dst_ip port <<< "$line"
        # Skip dummy line
        [ "$date" = "date" ] && continue
        service=$(get_service "$port")
        printf "${GREEN}%-12s %-10s ${RED}%-18s ${YELLOW}%-18s ${CYAN}%-10s ${BLUE}%-10s${NC}\n" \
               "$date" "$time" "$src_ip" "$dst_ip" "$port" "$service"
    done

    # Wait for 1 second before refresh
    sleep 1
done