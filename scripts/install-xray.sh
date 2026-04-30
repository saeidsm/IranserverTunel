#!/usr/bin/env bash
# install-xray.sh - Install Xray-core
# Usage: sudo bash scripts/install-xray.sh

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "❌ Run with sudo"
    exit 1
fi

echo "Installing dependencies..."
apt-get update
apt-get install -y curl unzip jq

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  XRAY_ARCH="64" ;;
    aarch64) XRAY_ARCH="arm64-v8a" ;;
    *) echo "❌ Unsupported arch: $ARCH"; exit 1 ;;
esac

echo "Detecting latest Xray release..."
LATEST_URL=$(curl -sL https://api.github.com/repos/XTLS/Xray-core/releases/latest \
    | jq -r ".assets[] | select(.name == \"Xray-linux-$XRAY_ARCH.zip\") | .browser_download_url")

if [ -z "$LATEST_URL" ] || [ "$LATEST_URL" = "null" ]; then
    echo "❌ Could not get latest release URL"
    echo "ℹ️  GitHub API may be unreachable. Try downloading manually:"
    echo "   https://github.com/XTLS/Xray-core/releases/latest"
    exit 1
fi

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

echo "Downloading: $LATEST_URL"
curl -L -o "$TMPDIR/xray.zip" "$LATEST_URL"

unzip -o "$TMPDIR/xray.zip" -d "$TMPDIR/extract"

echo "Installing..."
install -m 755 "$TMPDIR/extract/xray" /usr/local/bin/xray
mkdir -p /usr/local/share/xray
install -m 644 "$TMPDIR/extract/geoip.dat" /usr/local/share/xray/
install -m 644 "$TMPDIR/extract/geosite.dat" /usr/local/share/xray/

echo "✅ Xray installed: $(/usr/local/bin/xray version | head -1)"
echo "Geo data: /usr/local/share/xray/"
