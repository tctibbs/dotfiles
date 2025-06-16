#!/usr/bin/env bash
set -euo pipefail

# Skip if already installed
if command -v bat &>/dev/null; then
    echo "✅ bat is already installed"
    exit 0
fi

echo "📦 Installing bat via apt..."
sudo apt update
sudo apt install -y bat

# Handle Debian/Ubuntu naming quirk (batcat instead of bat)
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    echo "🔧 Creating 'bat' symlink for 'batcat'"
    sudo ln -s "$(command -v batcat)" /usr/local/bin/bat
fi

echo "✅ bat installed:"
bat --version
