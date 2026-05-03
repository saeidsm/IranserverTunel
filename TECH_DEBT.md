# Technical Debt & Future Improvements

این فایل بدهی‌های فنی شناخته‌شده، محدودیت‌های فعلی، و بهبودهای آتی را track می‌کند.

**به‌روزرسانی:** هر تغییر یا یافته‌ی جدید را به این فایل اضافه کن. این یک living document است.

---

## 🔴 P1 — مهم، باید قبل از scale حل شوند

### TD-001: aiohttp و NO_PROXY
**مشکل:** Python `aiohttp` به‌صورت پیش‌فرض `NO_PROXY` env var را احترام نمی‌گذارد. اگر `HTTPS_PROXY=socks5h://...` تنظیم شود، **همه** request ها از proxy می‌گذرند، حتی domain هایی که در `NO_PROXY` لیست شده‌اند.

**تأثیر:** 
- ZarinPal API call از tunnel می‌رود → fail (سرور خارجی به ZarinPal IP-restricted دسترسی ندارد)
- ArvanCloud bucket upload از tunnel می‌رود → کند و wasteful
- MongoDB/Redis در Docker network → باز هم از tunnel می‌رود → break

**راه‌حل پیشنهادی (Solution 2 از ARCHITECTURE.md):**
ساخت یک wrapper در `core/http_client.py` که قبل از هر request چک کند destination ایرانی است یا نه:

```python
# pseudo-code
DIRECT_HOSTS = load_from("data/iran-direct-hosts.txt")

async def smart_request(url, **kw):
    if not _needs_proxy(url):
        return await session.request(url, **kw)  # direct
    kw["proxy"] = "socks5h://127.0.0.1:1080"
    return await session.request(url, **kw)
```

**کجا استفاده می‌شود:**
- `services/story_engine.py` (Vertex/Gemini calls)
- `services/image_service.py` (FLUX calls)
- `services/voice_service.py` (ElevenLabs calls)
- `api/payment.py` (ZarinPal — باید **direct** باشد!)

**تخمین:** ۲-۳ روز کار + smoke tests
**اولویت:** قبل از production deploy روی Iran

---

### TD-002: کانفیگ‌های VLESS با Reality یا gRPC پشتیبانی نمی‌شوند
**مشکل:** `vless_to_config()` در tunnel-mgr فقط `type=ws` و `type=tcp` (با optional HTTP header) را parse می‌کند.

**تأثیر:** اگر فروشنده‌ای کانفیگ با `security=reality` یا `type=grpc` بدهد، باید JSON دستی paste شود (Method 3).

**راه‌حل:** اضافه کردن parser برای:
- `security=reality` (با sni, fingerprint, publicKey, shortId)
- `type=grpc` (با serviceName, mode)
- `type=h2` (HTTP/2)
- `type=httpupgrade` (alternative to ws)

**تخمین:** ۲-۳ ساعت برای هر فرمت
**اولویت:** وقتی فروشنده‌ای با Reality پیدا کردیم

---

### TD-003: Capability detection static است
**مشکل:** Pool dispatcher (HAProxy) "blind" است — round-robin بدون توجه به capability ها. اگر tunnel فقط `freezen` در pool باشد و request برای ElevenLabs بیاید، fail می‌شود.

**وضعیت فعلی:** فقط tunnel هایی که **همه** capability ها را pass کنند (qualified=true) وارد pool می‌شوند. این conservative است.

**تأثیر:** tunnel هایی که فقط Gemini و FLUX کار می‌کنند (نه ElevenLabs) حذف می‌شوند، حتی اگر بتوانیم برای text+image از آن‌ها استفاده کنیم.

**راه‌حل ۱ (ساده):** قبول وضعیت فعلی. tunnel اگر همه‌کاره نیست، اضافه نشود. ساده، قابل اعتماد.

**راه‌حل ۲ (پیچیده):** Service-aware routing با چند HAProxy backend:
- `tunnel_pool_text` — برای Gemini/text
- `tunnel_pool_image` — برای FLUX
- `tunnel_pool_audio` — برای ElevenLabs

و یک Python wrapper در shahrzad که بر اساس URL، یکی از این port ها را انتخاب کند:
- `tunnel_pool_text` → `127.0.0.1:1081`
- `tunnel_pool_image` → `127.0.0.1:1082`
- `tunnel_pool_audio` → `127.0.0.1:1083`

**تخمین:** ۱-۲ روز
**اولویت:** فقط اگر tunnel های partial-capability زیاد شد

---

### TD-004: مدیریت quota tunnel
**مشکل:** فروشنده‌های V2Ray معمولاً quota محدود دارند (۱GB، ۵GB، unlimited). فعلاً نمی‌دانیم کدام tunnel چقدر استفاده شده.

**تأثیر:** tunnel ممکن است بدون اطلاع silent fail شود وقتی quota تمام شد.

**راه‌حل:**
1. اضافه کردن `quota_limit_gb` و `quota_used_gb` به state file
2. خواندن HAProxy stats per backend برای رصد bytes transferred
3. در `status` نمایش `Used: X / Y GB`
4. هشدار وقتی > 80% رسید
5. auto-pause وقتی > 95% رسید

**تخمین:** ۱-۲ روز
**اولویت:** متوسط — وقتی > ۳ tunnel داریم

---

## 🟡 P2 — مهم، بعد از launch

