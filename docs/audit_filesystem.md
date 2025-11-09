# File-System Audit (`audit_filesystem.sh`)

This document describes `scripts/audit_filesystem.sh`, a focused file-system security audit script that checks for insecure permissions, SUID/SGID binaries, unowned files, and core-dump restrictions.

## Purpose

The script performs file-system related security checks (roughly checks 88–95 in the original audit grouping). It helps identify issues such as world-writable files/directories, unowned files, SUID/SGID binaries, and core-dump configuration risks.

## Quick facts

- Inputs: none (run as root / with sudo for accurate results)
- Outputs: colored terminal report and a detailed log at `/var/log/audit_filesystem_YYYY-MM-DD.log`
- Behavior: read-only (it reports issues and writes findings to a log but does not attempt remediation)

## Prerequisites

- Designed for Linux systems (the script uses `find`, `sysctl`, `systemctl` and typical `/etc` paths).
- Run as root (sudo) so that `find / -xdev` can inspect system files without permission errors.

## Usage

```bash
sudo bash scripts/audit_filesystem.sh
```

## What it checks

- No world-writable files (reports any files with mode `-0002`).
- No world-writable directories (excludes `/tmp` by default in the script).
- No unowned files (files without a valid user or group owner).
- SUID binaries (reports SUIDs — these may be warnings because some are expected).
- SGID binaries (reports SGIDs — often informational/warning).
- Core-dump restrictions (ensures system limits and systemd-coredump settings reduce risk of sensitive core dumps).

## Output

- Terminal: colored summary lines showing PASS/FAIL/WARN for each check.
- Log file: a detailed list of offending files or items is saved to `/var/log/audit_filesystem_YYYY-MM-DD.log` when failures are found.

Example snippet from the log:

```
[World-writable directories]
/srv/public
/var/www/html/uploads

[SUID binaries]
/usr/bin/passwd
/usr/bin/sudo
```

## Interpretation & next steps

- World-writable files or directories should be reviewed and fixed with `chmod`/`chown` as appropriate.
- Unowned files suggest package removal or orphaned files — investigate ownership and assign to correct user/group.
- SUID/SGID binaries are not always bad, but unexpected entries should be audited; remove or reconfigure unneeded ones.
- Core-dump protections: consider disabling core dumps or redirecting them to secure storage. Review `/etc/security/limits.conf`, systemd coredump settings, and `kernel.core_pattern`.

## Troubleshooting

- Running without sudo will produce false FAILs due to permission-denied results — run with root privileges.
- The `find / -xdev` scan can be slow on large filesystems; run during maintenance windows if needed.
- The script writes to `/var/log` — ensure sufficient disk space and permissions.

## License

See repository `LICENSE`.
