# inventory.sh

## Overview

`inventory.sh` is a small system inventory script located at `scripts/inventory.sh` that collects and prints a comprehensive report about the host system. It gathers information such as hostname, IP address, serial number, manufacturer, model, CPU, RAM, motherboard, physical disks, partitions, network interfaces, and listening ports.

The script uses common Linux utilities to produce a human-readable report with colorized output suitable for terminal viewing.

## What it reports

- Hostname and primary IP address
- System manufacturer, model and serial number (via `dmidecode`)
- CPU model, cores and frequency (via `lscpu`)
- Motherboard vendor, model and serial (via `dmidecode`)
- Physical disks (via `lsblk`) including size, vendor, model and serial
- Physical RAM module details (via `dmidecode`)
- Partitions with filesystem types and mount points (via `lsblk`)
- Network cards and related metadata (via `lshw`)
- Listening TCP/UDP ports and associated services (via `ss` and `netstat`)

## Prerequisites

The script calls several utilities that may not be installed by default on all distributions. Install the following packages if they are missing:

- `dmidecode` (reads DMI/BIOS information; requires root to show full details)
- `lshw` (hardware listing)
- `lsblk` (from util-linux)
- `lscpu` (from util-linux)
- `ss` (from iproute2)
- `netstat` (typically provided by the `net-tools` package)

On Debian/Ubuntu you can install them with:

```bash
sudo apt update
sudo apt install dmidecode lshw net-tools
```

On RHEL/CentOS/Fedora:

```bash
sudo dnf install dmidecode lshw net-tools
# or on older systems: sudo yum install dmidecode lshw net-tools
```

Note: `lsblk` and `lscpu` are usually included in the `util-linux` package which is typically present by default.

## Permissions

`dmidecode` and `lshw` may require root privileges to access full hardware information. Run the script with `sudo` to get the most complete output:

```bash
sudo ./scripts/inventory.sh
```

If you cannot run as root, the script will still run but some fields may show `N/A`, be empty, or include limited information.

## Usage

Make the script executable and run it:

```bash
chmod +x scripts/inventory.sh
./scripts/inventory.sh
# or with sudo for full details:
sudo ./scripts/inventory.sh
```

The script clears the terminal and prints a colored, sectioned report. Redirecting the output to a file will capture raw ANSI color codes; to save a clean report without colors you can pipe through `sed` to remove ANSI sequences:

```bash
# Save colorized output (includes ANSI escape sequences):
./scripts/inventory.sh > inventory-colors.txt

# Save a cleaned, plain-text copy:
./scripts/inventory.sh | sed -r "s/\x1B\[[0-9;]*[JKmsu]//g" > inventory.txt
```

## Examples

- Quick run locally:

```bash
./scripts/inventory.sh
```

- Capture report for asset tracking (plain text):

```bash
sudo ./scripts/inventory.sh | sed -r "s/\x1B\[[0-9;]*[JKmsu]//g" > /tmp/$(hostname)-inventory.txt
```

## Troubleshooting

- Blank or missing manufacturer/model/serial: run with `sudo` because `dmidecode` reads from privileged system interfaces.
- `lshw` shows limited info: again, run as root for full details.
- `netstat` not found: install `net-tools` or edit the script to use `ss -tulpen` with process info. On modern systems `ss` can be used to show process info if available.
- `lsblk` parsing oddities: `lsblk` output formats differ between versions. If you see unexpected columns, run `lsblk -o NAME,SIZE,VENDOR,MODEL,SERIAL` manually to check column order.

## Security note

This script prints hardware identifiers and network information. Treat its output as sensitive and avoid uploading or sharing it publicly without redaction.

## Contributing

If you'd like the script to output JSON, filter by device type, or include additional checks (e.g., SMART status for disks), open a PR or issue in the repository.

## See also

- `scripts/apt-upgradables.sh` — list packages that need upgrading
- `scripts/list_services.sh` — list system services

---

Generated with reference to `scripts/inventory.sh`.