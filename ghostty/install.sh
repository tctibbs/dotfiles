#!/bin/bash
# Symlink Ghostty config

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/ghostty"

mkdir -p "$CONFIG_DIR"
ln -sf "$SCRIPT_DIR/config" "$CONFIG_DIR/config"

echo "Ghostty config linked"
