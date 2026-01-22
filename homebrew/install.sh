#!/bin/bash
# Homebrew Bundle Installation Script
# ====================================
# Installs packages from Brewfile (macOS only)
#
# Usage:
#   ./install.sh         # Full install (with GUI apps)
#   ./install.sh full    # Full install (with GUI apps)
#   ./install.sh lite    # CLI tools only (no GUI apps/fonts)

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
PROFILE="${1:-full}"

# Select Brewfile based on profile
if [[ "$PROFILE" == "lite" ]]; then
    BREWFILE="$SCRIPT_DIR/Brewfile.lite"
    echo -e "${BLUE}Installing Homebrew packages (lite - CLI only)...${NC}"
else
    BREWFILE="$SCRIPT_DIR/Brewfile"
    echo -e "${BLUE}Installing Homebrew packages (full - with GUI apps)...${NC}"
fi

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
echo "Running brew bundle with $BREWFILE..."
brew bundle --file="$BREWFILE"

echo ""
echo -e "${GREEN}Homebrew packages installed!${NC}"
echo ""
