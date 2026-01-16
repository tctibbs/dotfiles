#!/usr/bin/env bash
set -euo pipefail

if command -v dops &>/dev/null; then
    echo "dops is already installed"
    exit 0
fi

TMPDIR="$(mktemp -d)"
echo "Downloading: dops_linux-amd64-static"
curl -fsSL -o "$TMPDIR/dops" "https://github.com/Mikescher/better-docker-ps/releases/latest/download/dops_linux-amd64-static"

if ! file "$TMPDIR/dops" | grep -q 'ELF'; then
    echo "Invalid binary"
    rm -rf "$TMPDIR"
    exit 1
fi

echo "Installing dops"
sudo install -m 755 "$TMPDIR/dops" /usr/local/bin/dops

rm -rf "$TMPDIR"

echo "dops installed:"
dops --version
