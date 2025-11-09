# Kernel Hardening (`harden_kernel.sh`)

This document describes `scripts/harden_kernel.sh`, a script that applies kernel-level hardening sysctl settings and persists them under `/etc/sysctl.d/99-hardening.conf`.

## Purpose

Apply recommended kernel tuning values that improve network security and memory/process isolation. The script writes a sysctl configuration file and runs `sysctl --system` to apply settings immediately.

## Quick facts

- Inputs: none (must be run as root)
- Outputs: sysctl file at `/etc/sysctl.d/99-hardening.conf` and a log at `/var/log/harden_kernel_YYYY-MM-DD.log`
- Behavior: writes persistent sysctl settings and applies them

## Prerequisites

- Requires sudo/root to write `/etc/sysctl.d` and run `sysctl --system`.

## Usage

```bash
sudo bash scripts/harden_kernel.sh
```

## Key settings applied

- Disable IPv4 forwarding
- Disable ICMP redirects and secure redirects
- Disable IP source routing
- Enable logging of suspicious packets (martians)
- Enable SYN cookies
- Optionally disable IPv6 (the script sets IPv6 disabled — review before applying)
- Enable ASLR and restrict kernel pointer exposure (`kptr_restrict`)
- Restrict dmesg access (`dmesg_restrict`)

## Notes & verification

After running, review the generated file `/etc/sysctl.d/99-hardening.conf`. To verify settings:

```bash
sudo sysctl -a | grep -E 'ip_forward|redirect|source_route|rp_filter|randomize_va_space|kptr_restrict'
```

If you prefer different values (for example, keep IPv6 enabled), edit the file before running the script or modify the script accordingly.

## Troubleshooting

- Script checks for root and exits if not run with sufficient privilege.
- If `sysctl --system` fails, check `/var/log/harden_kernel_YYYY-MM-DD.log` for errors and inspect `/etc/sysctl.d/99-hardening.conf`.

## Security considerations

- Disabling IPv6 may break some services; treat this as optional and adapt to your environment.

## License

See repository `LICENSE`.
