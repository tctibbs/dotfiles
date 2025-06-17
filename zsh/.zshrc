# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# Load optional custom configurations (aliases, exports, functions)
[[ -f "$HOME/aliash.zsh" ]] && source "$HOME/aliash.zsh"
[[ -f "$HOME/exports.zsh" ]] && source "$HOME/exports.zsh"

# theme
znap source romkatv/powerlevel10k

# Plugins

# zsh-autosuggestions: Suggests commands from history as you type.
znap source zsh-users/zsh-autosuggestions      

# zsh-syntax-highlighting: Adds color-coded syntax highlighting.
znap source zsh-users/zsh-syntax-highlighting  

# zsh-history-substring-search: Searches through history with partial input.
znap source zsh-users/zsh-history-substring-search  

# Keybindings
bindkey '^ ' autosuggest-accept                         # Accept autosuggestions with space
bindkey '^[[A' history-substring-search-up              # Search history (up arrow)
bindkey '^[[B' history-substring-search-down            # Search history (down arrow)

# Enable fzf key bindings and auto-completions (only if fzf is installed)
[ -f "$HOME/.zsh_env" ] && source "$HOME/.zsh_env"
if command -v fzf &>/dev/null && [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

unset ZSH_AUTOSUGGEST_USE_ASYNC
