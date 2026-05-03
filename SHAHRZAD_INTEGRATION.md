# Shahrzad Integration Guide

این فایل تغییرات لازم در codebase **shahrzad** را track می‌کند تا با IranserverTunel و در کل با multi-region deployment یکپارچه شود.

**مهم:** ما **یک codebase** داریم. همه‌ی این تغییرات باید با feature flags باشند تا یک‌جا برای همه deployment ها (Iran, Foreign, US, EU,...) کار کند.

---

## 🎯 اصول طراحی

1. **یک repo، چند deployment** — هرگز fork نمی‌کنیم
2. **Feature flags بجای branch ها** — هر تفاوت با env یا DB setting کنترل می‌شود
3. **Defaults برای production فعلی (DO خارج)** — تغییرات نباید رفتار فعلی را break کند
4. **Iran deployment = additive** — اضافه می‌کند، چیزی برنمی‌دارد

---

## 📋 فهرست تغییرات لازم

### 🔧 INT-001: Region-aware deployment config
**نیاز:** یک env var که بگوید "این deployment کجاست":

```bash
# .env
DEPLOYMENT_REGION=foreign     # default for current DO
# DEPLOYMENT_REGION=iran      # for Arvan VPS
# DEPLOYMENT_REGION=eu        # future
```

**تأثیر:** بر اساس این، feature flags پیش‌فرض تنظیم می‌شوند.

**فایل‌های متأثر:**
- `backend/core/config.py` — اضافه کردن `DEPLOYMENT_REGION`
- `backend/services/feature_flags.py` (جدید) — region-based defaults
- `docker-compose.yml` — اضافه کردن env

**تخمین:** ۱ روز

---

### 🔧 INT-002: Domain configuration per deployment
**نیاز:** هر deployment باید دامنه‌ی خودش را بداند برای:
- CORS origins
- Email templates (لینک‌های verification)
- ZarinPal callback URL
- Stripe webhook URL
- OAuth redirect URI ها
- Telegram bot URL

**مثال:**
```bash
# Foreign (current)
APP_DOMAIN=shahrzad.ai
APP_BASE_URL=https://shahrzad.ai

# Iran
APP_DOMAIN=shahrzadai.ir
APP_BASE_URL=https://shahrzadai.ir
```

**فایل‌های متأثر:**
- `backend/core/config.py`
- `backend/services/email_service.py` (URL builder)
- `backend/api/payment.py` (callback URLs)
- `frontend/next.config.js` (CORS, public URL)

**تخمین:** ۱ روز
**اولویت:** P1 (بدون این، Iran deploy نمی‌شود)

---

### 🔧 INT-003: AI services proxy support (TUNNEL_PROXY)
**نیاز:** یک env var برای proxy AI calls:

```bash
# Foreign (no proxy)
TUNNEL_PROXY=

# Iran (HAProxy entry)
TUNNEL_PROXY=socks5h://host.docker.internal:1080
```

**در کد، یک wrapper:**
```python
# backend/core/http_client.py (جدید)
import os
import aiohttp
from aiohttp_socks import ProxyConnector
from urllib.parse import urlparse

DIRECT_HOSTS = set()
DIRECT_SUFFIXES = set()

def _load_direct_hosts():
    """خواندن /home/ubuntu/v2ray/data/iran-direct-hosts.txt یا env"""
    # ...

def needs_proxy(url: str) -> bool:
    """آیا این URL باید از proxy برود؟"""
    if not os.getenv('TUNNEL_PROXY'):
        return False
    host = urlparse(url).hostname or ""
    if host in DIRECT_HOSTS:
        return False
    for suffix in DIRECT_SUFFIXES:
        if host.endswith(suffix):
            return False
    return True

async def get_session(url: str = None) -> aiohttp.ClientSession:
    """Session مناسب برای URL برمی‌گرداند"""
    proxy = os.getenv('TUNNEL_PROXY')
    if proxy and url and needs_proxy(url):
        connector = ProxyConnector.from_url(proxy)
        return aiohttp.ClientSession(connector=connector)
    return aiohttp.ClientSession()
```

