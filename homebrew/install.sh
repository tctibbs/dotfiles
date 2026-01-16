#!/bin/bash
# Homebrew Bundle Installation Script
# ====================================
# Installs all packages from Brewfile (macOS only)

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# macOS only
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${YELLOW}Brewfile is macOS only. Use platform-specific scripts for Linux.${NC}"
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "${BLUE}Installing Homebrew packages...${NC}"
echo ""

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
    echo -e "${YELLOW}Homebrew not found. Installing...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for Apple Silicon
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Run bundle
echo "Running brew bundle..."
brew bundle --file="$SCRIPT_DIR/Brewfile"

echo ""
echo -e "${GREEN}Homebrew packages installed!${NC}"
echo ""