### TD-005: Health check روی غلط چیز را تست می‌کند
**مشکل:** Quick health check فقط `aiplatform.googleapis.com` را تست می‌کند. اگر فقط Vertex block شد ولی FLUX کار می‌کرد، بازهم tunnel pause می‌شود.

**راه‌حل:** Quick health چند سرویس را round-robin تست کند:
- `aiplatform.googleapis.com` (Google)
- `api.bfl.ai` (FLUX)
- `api.elevenlabs.io` (EL)
- `github.com` (general)

نتیجه را OR می‌کند: اگر **هر کدام** پاسخ دهد، tunnel سالم.

**تخمین:** ۳۰ دقیقه
**اولویت:** بعد از یک هفته‌ی استفاده

---

### TD-006: HAProxy stats در صفحه مدیریت
**مشکل:** فعلاً HAProxy stats فقط روی `127.0.0.1:8404` است، نیاز به SSH tunnel دارد.

**راه‌حل:** یا:
1. اضافه کردن یک endpoint در `tunnel-mgr status` که stats را parse و نمایش دهد (bandwidth, requests count, error rate)
2. یا یک web UI کوچک با Flask/FastAPI روی پورت admin

**تخمین:** ۲-۴ ساعت
**اولویت:** پایین

---

### TD-007: Auto-pause ممکن است false-positive داشته باشد
**مشکل:** اگر شبکه‌ی آروان ۲ بار متوالی نوسان داشت (که ممکن است)، tunnel سالم به اشتباه pause می‌شود.

**راه‌حل:** قبل از pause کردن، یک fallback test:
- اگر یک tunnel شکست خورد، یک tunnel **دیگر** را تست کن
- اگر همه شکست خوردند → احتمالاً مشکل شبکه است، pause نکن
- اگر فقط این tunnel شکست خورد → pause کن

**تخمین:** ۱ ساعت
**اولویت:** بعد از مشاهده‌ی false-positive

---

### TD-008: Log rotation
**مشکل:** فایل‌های `logs/access-NAME.log` و `logs/error-NAME.log` نامحدود رشد می‌کنند.

**راه‌حل:** اضافه کردن یک `/etc/logrotate.d/tunnel-mgr`:
```
/home/ubuntu/v2ray/logs/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    copytruncate
}
```

**تخمین:** ۱۰ دقیقه
**اولویت:** قبل از long-term production

---

## 🔵 P3 — بهبود تجربه

### TD-009: TUI واقعی با textual
**مشکل:** menu فعلی bash-based است، refresh نمی‌شود.

**راه‌حل:** TUI با Python `textual`:
- Status real-time
- Click tunnels برای جزئیات
- Live charts (bandwidth)

**تخمین:** ۱-۲ روز
**اولویت:** خیلی پایین — bash menu کافی است

---

### TD-010: فروشندگان مختلف format های مختلف
**مشکل:** برخی فروشندگان `subscription URL` می‌دهند که list ای از کانفیگ‌ها است.

**راه‌حل:** parser برای subscription URLs:
```bash
sudo tunnel-mgr add-subscription https://provider.com/sub/abc123
# → automatically creates multiple tunnels: provider-1, provider-2, ...
```

**تخمین:** ۲-۳ ساعت
**اولویت:** وقتی فروشنده‌ای با subscription بیابیم

---

## ✅ Resolved (تاریخچه)

### TD-DONE-001: کانفیگ‌های VLESS بدون Iran routing rules
**مشکل:** کانفیگ‌های فروشندگان rule های ایرانی نداشتند، باعث می‌شد همه ترافیک از tunnel برود حتی برای ZarinPal.

**حل شد در:** v1.0.0 — `enrich_json_config()` خودکار rule ها را اضافه می‌کند.

### TD-DONE-002: Plain OpenVPN/WireGuard در ایران DPI block است
**یافته:** Apr 29, 2026 — تست‌های ما نشان داد plain WG (port 22720) و plain OVPN (port 1194) توسط GFW ایران شناسایی و reset می‌شوند.

**نتیجه:** فقط V2Ray/Xray با camouflage (WS+host fronting، یا TCP+HTTP fake) استفاده می‌کنیم.

### TD-DONE-003: ArvanCloud bucket از خارج کند است
**یافته:** Apr 29, 2026 — آپلود از DO NYC به Arvan Tehran ~۲۰-۴۰ KB/s.

**نتیجه:** Iran VPS مستقیم به Arvan bucket دسترسی دارد، **هیچ‌گاه** از خارج آپلود نمی‌کنیم.

---

## 📊 Metrics برای ردیابی

این‌ها را وقتی production می‌رویم باید log کنیم:

| Metric | Source | Goal |
|---|---|---|
| Tunnel uptime % | health.log | >99% per tunnel |
| Average request latency | per service | <2s for Gemini |
| Pool fallback rate | HAProxy stats | <5% |
| Quota utilization | manual + future automation | <80% |
| False-positive pause | manual review | <1/week |

---

## 🤝 Contributing to this file

وقتی یک bug یا limitation جدید پیدا کردی:

```markdown
### TD-XXX: عنوان کوتاه
**مشکل:** توضیح مشکل
**تأثیر:** چه کسی متأثر می‌شود
**راه‌حل:** پیشنهاد
**تخمین:** زمان
**اولویت:** P1/P2/P3
```

ID بعدی را با `grep -c "^### TD-" TECH_DEBT.md` پیدا کن.