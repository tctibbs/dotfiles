#!/bin/zsh

# Colorize grep output
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"

# Only define aliases if eza is available
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --color=always --group-directories-first'
  alias ll='eza -lgh --icons --color=always --group-directories-first'              # long view, group, human-readable
  alias la='eza -la --icons --color=always --group-directories-first'               # all files including dotfiles
  alias lt='eza -T --icons --color=always --group-directories-first'                # tree view
  alias llt='eza -lTgh --icons --color=always --group-directories-first'            # long + tree view
  alias ld='eza -D --icons --color=always --group-directories-first'                # directories only
  alias lm='eza -ls=modified -la --icons --color=always --group-directories-first'  # sort by modified date
else
  echo "⚠️  'eza' not found - skipping eza aliases" >&2
fi

# Only define aliases if bat is available
if command -v bat &> /dev/null; then
  alias cat='bat'                                  
  export BAT_THEME="Visual Studio Dark+"
else
  echo "⚠️  'bat' not found - skipping bat aliases" >&2
fi

# Only define alias if dust is available
if command -v dust &>/dev/null; then
  alias du='dust'
else
  echo "⚠️  'dust' not found - skipping dust aliases" >&2
fi

# Only define aliases if procs is available
if command -v procs &>/dev/null; then
  alias ps='procs'
else
  echo "⚠️  'procs' not found - skipping procs aliases" >&2
fi

# Claude Code aliases
if command -v claude &>/dev/null; then
  alias cc='claude --dangerously-skip-permissions'
  alias ccc='claude --dangerously-skip-permissions -c'
fi

# Gemini CLI aliases (gf = gemini flash, avoids conflict with Ruby's gem)
if command -v gemini &>/dev/null; then
  alias gf='gemini --model gemini-2.5-flash'
fi

# OneFetch - use nerd fonts by default
if command -v onefetch &>/dev/null; then
  alias onefetch='onefetch --nerd-fonts'
fi

# yazi - cd to directory on exit
if command -v yazi &>/dev/null; then
  function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi

# Database config editor - quick access to gobang config
if command -v gobang &>/dev/null; then
  alias dbconfig='${EDITOR:-nano} ~/.config/gobang/config.toml'
fi

# Source getcontext functions if available
# Try multiple possible locations for the dotfiles
if [[ -f "${0:A:h}/../scripts/getcontext.zsh" ]]; then
  source "${0:A:h}/../scripts/getcontext.zsh"
elif [[ -f "$HOME/.dotfiles/scripts/getcontext.zsh" ]]; then
  source "$HOME/.dotfiles/scripts/getcontext.zsh"
fi