**فایل‌های متأثر:**
- `backend/core/http_client.py` (جدید)
- `backend/services/story_engine.py` (Gemini)
- `backend/services/image_service.py` (FLUX)
- `backend/services/voice_service.py` (ElevenLabs)
- `backend/services/sentry_client.py` (اگر داریم)
- `requirements.txt` — اضافه کردن `aiohttp-socks`

**تست:** end-to-end story generation از Iran VPS با proxy فعال

**تخمین:** ۲-۳ روز
**اولویت:** P1 (core feature)

---

### 🔧 INT-004: Direct hosts file (Iran-aware NO_PROXY)
**نیاز:** فایل `data/iran-direct-hosts.txt` در shahrzad repo که از IranserverTunel کپی شود (با sync mechanism).

**یا:** یک endpoint `/api/internal/direct-hosts` که tunnel-mgr بسازد و backend بخواند.

**انتخاب پیشنهادی:** **کپی فایل**. ساده، static، در deploy time set می‌شود.

```bash
# در Iran deployment، یک sync script
cp /home/ubuntu/v2ray/data/iran-direct-hosts.txt \
   /root/ZigguratKids4/backend/data/direct-hosts.txt
```

**فایل‌های متأثر:**
- `backend/data/direct-hosts.txt` (جدید)
- `backend/core/http_client.py` (می‌خواند از این فایل)

**تخمین:** ۲-۳ ساعت
**اولویت:** P1

---

### 🔧 INT-005: Payment provider feature flags
**نیاز:** هر deployment باید بتواند provider های خاصی را فعال/غیرفعال کند:

```bash
# Foreign
PAYMENT_PROVIDERS=stripe,paypal

# Iran
PAYMENT_PROVIDERS=zarinpal
```

**در کد:**
```python
# backend/services/payment_service.py
ENABLED_PROVIDERS = os.getenv('PAYMENT_PROVIDERS', 'stripe').split(',')

@router.post("/payment/initiate")
async def initiate(provider: str, ...):
    if provider not in ENABLED_PROVIDERS:
        raise HTTPException(403, f"{provider} not enabled in this region")
    ...
```

**Frontend:**
```typescript
// settings از backend می‌گیرد:
const enabledProviders = await api.get('/api/config/payment-providers');
// Stripe button فقط اگر در لیست بود نمایش داده شود
```

**فایل‌های متأثر:**
- `backend/api/payment.py`
- `backend/api/config.py` (endpoint جدید برای frontend)
- `frontend/components/payment/*`

**تخمین:** ۱ روز
**اولویت:** P1 (بدون این، Iran deploy ZarinPal نمی‌تواند نمایش دهد)

---

### 🔧 INT-006: Messenger feature flags (Telegram vs Bale)
**نیاز:** هر deployment messenger خودش را داشته باشد:

```bash
# Foreign
MESSENGERS=telegram

# Iran
MESSENGERS=bale
```

**تأثیر:**
- در Iran، Telegram bot disabled (نه setup، نه webhook، نه polling)
- در Iran، Bale bot enabled
- در Foreign، برعکس
- ConvAI: روی Iran disabled تا Phase 2 (تو گفتی)

**فایل‌های متأثر:**
- `backend/api/telegram.py` — gate با `MESSENGERS`
- `backend/api/bale.py` (جدید) — copy از telegram pattern
- `backend/services/notification_service.py` — multi-channel
- `frontend/components/auth/messenger-login` — choose based on enabled

**نکات Bale:**
- Bale = Iranian Telegram، API مشابه
- پشتیبانی Mini Apps دارد (تأیید شده)
- پشتیبانی OTP (در حال اضافه شدن)
- لاگین: کاربر می‌تواند با Bale وارد شود

**تخمین:** ۳-۴ روز (Bale از scratch)
**اولویت:** P2 (می‌توانیم اول بدون Bale لانچ کنیم با ZarinPal+ایمیل)

---

### 🔧 INT-007: Language feature flags
**نیاز:** برای سبکی frontend per-region:

```bash
# Foreign
ENABLED_LANGUAGES=en,fa,es,ar

# Iran
ENABLED_LANGUAGES=fa,en
```

**تأثیر frontend:**
- Bundle splitting: فقط locale های فعال load شوند
- Language switcher: فقط فعال‌ها نمایش داده شوند
- SEO: فقط فعال‌ها index شوند

**تخمین:** ۲-۳ روز
**اولویت:** P3 (optimization)

---

