#!/usr/bin/env bash
set -euo pipefail

VERSION="0.24.3"
FILE="lazydocker_${VERSION}_Linux_arm64.tar.gz"

if command -v lazydocker &>/dev/null; then
    echo "lazydocker is already installed"
    exit 0
fi

TMPDIR="$(mktemp -d)"
echo "Downloading: $FILE"
curl -fsSL -o "$TMPDIR/$FILE" "https://github.com/jesseduffield/lazydocker/releases/download/v${VERSION}/${FILE}"

if ! file "$TMPDIR/$FILE" | grep -q 'gzip compressed data'; then
    echo "Invalid gzip archive"
    cat "$TMPDIR/$FILE"
    rm -rf "$TMPDIR"
    exit 1
fi

echo "Extracting to: $TMPDIR"
tar -xzf "$TMPDIR/$FILE" -C "$TMPDIR"

BIN=$(find "$TMPDIR" -type f -name lazydocker -perm /111 -print -quit)
if [[ -z "$BIN" ]]; then
    echo "Failed to find lazydocker binary"
    rm -rf "$TMPDIR"
    exit 1
fi

echo "Installing lazydocker"
sudo install -m 755 "$BIN" /usr/local/bin/lazydocker

rm -rf "$TMPDIR"

echo "lazydocker installed:"
lazydocker --version
