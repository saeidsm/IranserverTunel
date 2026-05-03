# IranserverTunel

> Unified V2Ray/Xray tunnel manager with HAProxy load balancing — designed for servers in regions with internet restrictions, particularly Iran.

[Persian section below | بخش فارسی پایین]

## English

### Why this exists

Servers in restricted-internet regions (e.g., Iran) face two simultaneous challenges:

1. International APIs (Google, OpenAI, ElevenLabs, FLUX, etc.) are blocked from local IPs
2. Local services (payment gateways, CDNs, regional messengers) require direct access from local IPs — they reject foreign IPs

This tool manages a **pool** of V2Ray/Xray tunnels (each pointing to different international servers) behind a **single HAProxy SOCKS5 entry point**. Your application connects to one proxy URL, and HAProxy load-balances across healthy tunnels with automatic failover.

### Features

- **Single entry point** — Application uses `socks5h://127.0.0.1:1080`
- **Multi-protocol support** — VLESS over WebSocket, TCP+HTTP camouflage
- **Three input methods** — VLESS URLs, JSON files, or paste JSON inline
- **Automatic enrichment** — Adds region-specific routing rules (Shecan DNS for `.ir`, direct routing for local services)
- **Health monitoring** — Quick checks every 15min, deep tests every 6h
- **Auto-pause** — Failed tunnels pause for 2 hours, then auto-retry
- **Capability detection** — Tests each tunnel against Gemini/FLUX/ElevenLabs to identify which services work
- **Interactive TUI menu** — Bash-based with status colors

### Iran-specific design (default)

By default, the following bypass the tunnel:
- All `.ir` domains
- ArvanCloud (storage/CDN)
- Iranian payment gateways (ZarinPal, Shaparak)
- Iranian messengers (Bale)
- Local services (MongoDB, Redis, etc.)

If you're not deploying in Iran, customize `data/iran-direct-hosts.txt` after first run.

### Quick start

See [docs/INSTALL.md](docs/INSTALL.md).

### Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## فارسی

### چرا این ابزار

سرورهای VPS داخل ایران با دو چالش همزمان مواجه‌اند:

۱. سرویس‌های بین‌المللی (Google, OpenAI, ElevenLabs, FLUX) از IP ایرانی block می‌شوند
۲. سرویس‌های ایرانی (درگاه‌های پرداخت، CDN، پیام‌رسان‌ها) باید مستقیم از IP ایرانی فراخوانی شوند

این ابزار یک **pool** از tunnel های V2Ray/Xray را پشت یک **HAProxy SOCKS5** مدیریت می‌کند. اپلیکیشن شما به یک proxy URL وصل می‌شود و HAProxy بین tunnel های سالم load balance می‌کند با failover خودکار.

### ویژگی‌ها

- **یک نقطه ورود** — `socks5h://127.0.0.1:1080`
- **چند پروتکل** — VLESS over WebSocket، TCP+HTTP camouflage
- **سه روش ورودی کانفیگ** — VLESS URL، فایل JSON، یا paste JSON inline
- **Enrichment خودکار** — قواعد routing ایرانی اضافه می‌کند (Shecan DNS برای `.ir`، routing مستقیم برای سرویس‌های ایرانی)
- **Monitoring** — تست سریع هر ۱۵ دقیقه، تست عمیق هر ۶ ساعت
- **Auto-pause** — tunnel خراب ۲ ساعت غیرفعال و بعد retry
- **تشخیص قابلیت** — هر tunnel با Gemini/FLUX/ElevenLabs تست می‌شود
- **منوی TUI تعاملی** — bash-based با رنگ‌بندی

### راه‌اندازی سریع

```bash
# 1. نصب Xray-core
sudo bash scripts/install-xray.sh

# 2. نصب tunnel-mgr
sudo cp tunnel-mgr /usr/local/bin/
sudo chmod +x /usr/local/bin/tunnel-mgr

# 3. setup اولیه (HAProxy + cron)
sudo tunnel-mgr setup

# 4. اضافه کردن tunnel
sudo tunnel-mgr add my-tunnel
```

برای جزئیات بیشتر: [docs/INSTALL.md](docs/INSTALL.md)

## License

MIT — see [LICENSE](LICENSE)

## Project documentation

- **[docs/INSTALL.md](docs/INSTALL.md)** — Installation guide
- **[docs/USAGE.md](docs/USAGE.md)** — Command reference  
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** — How it works internally
- **[docs/API_KEYS_SETUP.md](docs/API_KEYS_SETUP.md)** — Setting up API keys for deep tests
- **[TECH_DEBT.md](TECH_DEBT.md)** — Known limitations and future improvements
- **[SHAHRZAD_INTEGRATION.md](SHAHRZAD_INTEGRATION.md)** — Plans for integrating with Shahrzad backend
- **[CHANGELOG.md](CHANGELOG.md)** — Version history
- **[CONTRIBUTING.md](CONTRIBUTING.md)** — How to contribute

## Disclaimer

This software is provided for legitimate use cases:
- Server-to-server backend API access in regions with internet restrictions
- Development and staging environments
- Educational research

Users are responsible for compliance with local laws and tunnel provider terms of service.
