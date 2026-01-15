#!/bin/bash
# WezTerm Installation Script
# ===========================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/wezterm"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}Setting up WezTerm configuration...${NC}"
echo ""

# Install WezTerm if not present
if ! command -v wezterm &>/dev/null; then
    echo -e "${YELLOW}WezTerm is not installed. Installing...${NC}"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &>/dev/null; then
            brew install --cask wezterm
        else
            echo -e "${RED}Homebrew not found. Please install WezTerm manually from https://wezfurlong.org/wezterm/${NC}"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v flatpak &>/dev/null; then
            echo "Installing via Flatpak (user installation, no sudo required)..."
            flatpak install --user -y flathub org.wezfurlong.wezterm
        else
            echo -e "${YELLOW}WezTerm installation requires either Flatpak or manual installation.${NC}"
            echo ""
            echo "Option 1: Install Flatpak, then run this script again:"
            echo "  sudo apt install -y flatpak"
            echo ""
            echo "Option 2: Install WezTerm via apt (requires sudo):"
            echo "  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg"
            echo "  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list"
            echo "  sudo apt update && sudo apt install -y wezterm"
            echo ""
            echo -e "${YELLOW}Continuing with configuration setup...${NC}"
        fi
    elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]]; then
        echo -e "${YELLOW}On Windows, please install WezTerm from: https://wezfurlong.org/wezterm/install/windows.html${NC}"
        echo "Then re-run this script to configure."
        exit 1
    fi

    echo -e "${GREEN}WezTerm installed${NC}"
else
    echo -e "${GREEN}WezTerm is already installed${NC}"
fi

# Create config directory
mkdir -p "$CONFIG_DIR"

# Clean up old config location if it was a symlink
if [ -L "$HOME/.wezterm.lua" ]; then
    rm "$HOME/.wezterm.lua"
    echo -e "  ${YELLOW}Removed old symlink at ~/.wezterm.lua${NC}"
elif [ -f "$HOME/.wezterm.lua" ]; then
    mv "$HOME/.wezterm.lua" "$HOME/.wezterm.lua.backup"
    echo -e "  ${YELLOW}Backed up existing ~/.wezterm.lua${NC}"
fi

# Symlink all configuration files
echo "Creating symlinks to WezTerm configuration..."

# Main config (renamed from .wezterm.lua to wezterm.lua)
ln -sf "$SCRIPT_DIR/.wezterm.lua" "$CONFIG_DIR/wezterm.lua"
echo -e "  ${GREEN}Linked wezterm.lua${NC}"

# Module files
for module in theme platform keys; do
    if [ -f "$SCRIPT_DIR/${module}.lua" ]; then
        ln -sf "$SCRIPT_DIR/${module}.lua" "$CONFIG_DIR/${module}.lua"
        echo -e "  ${GREEN}Linked ${module}.lua${NC}"
    fi
done

echo ""
echo -e "${GREEN}WezTerm configuration installed to ~/.config/wezterm/${NC}"
echo ""
echo "Features enabled:"
echo "  - Catppuccin Mocha theme"
echo "  - FiraCode Nerd Font with ligatures"
echo "  - Kitty graphics protocol for images"
echo "  - WebGPU rendering"
echo "  - Cross-platform support (macOS/Linux/Windows)"
echo "  - Platform-aware keybindings"
echo ""
echo "Keybindings:"
echo "  - Cmd/Ctrl+T: New tab"
echo "  - Cmd/Ctrl+W: Close tab"
echo "  - Cmd/Ctrl+Shift+R: Rename tab"
echo "  - Ctrl+Shift+|: Split horizontal"
echo "  - Ctrl+Shift+_: Split vertical"
echo "  - Ctrl+Shift+P: Shell picker"
echo ""
