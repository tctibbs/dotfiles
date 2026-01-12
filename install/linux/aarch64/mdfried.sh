#!/usr/bin/env bash
set -euo pipefail

# mdfried - Terminal markdown viewer with inline images
# https://github.com/benjajaja/mdfried

if command -v mdfried &>/dev/null; then
    echo "mdfried is already installed"
    exit 0
fi

echo "Installing mdfried..."

# Check for cargo (Rust toolchain)
if ! command -v cargo &>/dev/null; then
    echo "Rust toolchain not found. Installing via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

cargo install mdfried

echo "mdfried installed"
