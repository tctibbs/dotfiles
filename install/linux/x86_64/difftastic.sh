#!/usr/bin/env bash
set -euo pipefail

# difftastic - A structural diff tool that understands syntax
# https://github.com/Wilfred/difftastic

if command -v difft &>/dev/null; then
    echo "difftastic is already installed"
    exit 0
fi

echo "Installing difftastic..."

# Try cargo first (most reliable cross-platform)
if command -v cargo &>/dev/null; then
    cargo install difftastic
# Try apt (Debian/Ubuntu) - may not be available in all repos
elif command -v apt &>/dev/null; then
    sudo apt update
    sudo apt install -y difftastic || {
        echo "difftastic not in apt repos. Installing via cargo..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        cargo install difftastic
    }
# Try dnf (Fedora)
elif command -v dnf &>/dev/null; then
    sudo dnf install -y difftastic || {
        echo "difftastic not in dnf repos. Installing via cargo..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        cargo install difftastic
    }
else
    echo "No supported package manager found. Install cargo or difftastic manually."
    exit 1
fi

echo "difftastic installed"
