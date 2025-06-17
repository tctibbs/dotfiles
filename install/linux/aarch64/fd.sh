#!/usr/bin/env bash
set -euo pipefail

VERSION="v10.2.0"
FILE="fd-${VERSION}-aarch64-unknown-linux-gnu.tar.gz"
TMPDIR="$(mktemp -d)"

# Skip if already installed
if command -v fd &>/dev/null; then
    echo "✅ fd is already installed"
    exit 0
fi

echo "📦 Downloading: $FILE"
curl -fsSL -o "$TMPDIR/$FILE" "https://github.com/sharkdp/fd/releases/download/${VERSION}/${FILE}"

echo "📂 Extracting to: $TMPDIR"
tar -xzf "$TMPDIR/$FILE" -C "$TMPDIR"

FD_BIN=$(find "$TMPDIR" -type f -name fd -perm /111 -print -quit)
if [[ -z "$FD_BIN" ]]; then
    echo "❌ Failed to find the fd binary"
    exit 1
fi

echo "🚀 Installing fd from $FD_BIN"
sudo install -m 755 "$FD_BIN" /usr/local/bin/fd

rm -rf "$TMPDIR"

echo "✅ fd installed:"
fd --version
