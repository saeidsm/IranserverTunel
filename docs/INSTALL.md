# Installation Guide

## Requirements

- Ubuntu 22.04+ (tested on Ubuntu 24.04)
- root/sudo access
- At least one V2Ray/Xray tunnel subscription (VLESS URL or JSON config)

## Step 1: Install Xray-core

```bash
sudo bash scripts/install-xray.sh
```

This installs Xray-core to `/usr/local/bin/xray` and the geoip/geosite data files.

## Step 2: Install tunnel-mgr

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/IranserverTunel.git
cd IranserverTunel

# Install
sudo cp tunnel-mgr /usr/local/bin/
sudo chmod +x /usr/local/bin/tunnel-mgr
```

## Step 3: First-time setup

```bash
sudo tunnel-mgr setup
```

This will:
- Install HAProxy, jq, bc, curl
- Initialize state files in `/home/ubuntu/v2ray/`
- Configure HAProxy to listen on `127.0.0.1:1080`
- Install cron jobs for automated health checks

## Step 4: Set up API keys (optional, for deep tests)

If you want deep tests to verify Gemini/FLUX/ElevenLabs work through each tunnel, create a keys file:

```bash
cat > /home/ubuntu/.api_keys <<EOF
export GEMINI_KEY="your_key_here"
export BFL_KEY="your_key_here"
export EL_KEY="your_key_here"
EOF
chmod 600 /home/ubuntu/.api_keys
```

⚠️ Never commit this file to git. It's already excluded by `.gitignore` if placed in this directory.

## Step 5: Add your first tunnel

```bash
sudo tunnel-mgr add
```

You'll be prompted for:
- Tunnel name (e.g., `mytunnel`)
- Method: VLESS URL, JSON file, or paste JSON

## Step 6: Verify

```bash
sudo tunnel-mgr status
```

You should see your tunnel in the pool with status `ready` (after deep test) or `degraded` (if some services don't work).

## Step 7: Connect your application

Set environment variables in your application:

```bash
HTTP_PROXY=socks5h://127.0.0.1:1080
HTTPS_PROXY=socks5h://127.0.0.1:1080
NO_PROXY=localhost,127.0.0.1,*.ir,*.arvanstorage.ir,*.zarinpal.com
```

For Python aiohttp, see notes in [docs/ARCHITECTURE.md](ARCHITECTURE.md) about NO_PROXY limitations.

## Uninstall

```bash
# Stop all xray services
for svc in /etc/systemd/system/xray-*.service; do
    name=$(basename "$svc" .service | sed 's/^xray-//')
    sudo systemctl stop "xray-$name"
    sudo systemctl disable "xray-$name"
done
sudo rm /etc/systemd/system/xray-*.service
sudo systemctl daemon-reload

# Restore HAProxy
sudo cp /home/ubuntu/v2ray/state/haproxy.cfg.original /etc/haproxy/haproxy.cfg
sudo systemctl restart haproxy

# Remove cron
sudo rm /etc/cron.d/tunnel-mgr

# Remove data (optional)
sudo rm -rf /home/ubuntu/v2ray
sudo rm /usr/local/bin/tunnel-mgr
```
