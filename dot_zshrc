# Set locale for UTF-8 compatibility
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# History configuration
export HISTFILE=~/.zsh_history        # Location for saved command history

# Znap setup for managing plugins
[[ -r ~/.config/zsh/znap/znap.zsh ]] || {
    git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git ~/.config/zsh/znap
}
source ~/.config/zsh/znap/znap.zsh

# Completion configuration
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case-insensitive
zstyle ':completion:*' menu select                          # Interactive menu
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}      # Colorized completions
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'

# Load optional custom configurations (aliases, exports, functions)
[[ -f "$HOME/.config/zsh/aliash.zsh" ]] && source "$HOME/.config/zsh/aliash.zsh"
[[ -f "$HOME/.config/zsh/exports.zsh" ]] && source "$HOME/.config/zsh/exports.zsh"

# Plugins

# zsh-autocomplete: Real-time type-ahead completion (from Znap's author)
znap source marlonrichert/zsh-autocomplete

# you-should-use: Reminds you of aliases when you type the full command
znap source MichaelAquilina/zsh-you-should-use

# fast-syntax-highlighting: Feature-rich syntax highlighting
znap source zdharma-continuum/fast-syntax-highlighting

# zsh-history-substring-search: Searches through history with partial input
znap source zsh-users/zsh-history-substring-search

# Keybindings (zsh-autocomplete handles most completion bindings automatically)
bindkey '^[[A' history-substring-search-up              # Search history (up arrow)
bindkey '^[[B' history-substring-search-down            # Search history (down arrow)

# Enable fzf key bindings and auto-completions (only if fzf is installed)
[ -f "$HOME/.zsh_env" ] && source "$HOME/.zsh_env"
if command -v fzf &>/dev/null && [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
fi

# Only init zoxide if available
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
else
  echo "zoxide not found - skipping zoxide integration" >&2
fi

export PATH="$HOME/.local/bin:$PATH"

# Initialize Starship prompt
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
