# Service Monitoring Script

## Overview
This Bash script provides a detailed overview of services running on a Linux system. It consists of:

- **Service Name**: The name of the system service.
- **Description**: A short summary of the service.
- **Status**: Whether the service is `active`, `inactive`, or `failed`.
- **User**: The user running the service.
- **Path of Service**: The system path to the service file.

Additionally, the script allows **filtering services by status** (`active`, `inactive`, `failed`, etc.).

## Prerequisites
Ensure that the following utilities are available on your system:
- `systemctl`
- `awk`

These commands are typically available by default in most Linux distributions that use `systemd`.

## Installation
Clone this repository or copy the script file to your local system:
```bash
chmod +x list_services.sh
```

## Usage
Run the script by executing:
```bash
./list_services.sh
```

### **Filter by Status**
You can filter services based on their status by providing an argument:
```bash
./list_services.sh active   # Show only active services
./list_services.sh inactive # Show only inactive services
./list_services.sh failed   # Show only failed services
```

## Example Output
```
Service Name                  Description                                Status     User            Path of Service
----------------------------------------------------------------------------------------------------------------------------------------
sshd.service                  OpenSSH Daemon                             active     root            /lib/systemd/system/sshd.service
nginx.service                 A high performance web server              active     www-data        /lib/systemd/system/nginx.service
cron.service                  Regular background program processing daemon active     root            /lib/systemd/system/cron.service
apache2.service               The Apache HTTP Server                     inactive   root            /lib/systemd/system/apache2.service
mysql.service                 MySQL Database Server                      failed     mysql           /lib/systemd/system/mysql.service
```

## License
This project is licensed under the Apache License 2.0.