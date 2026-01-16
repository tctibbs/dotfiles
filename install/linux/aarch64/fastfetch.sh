#!/usr/bin/env bash
set -euo pipefail

VERSION="2.57.1"
FILE="fastfetch-linux-aarch64.tar.gz"

if command -v fastfetch &>/dev/null; then
    echo "fastfetch is already installed"
    exit 0
fi

echo "Downloading: $FILE"
curl -fsSL -o "$FILE" "https://github.com/fastfetch-cli/fastfetch/releases/download/${VERSION}/${FILE}"

if ! file "$FILE" | grep -q 'gzip compressed data'; then
    echo "Invalid gzip archive"
    cat "$FILE"
    exit 1
fi

TMPDIR="$(mktemp -d)"
echo "Extracting to: $TMPDIR"
tar -xzf "$FILE" -C "$TMPDIR"

BIN=$(find "$TMPDIR" -type f -name fastfetch -perm /111 -print -quit)
if [[ -z "$BIN" ]]; then
    echo "Failed to find fastfetch binary"
    exit 1
fi

echo "Installing fastfetch"
sudo install -m 755 "$BIN" /usr/local/bin/fastfetch

rm -rf "$FILE" "$TMPDIR"

echo "fastfetch installed:"
fastfetch --version
