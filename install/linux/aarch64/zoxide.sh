#!/usr/bin/env bash
set -euo pipefail

# Skip if already installed
if command -v zoxide &>/dev/null; then
    echo "✅ zoxide is already installed"
    exit 0
fi

echo "📦 Installing zoxide via apt..."
sudo apt update
sudo apt install -y zoxide

echo "✅ zoxide installed:"
zoxide --version
