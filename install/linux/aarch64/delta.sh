#!/usr/bin/env bash
set -euo pipefail

# delta - A syntax-highlighting pager for git
# https://github.com/dandavison/delta

if command -v delta &>/dev/null; then
    echo "delta is already installed"
    exit 0
fi

echo "Installing delta..."

# Try cargo first (most reliable cross-platform)
if command -v cargo &>/dev/null; then
    cargo install git-delta
# Try apt (Debian/Ubuntu)
elif command -v apt &>/dev/null; then
    # delta package name varies by distro
    sudo apt update
    sudo apt install -y git-delta || sudo apt install -y delta
# Try dnf (Fedora)
elif command -v dnf &>/dev/null; then
    sudo dnf install -y git-delta
else
    echo "No supported package manager found. Install cargo or delta manually."
    exit 1
fi

echo "delta installed"
