#!/usr/bin/env bash
set -euo pipefail

# delta - A syntax-highlighting pager for git
# https://github.com/dandavison/delta

if command -v delta &>/dev/null; then
    echo "delta is already installed"
    exit 0
fi

echo "Installing delta..."

if command -v brew &>/dev/null; then
    brew install git-delta
else
    echo "Homebrew not found. Please install delta manually."
    exit 1
fi

echo "delta installed"
