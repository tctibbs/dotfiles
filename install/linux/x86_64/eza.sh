#!/usr/bin/env bash
set -euo pipefail

VERSION="0.22.0"
FILE="eza_x86_64-unknown-linux-gnu.tar.gz"

# Skip if already installed
if command -v eza &>/dev/null; then
    echo "eza is already installed"
    exit 0
fi

# Determine install location based on sudo availability
CAN_SUDO="${CAN_SUDO:-false}"
if [[ "$CAN_SUDO" != "true" ]] && command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
    CAN_SUDO="true"
fi

if [[ "$CAN_SUDO" == "true" ]]; then
    INSTALL_DIR="/usr/local/bin"
else
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
fi

echo "Downloading: $FILE"
curl -fsSL -o "$FILE" "https://github.com/eza-community/eza/releases/download/v${VERSION}/${FILE}"

if ! file "$FILE" | grep -q 'gzip compressed data'; then
    echo "Invalid gzip archive"
    cat "$FILE"
    exit 1
fi

TMPDIR="$(mktemp -d)"
echo "Extracting to: $TMPDIR"
tar -xzf "$FILE" -C "$TMPDIR"

EZA_BIN=$(find "$TMPDIR" -type f -name eza -perm /111 -print -quit)
if [[ -z "$EZA_BIN" ]]; then
    echo "Failed to find the eza binary"
    exit 1
fi

echo "Installing eza to $INSTALL_DIR"
if [[ "$CAN_SUDO" == "true" ]]; then
    sudo install -m 755 "$EZA_BIN" "$INSTALL_DIR/eza"
else
    install -m 755 "$EZA_BIN" "$INSTALL_DIR/eza"
fi

rm -rf "$FILE" "$TMPDIR"

echo "eza installed:"
eza --version
