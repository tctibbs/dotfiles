#!/bin/bash
# Fastfetch Configuration Setup
# ==============================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/fastfetch"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}Setting up Fastfetch configuration...${NC}"
echo ""

# Create config directory
mkdir -p "$CONFIG_DIR"

# Symlink config file
if [ -f "$CONFIG_DIR/config.jsonc" ] && [ ! -L "$CONFIG_DIR/config.jsonc" ]; then
    mv "$CONFIG_DIR/config.jsonc" "$CONFIG_DIR/config.jsonc.backup"
    echo -e "  ${YELLOW}Backed up existing config.jsonc${NC}"
fi

ln -sf "$SCRIPT_DIR/config.jsonc" "$CONFIG_DIR/config.jsonc"
echo -e "  ${GREEN}Linked config.jsonc${NC}"

echo ""
echo -e "${GREEN}Fastfetch configuration installed to ~/.config/fastfetch/${NC}"
echo ""
echo "Run 'fastfetch' to see your system info"
echo ""