### 🔧 INT-008: Storage backend per region
**نیاز:** هر deployment storage خودش را داشته باشد:

```bash
# Foreign (DigitalOcean Spaces)
S3_ENDPOINT=https://nyc3.digitaloceanspaces.com
S3_BUCKET=shahrzad-media

# Iran (ArvanCloud)
S3_ENDPOINT=https://s3.ir-thr-at1.arvanstorage.ir
S3_BUCKET=shahrzad-iran-media
```

**خوبی:** کد فعلی `s3_storage.py` با aioboto3 است → هر دو endpoint کار می‌کنند بدون تغییر کد.

**تنها تغییر:** اطمینان از **media URL ها** که در DB ذخیره می‌شوند، **مطلق** هستند نه نسبی:
```python
# bad
file_url = f"/media/{key}"

# good
file_url = f"{S3_PUBLIC_URL}/{key}"
# Foreign: https://media.shahrzad.ai/...
# Iran: https://media.shahrzadai.ir/... (Cloudflare Worker → ArvanCloud)
```

**فایل‌های متأثر:**
- `backend/services/s3_storage.py`
- `backend/core/config.py`
- Migration script برای URL های موجود (فقط Foreign، چون Iran tabula rasa شروع می‌کند)

**تخمین:** ۱-۲ روز
**اولویت:** P1

---

### 🔧 INT-009: Email provider per region
**نیاز:** Resend در ایران از خارج می‌آید. ممکن است نیاز به provider ایرانی باشد:

```bash
# Foreign (Resend)
EMAIL_PROVIDER=resend
EMAIL_FROM=noreply@email.shahrzad.ai

# Iran (Resend via tunnel? یا alternative ایرانی?)
EMAIL_PROVIDER=resend
EMAIL_FROM=noreply@shahrzadai.ir
```

**سؤال باز:** آیا email از طریق tunnel فرستاده شود (gmail/resend) یا از یک SMTP ایرانی؟

**پیشنهاد:** فعلاً Resend از طریق tunnel. اگر برای کاربران ایرانی email های ما به spam رفت، آن‌وقت SMTP ایرانی.

**تخمین:** ۱ روز برای provider abstraction
**اولویت:** P2

---

### 🔧 INT-010: ZarinPal specific routing
**نیاز:** ZarinPal API call ها **حتماً** باید مستقیم بروند، نه از tunnel.

این به **TD-001** و **INT-003** برمی‌گردد. در `core/http_client.py` باید مطمئن شویم:

```python
DIRECT_HOSTS = {
    "api.zarinpal.com",
    "www.zarinpal.com",
    "zarinpal.com",
    # ...
}
```

**تست:** mock یک ZarinPal flow و verify کن HTTP_PROXY روی این درخواست نیست.

**تخمین:** بخشی از INT-003
**اولویت:** P1 (critical path)

---

### 🔧 INT-011: Sentry per region
**نیاز:** هر region Sentry جدای خودش را داشته باشد، تا:
- error های Iran و Foreign mix نشوند
- billing tracking ساده‌تر باشد
- privacy: error های Iran user ها به Sentry US نروند (شاید)

```bash
# Foreign
SENTRY_DSN_BACKEND=https://...@xxx.ingest.sentry.io/foreign-project
SENTRY_DSN_FRONTEND=https://...@xxx.ingest.sentry.io/foreign-frontend

# Iran
SENTRY_DSN_BACKEND=https://...@xxx.ingest.sentry.io/iran-project
SENTRY_DSN_FRONTEND=https://...@xxx.ingest.sentry.io/iran-frontend
```

**سوال:** Sentry برای Iran ممکن است بدون tunnel کار نکند. باید یا:
- (الف) از tunnel بفرستیم (طبق INT-003)
- (ب) Sentry self-hosted روی Iran VPS
- (ج) Sentry را موقتاً disable روی Iran، یا فقط console log

**پیشنهاد:** (الف) ساده‌ترین. اگر کند بود، (ج).

**تخمین:** ۱ روز
**اولویت:** P2

---

### 🔧 INT-012: Database per region
**نیاز:** هر deployment MongoDB جدا. هیچ replication بین Iran و Foreign.

**فعلی:** ✅ این از پیش است. هر docker-compose یک MongoDB دارد.

