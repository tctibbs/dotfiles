#!/usr/bin/env bash
set -euo pipefail

# Skip if already installed
if command -v fzf &>/dev/null; then
    echo "✅ fzf is already installed"
    exit 0
fi

echo "📦 Installing fzf..."

# Ensure ~/.fzf/bin is in PATH by writing to a clean file
if ! grep -q 'export PATH="$HOME/.fzf/bin:$PATH"' "$HOME/.zsh_env" 2>/dev/null; then
  echo 'export PATH="$HOME/.fzf/bin:$PATH"' >> "$HOME/.zsh_env"
fi
export PATH="$HOME/.fzf/bin:$PATH"

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --key-bindings --completion --no-update-rc

echo "✅ fzf installed:"
fzf --version
