#!/usr/bin/env bash
set -euo pipefail

# difftastic - A structural diff tool that understands syntax
# https://github.com/Wilfred/difftastic

if command -v difft &>/dev/null; then
    echo "difftastic is already installed"
    exit 0
fi

echo "Installing difftastic..."

if command -v brew &>/dev/null; then
    brew install difftastic
else
    echo "Homebrew not found. Please install difftastic manually."
    exit 1
fi

echo "difftastic installed"