**نکته:** اگر بعداً خواستیم share کنیم (مثلاً لیست admin ها مشترک)، نیاز به یک sync mechanism داریم. ولی فعلاً نه.

**تخمین:** ۰ (already done)

---

### 🔧 INT-013: API keys per region
**نیاز:** Iran و Foreign **کلیدهای جدا** برای AI services استفاده کنند:
- Billing tracking per-region
- IP whitelisting per-region
- آسانی revoke یکی بدون تأثیر بر دیگری

```bash
# Iran .env (production)
GEMINI_KEY=AIzaSy...iran_specific
BFL_KEY=bfl_...iran_specific  
EL_KEY=sk_...iran_specific

# Foreign .env (production)
GEMINI_KEY=AIzaSy...foreign_specific
# ...
```

**در کد:** هیچ تغییر لازم نیست. هر deployment .env خودش را دارد.

**نکته‌ی عملی:** در Google Cloud / BFL / EL panels:
- نام key های Iran با suffix `-iran` 
- IP restriction روی Gemini key های Iran به IP exit servers tunnel ها

**تخمین:** ۲ ساعت ادمین کاری (ساخت کلید + restriction)
**اولویت:** P1

---

### 🔧 INT-014: Frontend region awareness
**نیاز:** Frontend باید بداند در کدام region اجرا می‌شود:
- نمایش پرچم/لگوی مناسب
- Default language (Iran → fa، Foreign → en)
- Hide/show certain features
- Different pricing display (تومان vs USD)

```typescript
// frontend/lib/region.ts
export const REGION = process.env.NEXT_PUBLIC_REGION || 'foreign';

export const isRegion = (r: string) => REGION === r;
export const isIran = () => REGION === 'iran';
```

```typescript
// component
{isIran() && <ZarinPalCheckout />}
{!isIran() && <StripeCheckout />}
```

**فایل‌های متأثر:** بسیاری از components

**تخمین:** ۲-۳ روز
**اولویت:** P2 (می‌توانیم با feature flags از backend بدون این هم لانچ کنیم)

---

### 🔧 INT-015: Cron job differences per region
**نیاز:** برخی cron job ها فقط در یک region معنی دارند:
- `daily_research_invite_cron` → فقط Iran (احتمالاً)
- `nightwatch_health_check` → DevOps DO، نه Iran/Foreign production
- `shahrzad-cleanup` → هر دو

**در کد:**
```python
# backend/workers/celery_beat.py
beat_schedule = {
    "shahrzad_cleanup": { ... },  # both
}

if DEPLOYMENT_REGION == "foreign":
    beat_schedule["research_invite"] = { ... }
    beat_schedule["stripe_subscription_renewal_check"] = { ... }

if DEPLOYMENT_REGION == "iran":
    beat_schedule["zarinpal_pending_verify_cron"] = { ... }
```

**تخمین:** ۱ روز
**اولویت:** P2

---

### 🔧 INT-016: Admin panel region awareness
**نیاز:** Admin panel فعلی همه چیز را نمایش می‌دهد. در آینده شاید بخواهیم:
- super-admin ها همه region ها را ببینند
- regional admin ها فقط region خودشان

**فعلاً ساده‌اش:** هر deployment admin panel خودش را دارد، separate. این OK است.

**تخمین:** ۰ (نسخه‌ی فعلی کافی است)
**اولویت:** P3

---

## 📐 معماری نهایی پیشنهادی

```
       ┌──────────────────────────────────────────────────┐
       │  ONE git repo: ZigguratKids4 (shahrzad)         │
       │                                                  │
       │  Feature flags from:                             │
       │  1. .env (deployment-time)                       │
       │  2. MongoDB settings (runtime, admin-toggle)     │
       │  3. data/direct-hosts.txt (Iran-specific)        │
       └────────────────┬─────────────────────────────────┘
                        │
            git pull / docker compose up
                        │
       ┌────────────────┼────────────────────────────────┐
       │                │                                │
       ▼                ▼                                ▼
   Foreign          Iran (Arvan)                     Future EU
   (DO NYC)                                          (Hetzner)
   
   .env:            .env:                            .env:
   REGION=foreign   REGION=iran                     REGION=eu
   PAYMENTS=        PAYMENTS=                       PAYMENTS=
     stripe,          zarinpal                        stripe
     paypal         MESSENGERS=                      MESSENGERS=
   MESSENGERS=        bale                            telegram
     telegram       TUNNEL_PROXY=                    TUNNEL_PROXY=
   TUNNEL_PROXY=     socks5h://...                    (none)
     (none)         APP_DOMAIN=                      APP_DOMAIN=
   APP_DOMAIN=       shahrzadai.ir                   shahrzad.eu
     shahrzad.ai    S3_ENDPOINT=                     S3_ENDPOINT=
   S3_ENDPOINT=      arvanstorage.ir                  hetzner...
     digitalocean
```

