#!/usr/bin/env bash
# Architecture: x86_64 – 64-bit AMD/Intel (Linux GNU)
set -euo pipefail

VERSION="1.2.2"
FILE="dust-v${VERSION}-x86_64-unknown-linux-gnu.tar.gz"
TMPDIR="$(mktemp -d)"

# Skip if already installed
if command -v dust &>/dev/null; then
    echo "✅ dust is already installed"
    exit 0
fi

echo "📦 Downloading: $FILE"
curl -fsSL -o "$TMPDIR/$FILE" "https://github.com/bootandy/dust/releases/download/v${VERSION}/${FILE}"

echo "📂 Extracting to: $TMPDIR"
tar -xzf "$TMPDIR/$FILE" -C "$TMPDIR"

# Find the binary
DUST_BIN=$(find "$TMPDIR" -type f -name dust -perm /111 -print -quit)
if [[ -z "$DUST_BIN" ]]; then
    echo "❌ Failed to find the dust binary"
    exit 1
fi

echo "🚀 Installing dust from $DUST_BIN"
sudo install -m 755 "$DUST_BIN" /usr/local/bin/dust

rm -rf "$TMPDIR"

echo "✅ dust installed:"
dust --version
