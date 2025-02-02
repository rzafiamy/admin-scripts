#!/bin/bash

echo "=========================================="
echo "  Physical Disks Partitions (Used/Size)   "
echo "=========================================="
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT | awk 'NR==1 || NF==4'

echo
echo "=========================================="
echo "  System Paths Usage (Used/Size)          "
echo "=========================================="
for path in / /home /var /tmp; do
    if [ -d "$path" ]; then
        used=$(df -h "$path" | awk 'NR==2 {print $3}')
        size=$(df -h "$path" | awk 'NR==2 {print $2}')
        echo "$path: Used: $used / Size: $size"
    fi
done

echo
echo "=========================================="
echo "  Disk Monitoring Information             "
echo "=========================================="
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL
