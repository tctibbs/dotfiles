#!/usr/bin/env bash
set -euo pipefail

# Skip if already installed
if command -v btop &>/dev/null; then
    echo "✅ btop is already installed"
    exit 0
fi

echo "📦 Installing btop via apt..."
sudo apt update
sudo apt install -y btop

echo "✅ btop installed:"
btop --version
