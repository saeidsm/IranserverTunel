# IranserverTunel

> A unified V2Ray/Xray tunnel manager with HAProxy load balancing, designed for Iranian VPS servers that need reliable access to international AI/SaaS services.

[Persian section below | بخش فارسی پایین صفحه]

## English

### Why this exists

Iranian VPS servers face two challenges when accessing international services:
1. Many international APIs (Google, OpenAI, ElevenLabs, etc.) are blocked from Iranian IPs
2. Iranian payment gateways (ZarinPal, Shaparak) and CDN (ArvanCloud) require direct access from Iranian IPs

This tool manages a pool of V2Ray/Xray tunnels (each pointing to different international servers) behind a single HAProxy SOCKS5 entry point. Your application connects to ONE proxy URL, and HAProxy load-balances across healthy tunnels with automatic failover.

### Features

- Single entry point — Your app uses `socks5h://127.0.0.1:1080`, regardless of how many tunnels exist
- Multi-protocol — Supports VLESS via WebSocket, TCP+HTTP camouflage
- Three input methods — VLESS URLs, JSON files, or paste JSON inline
- Automatic enrichment — Adds Iran-specific routing rules (Shecan DNS for `.ir`, direct routing for Iranian services)
- Health monitoring — Quick checks every 15min, deep tests every 6h
- Auto-pause — Failed tunnels pause for 2 hours, then auto-retry
- Capability detection — Tests each tunnel against Gemini/FLUX/ElevenLabs to verify which services work
- Interactive TUI — Simple menu with status colors

### Important: Iran-specific design

This tool is opinionated for Iranian deployments. By default, the following hosts bypass the tunnel:
- All `.ir` domains
- ArvanCloud (storage/CDN)
- ZarinPal, Shaparak (payment gateways)
- Bale messenger
- Local services (MongoDB, Redis, etc.)

If you're not deploying in Iran, you'll want to customize `data/iran-direct-hosts.txt` after first run.

### Quick start

See [docs/INSTALL.md](docs/INSTALL.md).

### Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## فارسی

### چرا این ابزار

سرورهای VPS داخل ایران با دو چالش مواجه‌اند:
1. سرویس‌های بین‌المللی (Google, OpenAI, ElevenLabs) از IP ایرانی block می‌شوند
2. درگاه‌های پرداخت ایرانی (زرین‌پال، شاپرک) و CDN ها (ArvanCloud) باید مستقیم از IP ایرانی فراخوانی شوند

این ابزار یک pool از tunnel های V2Ray/Xray (که هر کدام به سرور خارجی متفاوتی وصل می‌شوند) را پشت یک HAProxy SOCKS5 مدیریت می‌کند. اپلیکیشن شما فقط به یک proxy URL وصل می‌شود و HAProxy بین tunnel های سالم load balance می‌کند با failover خودکار.

### ویژگی‌ها

- یک نقطه ورود — اپ شما به `socks5h://127.0.0.1:1080` وصل می‌شود
- چند پروتکل — VLESS over WebSocket، TCP+HTTP camouflage
- سه روش ورودی — VLESS URL، فایل JSON، یا paste JSON
- Enrichment خودکار — قواعد routing ایرانی اضافه می‌کند (DNS Shecan برای `.ir`، routing مستقیم برای سرویس‌های ایرانی)
- Monitoring مداوم — تست سریع هر ۱۵ دقیقه، تست عمیق هر ۶ ساعت
- Auto-pause — tunnel خراب ۲ ساعت غیرفعال می‌شود، بعد retry
- تشخیص قابلیت — هر tunnel با Gemini/FLUX/ElevenLabs تست می‌شود
- منوی تعاملی — TUI ساده با رنگ‌بندی

### راه‌اندازی سریع

```bash
# 1. نصب Xray-core (یک بار)
sudo bash scripts/install-xray.sh

# 2. نصب tunnel-mgr
sudo cp tunnel-mgr /usr/local/bin/
sudo chmod +x /usr/local/bin/tunnel-mgr

# 3. setup اولیه (HAProxy + cron)
sudo tunnel-mgr setup

# 4. اضافه کردن اولین tunnel
sudo tunnel-mgr add my-tunnel
```

برای جزئیات بیشتر: [docs/INSTALL.md](docs/INSTALL.md)

## License

MIT — see [LICENSE](LICENSE)

## Contributing

This is a personal project but PRs are welcome. For Iranian deployment improvements, please test on actual Iranian VPS before submitting.

## Disclaimer

This software is provided for legitimate use cases such as:
- Backend API access from servers in regions with internet restrictions
- Development/staging environments

Users are responsible for compliance with their local laws and the terms of service of any tunnel providers used.
