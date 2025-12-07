#!/bin/bash

# Tmux Installation Script
# ========================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🔧 Setting up Tmux configuration...${NC}"

# ===================================
# Install tmux if not present
# ===================================

if ! command -v tmux &> /dev/null; then
    echo -e "${YELLOW}⚠️  Tmux is not installed. Installing via package manager...${NC}"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install tmux
        else
            echo -e "${RED}❌ Homebrew not found. Please install tmux manually.${NC}"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y tmux
        elif command -v yum &> /dev/null; then
            sudo yum install -y tmux
        elif command -v pacman &> /dev/null; then
            sudo pacman -S tmux
        else
            echo -e "${RED}❌ Package manager not found. Please install tmux manually.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}❌ Unsupported OS. Please install tmux manually.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓ Tmux $(tmux -V | cut -d' ' -f2) installed${NC}"

# ===================================
# Install TPM (Tmux Plugin Manager)
# ===================================

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
    echo -e "${BLUE}📦 Installing TPM (Tmux Plugin Manager)...${NC}"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo -e "${GREEN}✓ TPM installed${NC}"
else
    echo -e "${GREEN}✓ TPM already installed${NC}"
fi

# ===================================
# Symlink configuration files
# ===================================

echo -e "${BLUE}🔗 Creating symlinks to tmux configurations...${NC}"

CONFIGS=(".tmux.conf" ".tmux.mac.conf" ".tmux.linux.conf")

for conf in "${CONFIGS[@]}"; do
    if [ -f "$SCRIPT_DIR/$conf" ]; then
        # Backup existing non-symlink config
        if [ -f "$HOME/$conf" ] && [ ! -L "$HOME/$conf" ]; then
            echo -e "${YELLOW}  📦 Backing up existing $conf${NC}"
            mv "$HOME/$conf" "$HOME/${conf}.backup"
        fi

        ln -sf "$SCRIPT_DIR/$conf" "$HOME/$conf"
        echo -e "${GREEN}  ✓ Linked $conf${NC}"
    fi
done

# ===================================
# Install optional tools
# ===================================

echo -e "${BLUE}🛠️  Checking optional tools...${NC}"

# Screensaver tools
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v pipes.sh &>/dev/null; then
        if command -v brew &>/dev/null; then
            echo -e "${YELLOW}  Installing pipes.sh...${NC}"
            brew install pipes-sh 2>/dev/null || echo -e "${YELLOW}  ⚠️  pipes.sh install failed (optional)${NC}"
        fi
    else
        echo -e "${GREEN}  ✓ pipes.sh available${NC}"
    fi

    # LazyGit for git popup
    if ! command -v lazygit &>/dev/null; then
        if command -v brew &>/dev/null; then
            echo -e "${YELLOW}  Installing lazygit...${NC}"
            brew install lazygit 2>/dev/null || echo -e "${YELLOW}  ⚠️  lazygit install failed (optional)${NC}"
        fi
    else
        echo -e "${GREEN}  ✓ lazygit available${NC}"
    fi

    # fzf for tmux-fzf plugin
    if ! command -v fzf &>/dev/null; then
        if command -v brew &>/dev/null; then
            echo -e "${YELLOW}  Installing fzf...${NC}"
            brew install fzf 2>/dev/null || echo -e "${YELLOW}  ⚠️  fzf install failed (optional)${NC}"
        fi
    else
        echo -e "${GREEN}  ✓ fzf available${NC}"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "${BLUE}  ℹ️  Optional: Install pipes.sh from https://github.com/pipeseroni/pipes.sh${NC}"
    echo -e "${BLUE}  ℹ️  Optional: Install lazygit from https://github.com/jesseduffield/lazygit${NC}"
    echo -e "${BLUE}  ℹ️  Optional: Install fzf from https://github.com/junegunn/fzf${NC}"
fi

# ===================================
# Install tmux plugins via TPM
# ===================================

echo -e "${BLUE}📦 Installing tmux plugins...${NC}"

if [ -x "$TPM_DIR/bin/install_plugins" ]; then
    "$TPM_DIR/bin/install_plugins"
    echo -e "${GREEN}✓ Plugins installed${NC}"
else
    echo -e "${YELLOW}⚠️  Run 'prefix + I' in tmux to install plugins${NC}"
fi

# ===================================
# Reload tmux config if server running
# ===================================

if tmux info &> /dev/null; then
    echo -e "${GREEN}🔄 Reloading tmux configuration...${NC}"
    # Source config in all sessions to apply changes everywhere
    tmux source-file "$HOME/.tmux.conf" 2>/dev/null || true
    # Kill and restart the server to fully apply terminal settings (optional)
    echo -e "${YELLOW}⚠️  For full effect, restart tmux: tmux kill-server && tmux${NC}"
else
    echo -e "${BLUE}ℹ️  Tmux server not running. Configuration will be loaded on next session.${NC}"
fi

# ===================================
# Summary
# ===================================

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Tmux configuration installed successfully!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}🎯 Quick Start:${NC}"
echo "  tmux                         Start tmux"
echo "  tmux new -s <name>           New named session"
echo "  tmux attach -t <name>        Attach to session"
echo ""
echo -e "${BLUE}🎨 Key Bindings (Prefix = Ctrl-a):${NC}"
echo "  Prefix + |                   Split horizontal"
echo "  Prefix + -                   Split vertical"
echo "  Prefix + s                   Session browser (sessionx)"
echo "  Prefix + g                   LazyGit popup"
echo "  Prefix + a                   Claude AI popup"
echo "  Prefix + b                   btop system monitor"
echo "  Prefix + n                   Notes scratchpad"
echo "  Prefix + f                   Fuzzy finder (fzf)"
echo "  Prefix + F                   Quick copy hints (thumbs)"
echo "  Prefix + I                   Install/update plugins"
echo "  Alt + Arrow keys             Navigate panes (no prefix)"
echo "  Alt + 1-5                    Switch windows"
echo ""
echo -e "${GREEN}🎉 Happy tmux-ing!${NC}"
