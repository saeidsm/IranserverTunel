# Contributing

PRs welcome! Please follow these guidelines:

## Before submitting

1. **Test on actual Iranian VPS** if your change is Iran-specific
2. **Update TECH_DEBT.md** if you discover new limitations
3. **Update SHAHRZAD_INTEGRATION.md** if your change affects backend integration plans
4. **Never commit secrets** — no API keys, no real VLESS UUIDs, no production hostnames

## Code style

- Bash: use `set -euo pipefail` at the top of new scripts
- Comments in English (for international contributors)
- User-facing messages can be Persian or English

## Local development

The script can run on any Linux for testing routing logic. You can simulate a SOCKS5 proxy with:

```bash
# Simulate a tunnel locally:
ssh -D 1080 -N somewhere@example.com &
```

Then test the management commands without setting up real Xray instances.

## Testing checklist

Before submitting a PR:
- [ ] `bash -n tunnel-mgr` passes (syntax check)
- [ ] Tested adding a tunnel via VLESS URL
- [ ] Tested adding a tunnel via JSON file
- [ ] Tested adding a tunnel via paste JSON
- [ ] Health check works
- [ ] Pause/resume work
- [ ] Status display is correct after each operation

## Reporting issues

Open an issue with:
- VPS provider (e.g., ArvanCloud)
- Ubuntu version
- Steps to reproduce
- Output of `sudo tunnel-mgr status` (sanitized — no UUIDs)
- Output of `journalctl -u xray-NAME --no-pager -n 30`
