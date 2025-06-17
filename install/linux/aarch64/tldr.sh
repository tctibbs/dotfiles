#!/usr/bin/env bash
set -euo pipefail

# Skip if already installed
if command -v tldr &>/dev/null; then
    echo "✅ tldr is already installed"
    exit 0
fi

echo "📦 Installing tldr via apt..."
sudo apt update
sudo apt install -y tldr

echo "✅ tldr installed:"
tldr --version
