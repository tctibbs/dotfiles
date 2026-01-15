#!/bin/bash
# Starship Prompt Installation Script
# ====================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}Setting up Starship prompt...${NC}"
echo ""

# Install Starship if not present
if ! command -v starship &>/dev/null; then
    echo -e "${YELLOW}Starship not found. Installing...${NC}"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &>/dev/null; then
            brew install starship
        else
            echo -e "${YELLOW}Homebrew not found, using curl installer...${NC}"
            curl -sS https://starship.rs/install.sh | sh -s -- -y
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]]; then
        # Windows (Git Bash/MSYS2)
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        echo -e "${RED}Unsupported OS. Please install Starship manually.${NC}"
        echo "Visit: https://starship.rs/guide/#installation"
        exit 1
    fi

    echo -e "${GREEN}Starship installed${NC}"
else
    echo -e "${GREEN}Starship is already installed${NC}"
fi

# Create config directory if needed
mkdir -p "$HOME/.config"

# Symlink configuration
echo "Creating symlink to Starship configuration..."

if [ -f "$HOME/.config/starship.toml" ] && [ ! -L "$HOME/.config/starship.toml" ]; then
    echo -e "  ${YELLOW}Backing up existing starship.toml${NC}"
    mv "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.backup"
fi

ln -sf "$SCRIPT_DIR/starship.toml" "$HOME/.config/starship.toml"
echo -e "  ${GREEN}Linked starship.toml${NC}"

echo ""
echo -e "${GREEN}Starship configuration installed${NC}"
echo ""
echo "Features enabled:"
echo "  - Nord color palette"
echo "  - Two-line prompt with git info"
echo "  - Language version indicators"
echo "  - AWS and Docker context"
echo "  - Command duration tracking"
echo ""
echo -e "${YELLOW}Note: Add this to your shell rc file if not already present:${NC}"
echo '  eval "$(starship init zsh)"'
echo ""
