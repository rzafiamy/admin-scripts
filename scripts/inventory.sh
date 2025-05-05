#!/bin/bash

# Colors for formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print section header
print_header() {
    echo -e "${BLUE}======================================${NC}"
    echo -e "${YELLOW}📊 $1 ${NC}"
    echo -e "${BLUE}======================================${NC}"
}

# Collect system information
HOSTNAME=$(hostname)
IP_ADDRESS=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d'/' -f1 | head -n 1)
SERIAL_NUMBER=$(dmidecode -s system-serial-number 2>/dev/null | grep -v '^#')
SYSTEM_MANUFACTURER=$(dmidecode -s system-manufacturer 2>/dev/null | grep -v '^#')
SYSTEM_MODEL=$(dmidecode -s system-product-name 2>/dev/null | grep -v '^#')

# Start report
clear
echo -e "${GREEN}🚀 System Inventory Report for $HOSTNAME 🚀${NC}\n"

# System Overview
print_header "System Overview 🖥️"
echo -e "Hostname: ${GREEN}$HOSTNAME${NC}"
echo -e "IP Address: ${GREEN}$IP_ADDRESS${NC}"
echo -e "Manufacturer: ${GREEN}$SYSTEM_MANUFACTURER${NC}"
echo -e "Model: ${GREEN}$SYSTEM_MODEL${NC}"
echo -e "Serial Number: ${GREEN}$SERIAL_NUMBER${NC}"

# CPU Information
print_header "Processor 🧑‍💻"
CPU_MODEL=$(lscpu | grep "Model name:" | awk -F: '{print $2}' | xargs)
CPU_CORES=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
CPU_SPEED=$(lscpu | grep "CPU MHz:" | awk '{print $3}' | xargs)
echo -e "Model: ${GREEN}$CPU_MODEL${NC}"
echo -e "Cores: ${GREEN}$CPU_CORES${NC}"
echo -e "Speed: ${GREEN}$CPU_SPEED MHz${NC}"

# Motherboard Information
print_header "Motherboard 🔌"
MB_MANUFACTURER=$(dmidecode -s baseboard-manufacturer 2>/dev/null | grep -v '^#')
MB_MODEL=$(dmidecode -s baseboard-product-name 2>/dev/null | grep -v '^#')
MB_SERIAL=$(dmidecode -s baseboard-serial-number 2>/dev/null | grep -v '^#')
echo -e "Manufacturer: ${GREEN}$MB_MANUFACTURER${NC}"
    echo -e "Model: ${GREEN}$MB_MODEL${NC}"
echo -e "Serial Number: ${GREEN}$MB_SERIAL${NC}"

# Disk Information
print_header "Physical Disks 💾"
lsblk -d -o NAME,SIZE,VENDOR,MODEL,SERIAL | grep -v loop | while read -r line; do
    NAME=$(echo "$line" | awk '{print $1}')
    SIZE=$(echo "$line" | awk '{print $2}')
    VENDOR=$(echo "$line" | awk '{print $3}')
    MODEL=$(echo "$line" | awk '{print $4}')
    SERIAL=$(echo "$line" | awk '{print $5}')
    AVAILABLE=$(df -h /dev/"$NAME" 2>/dev/null | tail -1 | awk '{print $4}' || echo "N/A")
    echo -e "Disk: ${GREEN}$NAME${NC} | Size: $SIZE | Available: $AVAILABLE | Vendor: $VENDOR | Model: $MODEL | Serial: $SERIAL"
done

# RAM Information
print_header "Physical RAM 🧠"
dmidecode -t memory | grep -E "Size:|Manufacturer:|Serial Number:|Part Number:" | awk '
    /Size:/ {size=$2" "$3}
    /Manufacturer:/ {man=$2}
    /Serial Number:/ {serial=$3}
    /Part Number:/ {part=$3; print "RAM: "size" | Manufacturer: "man" | Part Number: "part" | Serial: "serial}
' | grep -v "No Module" | while read -r line; do
    echo -e "${GREEN}$line${NC}"
done

# Partitions
print_header "Partitions 📂"
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,UUID | grep -v loop | while read -r line; do
    NAME=$(echo "$line" | awk '{print $1}')
    FSTYPE=$(echo "$line" | awk '{print $2}')
    SIZE=$(echo "$line" | awk '{print $3}')
    MOUNTPOINT=$(echo "$line" | awk '{print $4}')
    UUID=$(echo "$line" | awk '{print $5}')
    echo -e "Partition: ${GREEN}$NAME${NC} | Type: $FSTYPE | Size: $SIZE | Mount: $MOUNTPOINT | UUID: $UUID"
done

# Network Cards
print_header "Network Cards 🌐"
lshw -class network 2>/dev/null | grep -E "description:|product:|vendor:|serial:|logical name:" | awk '
    /logical name:/ {iface=$3}
    /description:/ {desc=$2}
    /product:/ {prod=$2}
    /vendor:/ {ven=$2}
    /serial:/ {serial=$2; print "Interface: "iface" | Card: "desc" | Product: "prod" | Vendor: "ven" | MAC: "serial}
' | while read -r line; do
    echo -e "${GREEN}$line${NC}"
done

# Listening Services
print_header "Listening Ports 🔓"
ss -tuln | grep LISTEN | awk '{print $5}' | while read -r port; do
    PORT_NUM=$(echo "$port" | cut -d':' -f2)
    SERVICE=$(netstat -tulnp 2>/dev/null | grep ":$PORT_NUM " | awk '{print $7}' | cut -d'/' -f2 | head -n 1)
    echo -e "Port: ${GREEN}$PORT_NUM${NC} | Service: $SERVICE"
done

echo -e "\n${GREEN}✅ Inventory Report Complete!${NC}"