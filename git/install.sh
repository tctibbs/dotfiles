#!/bin/bash

# Git Configuration Installation Script
# =====================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🔧 Setting up Git configuration...${NC}"

# Backup existing non-symlink config
if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
    echo -e "${YELLOW}  📦 Backing up existing .gitconfig${NC}"
    mv "$HOME/.gitconfig" "$HOME/.gitconfig.backup"
fi

# Create symlinks
ln -sf "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"
echo -e "${GREEN}  ✓ Linked .gitconfig${NC}"

ln -sf "$SCRIPT_DIR/.gitconfig-work" "$HOME/.gitconfig-work"
echo -e "${GREEN}  ✓ Linked .gitconfig-work${NC}"

echo ""
echo -e "${GREEN}✅ Git configuration installed!${NC}"
echo ""
echo -e "${BLUE}Aliases available:${NC}"
echo "  git amend    Amend last commit without editing message"
echo "  git wip      Stage all + commit with 'WIP' message"
echo "  git undo     Undo last commit, keep changes staged"
