
# 🧰 admin-scripts — Lightweight admin utilities

A curated collection of small admin scripts to help inspect, monitor, and audit Ubuntu/Debian systems. Each script is designed to be simple, portable, and easy to run from the command line.

---

## 📚 Documentation

Find detailed documentation for the included tools in the `docs/` folder. Quick links:

- 🛡️ `docs/audit_security_priv.md` — Comprehensive security & privacy audit (large set of sysctl, PAM, SSH, filesystem and service checks).
- 📦 `docs/apt-upgradables.md` — List upgradable packages in a friendly table (supports English & French).
- 💽 `docs/disk-monitor.md` — Disk usage and partition overview with per-path usage.
 - 🧾 `docs/inventory.md` — System inventory report (hardware, disks, network, listening services).
- ⚙️ `docs/list-services.md` — Service status and filtering (active / inactive / failed).
 - 🧱 `docs/audit_filesystem.md` — File-system specific audit (world-writable files/dirs, SUID/SGID, unowned files, core-dump restrictions).
 - 🧠 `docs/harden_kernel.md` — Script to apply kernel (sysctl) hardening settings and persist them.
 - 🧯 `docs/harden_logging.md` — Scripts to enable auditd, load audit rules, secure logs and harden Bash history.

---

## 🗂️ Available scripts

Scripts live in the `scripts/` directory. Short descriptions and usage:

- 📦 `scripts/apt-upgradables.sh` — Shows upgradable packages and suggests upgrade commands.
	- Usage: `sudo bash scripts/apt-upgradables.sh`

- 🔐 `scripts/audit_security_priv.sh` — Run a broad security & privacy audit and save results to `/var/log/audit_security_YYYY-MM-DD.log`.
	- Usage: `sudo bash scripts/audit_security_priv.sh`

- 🔁 `scripts/bounce_monitor.py` — (Python) Lightweight monitor/restart helper (check script header for usage details).

- 💽 `scripts/disk_monitor.sh` — Prints partitions, block devices and per-path usage.
	- Usage: `bash scripts/disk_monitor.sh`
	- Notes: this script prints a colored, human-friendly disk dashboard and
	  saves a simple `lsblk` snapshot to `/tmp/pro_disk_report.log` by default.

- 🔍 `scripts/find_dns_by_cert.sh` — Find domains/hosts by certificate attributes (search TLS certs for names).

- 🧾 `scripts/inventory.sh` — Gather basic system inventory (packages, kernel, CPU, memory, disks).

- 🧾 `scripts/inventory.sh` — Gather basic system inventory (hostname, DMI info, CPU, memory, disks, network, listening ports).

- 📋 `scripts/list_services.sh` — List systemd services with status and allow filtering by status.
	- Usage: `bash scripts/list_services.sh [active|inactive|failed]`

- ✉️ `scripts/mail_stats.py` — (Python) Collect simple mail statistics from logs or mail queues (see script header).

- 🌐 `scripts/netmon.sh` — Network interface and connection summary.

---

## 🧭 Quick start

1. Clone the repo:

```bash
git clone https://github.com/rzafiamy/admin-scripts.git
cd admin-scripts
```

2. Read a specific doc for details (for example):

```bash
less docs/audit_security_priv.md
```

3. Run a script (use `sudo` where the script needs to inspect protected files):

```bash
sudo bash scripts/audit_security_priv.sh
```

---

## Contributing

Contributions welcome! Open an issue or submit a pull request to add features, improve checks, or fix documentation.

---

## License

See the `LICENSE` file for license terms.

---

Happy administering! 🚀