---

## 📅 پیشنهاد ترتیب اجرا

این یک **Sprint plan** است. هر کدام یک PR در shahrzad repo:

### Sprint A (Foundation, ~۱ هفته)
- [ ] **INT-001** Region-aware deployment config
- [ ] **INT-002** Domain configuration
- [ ] **INT-013** Multi-region API keys (admin task)
- [ ] **INT-012** Confirm DB-per-region (تأیید موجود بودن)

### Sprint B (Tunnel Integration, ~۱ هفته)
- [ ] **INT-003** AI services proxy support (`http_client.py`)
- [ ] **INT-004** Direct hosts file
- [ ] **INT-010** ZarinPal direct routing (در Sprint B included)
- [ ] **TD-001** aiohttp NO_PROXY workaround

### Sprint C (Region-specific Providers, ~۱ هفته)
- [ ] **INT-005** Payment provider feature flags
- [ ] **INT-008** Storage backend per region
- [ ] **INT-011** Sentry per region (decision)
- [ ] **INT-014** Frontend region awareness

### Sprint D (Iran-specific, ~۲ هفته)
- [ ] **INT-006** Bale messenger integration
- [ ] **INT-009** Email per region
- [ ] **INT-015** Cron job conditional registration

### Sprint E (Optimization, post-launch)
- [ ] **INT-007** Language feature flags
- [ ] **INT-016** Admin panel improvements

---

## 🤝 وقتی به Claude Code می‌دهیم

برای هر Sprint، یک پرامت مجزا می‌نویسیم که:
1. **scope را روشن می‌کند** (فقط این فایل‌ها)
2. **constraint های فعلی را یادآوری می‌کند** (backward compatible، یک codebase)
3. **معیار success را می‌دهد** (مثل تست‌های smoke که باید pass شوند)
4. **rollback plan دارد** (اگر مشکل شد چه)

**نکته‌ی مهم:** Claude Code باید تأیید بگیرد قبل از:
- تغییر MongoDB schema
- merge به main
- deploy روی production

---

## 📝 یادداشت‌های مهم

### نکته‌ی ۱: shahrzad فعلی production است
هر تغییر باید **non-breaking** باشد. اگر INT-003 اضافه شد، ولی `TUNNEL_PROXY=` (خالی)، باید مثل قبل کار کند.

### نکته‌ی ۲: Iran deployment fresh شروع می‌کند
- DB جدید (هیچ migration از Foreign نیست)
- کاربران جدید (با ZarinPal ثبت‌نام کنند)
- Stories جدید (هیچ history منتقل نمی‌شود)

این **انتخاب راحت** است. اگر بعداً شاتل user data بین region ها لازم شد (مثلاً مهاجرت)، یک پروژه‌ی جدا.

### نکته‌ی ۳: testing strategy
هر Sprint باید **هر دو region** را test کند:
- Foreign deployment (DO production) — هیچ تغییر رفتاری
- Iran deployment (Arvan VPS) — feature های جدید کار کنند

این یعنی یک staging Iran VPS هم نیاز داریم. **آماده شدن این infrastructure قبل از Sprint A**.

### نکته‌ی ۴: domain قبل از Sprint A
ثبت دامنه `shahrzadai.ir` (یا هر دامنه‌ی نهایی Iran) باید قبل از شروع کارها انجام شود.

---

## 🏷️ نسخه‌بندی

این فایل با هر Sprint به‌روزرسانی می‌شود. در هر تغییر، یک خط در ابتدای فایل:

```
v1.0 (Apr 30, 2026) — initial draft
v1.1 (TBD) — Sprint A complete
v1.2 (TBD) — Sprint B complete
...
```