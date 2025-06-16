#!/bin/zsh

# Colorize grep output
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"

# Set up eza aliases with fancy colors and icons
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
