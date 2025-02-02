# Disk Monitoring Script

## Overview
This Bash script provides a detailed overview of disk usage and partitions on a Linux system. It consists of three sections:

1. **Physical Disks Partitions:** Displays disk partitions with their filesystem type, size, and mount points.
2. **System Paths Usage:** Shows the used and total size for critical system paths (`/`, `/home`, `/var`, `/tmp`).
3. **Disk Monitoring Information:** Provides details about block devices, including partition sizes, disk names, and models.

## Prerequisites
Ensure that the following utilities are available on your system:
- `lsblk`
- `df`
- `awk`

These commands are typically available by default in most Linux distributions.

## Installation
Clone this repository or copy the script file to your local system:
```bash
chmod +x disk_monitor.sh
```

## Usage
Run the script by executing:
```bash
./disk_monitor.sh
```
It will display the disk usage details in the terminal.

## Example Output
```
==========================================
  Physical Disks Partitions (Used/Size)   
==========================================
NAME   FSTYPE   SIZE  MOUNTPOINT
sda    ext4     500G  /
sdb    xfs      1T    /mnt/data

==========================================
  System Paths Usage (Used/Size)          
==========================================
/: Used: 20G / Size: 100G
/home: Used: 50G / Size: 200G
/var: Used: 30G / Size: 150G
/tmp: Used: 5G / Size: 50G

==========================================
  Disk Monitoring Information             
==========================================
NAME   SIZE  TYPE  MOUNTPOINT  MODEL
sda    500G  disk  /           Samsung SSD
sdb    1T    disk  /mnt/data   Seagate HDD
```

## License
This project is licensed under the Apache License 2.0.