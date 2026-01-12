#!/bin/bash
# WezTerm Installation Script
# ===========================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "Setting up WezTerm configuration..."
echo ""

# Install WezTerm if not present
if ! command -v wezterm &>/dev/null; then
    echo "WezTerm is not installed. Installing..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &>/dev/null; then
            brew install --cask wezterm
        else
            echo "Homebrew not found. Please install WezTerm manually from https://wezfurlong.org/wezterm/"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v flatpak &>/dev/null; then
            echo "Installing via Flatpak..."
            flatpak install -y flathub org.wezfurlong.wezterm
        elif command -v apt &>/dev/null; then
            echo "Installing via apt..."
            curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
            echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
            sudo apt update
            sudo apt install -y wezterm
        else
            echo "No supported package manager found. Please install WezTerm manually."
            exit 1
        fi
    fi

    echo "WezTerm installed"
else
    echo "WezTerm is already installed"
fi

# Symlink configuration
echo "Creating symlink to WezTerm configuration..."

if [ -f "$HOME/.wezterm.lua" ] && [ ! -L "$HOME/.wezterm.lua" ]; then
    echo "  Backing up existing .wezterm.lua"
    mv "$HOME/.wezterm.lua" "$HOME/.wezterm.lua.backup"
fi

ln -sf "$SCRIPT_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
echo "  Linked .wezterm.lua"

echo ""
echo "WezTerm configuration installed"
echo ""
echo "Features enabled:"
echo "  - Catppuccin Mocha theme"
echo "  - FiraCode Nerd Font with ligatures"
echo "  - Kitty graphics protocol for images"
echo "  - Tmux passthrough for inline images"
echo "  - WebGPU rendering"
echo ""
