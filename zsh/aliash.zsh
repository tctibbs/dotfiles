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

# Only define alias if fd is available
if command -v fd &>/dev/null; then
  alias find='fd'
else
  echo "⚠️  'fd' not found - skipping fd alias" >&2
fi
