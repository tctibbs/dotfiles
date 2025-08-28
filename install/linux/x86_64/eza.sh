#!/usr/bin/env bash
set -euo pipefail

VERSION="0.22.0"
FILE="eza_x86_64-unknown-linux-gnu.tar.gz"

# Skip if already installed
if command -v eza &>/dev/null; then
    echo "✅ eza is already installed"
    exit 0
fi

echo "📦 Downloading: $FILE"
curl -fsSL -o "$FILE" "https://github.com/eza-community/eza/releases/download/v${VERSION}/${FILE}"

if ! file "$FILE" | grep -q 'gzip compressed data'; then
    echo "❌ Invalid gzip archive"
    cat "$FILE"
    exit 1
fi

TMPDIR="$(mktemp -d)"
echo "📂 Extracting to: $TMPDIR"
tar -xzf "$FILE" -C "$TMPDIR"

EZA_BIN=$(find "$TMPDIR" -type f -name eza -perm /111 -print -quit)
if [[ -z "$EZA_BIN" ]]; then
    echo "❌ Failed to find the eza binary"
    exit 1
fi

echo "🚀 Installing eza from $EZA_BIN"
sudo install -m 755 "$EZA_BIN" /usr/local/bin/eza

rm -rf "$FILE" "$TMPDIR"

echo "✅ eza installed:"
eza --version
