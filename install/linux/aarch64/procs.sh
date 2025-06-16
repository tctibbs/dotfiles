#!/usr/bin/env bash
set -euo pipefail

VERSION="0.14.10"
FILE="procs-v${VERSION}-aarch64-linux.zip"
TMPDIR="$(mktemp -d)"

# Skip if already installed
if command -v procs &>/dev/null; then
    echo "✅ procs is already installed"
    exit 0
fi

echo "📦 Downloading: $FILE"
curl -fsSL -o "$TMPDIR/$FILE" "https://github.com/dalance/procs/releases/download/v${VERSION}/${FILE}"

echo "📂 Extracting to: $TMPDIR"
unzip -q "$TMPDIR/$FILE" -d "$TMPDIR"

PROCS_BIN=$(find "$TMPDIR" -type f -name procs -perm /111 -print -quit)
if [[ -z "$PROCS_BIN" ]]; then
    echo "❌ Failed to find the procs binary"
    exit 1
fi

echo "🚀 Installing procs from $PROCS_BIN"
sudo install -m 755 "$PROCS_BIN" /usr/local/bin/procs

rm -rf "$TMPDIR"

echo "✅ procs installed:"
procs --version
