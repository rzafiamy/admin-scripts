
# audit_security_priv.sh — Ubuntu Security & Privacy Audit

This document describes `scripts/audit_security_priv.sh`, a comprehensive Bash script that performs a large set of security and privacy checks on Ubuntu systems. The script runs checks across system integrity, user and authentication settings, PAM password policies, SSH hardening, networking and firewall configuration, kernel hardening, filesystem permissions, logging, privacy/telemetry, and miscellaneous hardening items.

## Purpose

The script's goal is to provide a quick, automated audit that highlights misconfigurations and weak defaults which could impact system security or privacy. It prints a colored summary to stdout and writes a detailed log to `/var/log/audit_security_YYYY-MM-DD.log`.

## Quick facts / contract

- Inputs: none (run as root or with sudo to get comprehensive checks).
- Outputs: colored terminal report and a log file at `/var/log/audit_security_$(date +'%Y-%m-%d').log` containing PASS/FAIL per check.
- Exit behavior: the script prints results and recommendations; it does not modify system state.

## Prerequisites

- Designed for Ubuntu / Debian-like systems. Some checks use distro-specific tools and paths (for example, `/etc/apt`, `aa-status`, `ufw`, `snap`, etc.).
- Recommended to run as root (sudo) so checks like file permission tests, service status, and package queries are accurate.
- Optional tools that improve coverage: `debsums`, `mokutil`, `auditd`, `ufw`, `snap`.

## Usage

From the repository root or wherever the script is located, run:

```bash
sudo bash scripts/audit_security_priv.sh
```

The script will print each check with a pass/fail icon and summary counts at the end. A detailed log is written to `/var/log/audit_security_YYYY-MM-DD.log`.

## Output

- Terminal: color-coded checks with emojis indicating PASS (✅), FAIL (❌) and informational messages.
- Log: one-line entries in the log file with the check number, description, and PASS/FAIL state.
- Summary: totals (Passed / Failed) and a percentage score.

Example summary output (shortened):

```
✅ Passed: 42
❌ Failed: 8
📊 Score: 84% (42/50)
🗂️  Detailed log saved to: /var/log/audit_security_2025-11-09.log
```

### Example run and sample log

Run the audit interactively:

```bash
sudo bash scripts/audit_security_priv.sh
```

Or run and capture stdout/stderr to a file:

```bash
sudo bash scripts/audit_security_priv.sh &> ~/audit_run_$(date +%F).log
```

Sample lines from the detailed `/var/log/audit_security_YYYY-MM-DD.log` (each line indicates PASS/FAIL):

```
1. System is 64-bit : PASS
2. Kernel is hardened (CONFIG_HARDENED_USERCOPY=y) : FAIL
3. Secure Boot enabled : PASS
... 
47. auditd service running : PASS
48. auditd rules loaded : FAIL
```

Interpretation tips:

- A small number of failures may be acceptable depending on your environment (for example, intentionally disabled services or different administrative choices).
- Focus first on any checks that expose world-writable files, misconfigured sudoers, or insecure SSH settings.


## Sections checked

The script groups checks into logical sections. Key examples include:

- System integrity & updates (architecture, secure boot, update availability, AppArmor)
- Users & authentication (UID 0 users, home/.ssh permissions, sudoers checks)
- Password policy (pwquality, PAM settings, PASS_MAX_DAYS, etc.)
- SSH server hardening (PermitRootLogin, PasswordAuthentication, Ciphers, MACs)
- Network & firewall (UFW status, listening ports, legacy services)
- Kernel hardening (sysctl values such as rp_filter, ASLR, dmesg/kptr restrictions)
- Filesystem & permissions (world-writable files, SUID/SGID, /tmp sticky bit)
- Logs & monitoring (auditd, rsyslog, logrotate)
- Privacy/telemetry (removal or disabling of ubuntu-report, apport, whoopsie, snap telemetry)
- Miscellaneous hardening (restricting compilers, USB storage, system accounts)

Refer to the script source (`scripts/audit_security_priv.sh`) for the full list of checks and the exact conditions evaluated.

## Customizing checks

- The script is a single-file Bash script. You can add, remove or modify checks by editing the `check` calls near the top of the file.
- Each check uses a description string and a command that should return success (exit code 0) for a PASS. Some checks use an `invert` logic inside the helper function — review the `check()` function behavior before modifying checks.
- To add a new check:

1. Open `scripts/audit_security_priv.sh`.
2. Find an appropriate section (for example, `🔒 SSH Server Hardening`).
3. Add a `check "Description" "<command>"` line. If your command returns 0 on success, no further change is required.

## Running non-interactively

The script prints to stdout and to the log file. To capture output for later review, redirect stdout/stderr:

```bash
sudo bash scripts/audit_security_priv.sh &> ~/audit_security_$(date +%F).log
```

Note: the script itself also writes to `/var/log`.

## Troubleshooting & common notes

- Permissions: many checks require root privileges to inspect files under `/etc`, `/var/log`, or to query services; run with `sudo`.
- False positives: some checks assume default file locations or tools. If your environment differs (custom SSH port, alternative firewall, or AppArmor disabled by design), interpret failures accordingly.
- Missing tools: if `debsums`, `mokutil`, or `aa-status` are unavailable, the corresponding checks may fail or exit non-zero. Install required packages if you want those checks to be accurate.
- Systemd vs non-systemd: checks using `systemctl` assume a systemd-managed host.

### Common failures and quick fixes

- "No UID 0 users except root" fails: check `/etc/passwd` for accounts with UID 0. If a service requires uid 0, consider using sudo/privileged helpers instead of giving arbitrary accounts UID 0.
- Home directory permission failures: run `chmod 750 /home/username` and ensure correct ownership with `chown username:username /home/username`.
- SSH: Password authentication disabled reported as FAIL: if you use password-based logins for legitimate reasons, either update the script expectation or migrate to key-based auth and disable passwords.
- AppArmor reported disabled: enable AppArmor profiles with `systemctl enable --now apparmor` or adapt the check if your OS uses SELinux instead.
- Kernel sysctl checks fail: review `/etc/sysctl.conf` and `/etc/sysctl.d/*` files and reload with `sudo sysctl --system` after making changes.

### Privileges and safe execution

- Always inspect the script if you obtained it from a third party. It is intended to be read-only but review custom changes before running as root.
- Run with `sudo` for full checks. Running as an unprivileged user can produce many false FAILs due to permission-denied errors.

## Next steps and suggestions

- If you want automated remediation, create an Ansible playbook that applies recommended changes for each failed check.
- To integrate with monitoring or inventory systems, add a wrapper that converts the log to structured JSON and ships results to your collector.


## Extending & integrating

- CI / Reporting: you can run this script from a CI job or inventory system and collect logs centrally.
- Automation: convert the script output into JSON by wrapping each check to produce machine-readable key/value lines (small patch suggested below).
- Remediation: the script is audit-only — consider pairing it with configuration management (Ansible/Chef) for automated remediation.

## Security considerations

- The script is read-only; it should not change system state. Review commands before running in sensitive/production systems.
- Keep the script updated as security best practices and sysctl names evolve.

## Example: turning a check into a JSON-friendly line

Small example of how to wrap a check to produce compact results (pseudo-change):

```bash
# Instead of printing colored output, write: echo "{ \"check\": \"SSH: Root login disabled\", \"result\": \"PASS\" }"
```

## License & attribution

See the repository `LICENSE` for license terms for this project.

## Contact / Contributing

If you find errors in checks or have ideas for additional checks, open an issue or submit a pull request in the repository.
