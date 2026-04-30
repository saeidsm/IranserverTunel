# Architecture

## Overview

```
       Iranian VPS

       ┌─────────────────────────────────┐
       │  Your Application                │
       │  (HTTP_PROXY=socks5h://...)      │
       └──────────────┬───────────────────┘
                      │
                      ▼
       ┌─────────────────────────────────┐
       │  HAProxy (127.0.0.1:1080)       │
       │  Round-robin load balancer       │
       └──┬─────────┬─────────┬──────────┘
          │         │         │
          ▼         ▼         ▼
       ┌────┐    ┌────┐    ┌────┐
       │xray│    │xray│    │xray│   (one per tunnel)
       │ A  │    │ B  │    │ C  │
       └─┬──┘    └─┬──┘    └─┬──┘
         │         │         │
         └─────────┴─────────┘
                   │
        ┌──────────┴──────────┐
        │  Routing rules:      │
        │  - .ir → DIRECT      │
        │  - geoip:ir → DIRECT │
        │  - rest → tunnel     │
        └──────────┬──────────┘
                   │
              ┌────┴────┐
              ▼         ▼
        Iranian      International
        services     services
        (direct)     (via tunnel)
```

## Components

### HAProxy
- Listens on `127.0.0.1:1080` for SOCKS5 traffic
- Round-robins across qualified tunnels
- Health checks each tunnel via TCP
- Stats UI on `127.0.0.1:8404`

### Xray instances
- One systemd service per tunnel (`xray-NAME.service`)
- Each listens on a unique localhost port (`10810+`)
- Each has its own routing rules (Iranian → direct, rest → proxy)

### State management
- JSON state file at `/home/ubuntu/v2ray/state/tunnels.json`
- Tracks: capabilities, last check time, pause state, qualification status

### Cron jobs
- `*/15 * * * *` — quick health check (TCP reachability)
- `30 */6 * * *` — deep test (real API calls)

## Failure modes & recovery

### A tunnel fails 2 consecutive quick checks
→ Auto-paused for 2 hours, removed from HAProxy pool

### After 2 hours
→ Auto-resumed, will be tested again at next health cycle

### A tunnel passes basic checks but fails deep tests
→ Marked `not qualified`, removed from HAProxy pool until next deep test passes

### HAProxy pool is empty
→ Application gets connection refused on `127.0.0.1:1080`
→ Manual intervention needed

## NO_PROXY limitations (important for Python)

Python's `aiohttp` does NOT respect `NO_PROXY` environment variable by default. If you're using `aiohttp` with `HTTPS_PROXY=socks5h://...`, ALL requests will go through the tunnel — including Iranian services that should bypass.

### Solution 1: Use a wrapper

```python
from urllib.parse import urlparse
import aiohttp_socks

DIRECT_HOSTS = {
    "shaparak.ir", "zarinpal.com", "bale.ai",
    "arvanstorage.ir", "arvancloud.ir",
}

def needs_proxy(url: str) -> bool:
    host = urlparse(url).hostname or ""
    if host.endswith(".ir"):
        return False
    for h in DIRECT_HOSTS:
        if host == h or host.endswith(f".{h}"):
            return False
    return True

async def make_request(url, **kwargs):
    if needs_proxy(url):
        kwargs["proxy"] = "socks5h://127.0.0.1:1080"
    # ... use the right connector
```

### Solution 2: Use `requests` (sync)

The `requests` library DOES respect `NO_PROXY`. If you can use sync calls, this is simpler.

### Solution 3: aiohttp-socks library

```python
from aiohttp_socks import ProxyConnector
# Has better NO_PROXY-like behavior via custom routing
```
