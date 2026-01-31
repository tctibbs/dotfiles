#!/bin/zsh

# ==============================================================
# getcontext: Gather project context by dumping file contents
# into a single stream. Useful for prompts, reviews, or quick
# overviews of all code files in a repo.
#
# Example usage:
#
#   # Use default extensions
#   getcontext
#
#   # Only include Python and JS files
#   getcontext -e ".py,.js"
#
#   # Use language profiles
#   getcontext --python
#   getcontext --react
#
#   # Filter by directories
#   getcontext -d frontend
#   getcontext -d src -d lib
#
#   # Combine profiles and directories
#   getcontext --python -d backend
#
#   # Raise/Lower the safety threshold (max files before confirm)
#   getcontext -m 200
#
#   # Skip confirmation (CI/automation)
#   getcontext -y
#
#   # Dry run: count + list files without printing contents
#   getcontext --dry-run
#
#   # Save context to a file (default: context.txt)
#   getcontext-save
#
#   # Save to custom file
#   getcontext-save mycontext.md
#
#   # Save with specific extensions
#   getcontext-save context.md -e ".py,.ts"
#
#   # Copy context to clipboard
#   getcontext-copy
# ==============================================================

# Detect appropriate clipboard command for the current OS
_get_clipboard_command() {
  # macOS: pbcopy is the standard
  if [[ "$OSTYPE" == darwin* ]]; then
    echo "pbcopy"
    return 0
  fi

  # WSL: Use Windows clip.exe
  if [[ -n "$WSL_DISTRO_NAME" ]]; then
    echo "/mnt/c/Windows/System32/clip.exe"
    return 0
  fi

  # Linux: Detect Wayland vs X11
  if [[ -n "$WAYLAND_DISPLAY" ]]; then
    if command -v wl-copy &>/dev/null; then
      echo "wl-copy"
      return 0
    fi
  fi

  # X11 or fallback for Linux
  if [[ -n "$DISPLAY" ]] && command -v xclip &>/dev/null; then
    echo "xclip -selection clipboard"
    return 0
  fi

  # No clipboard tool found
  return 1
}

getcontext() {
  setopt local_options no_aliases  # ignore any aliases inside this function

  # Language/framework profile definitions
  typeset -A profiles
  profiles[python]=".py,.pyi,requirements.txt,requirements-dev.txt,pyproject.toml,setup.py,setup.cfg,Pipfile,Pipfile.lock,pytest.ini,tox.ini,.flake8,mypy.ini,py.typed"
  profiles[javascript]=".js,.jsx,.mjs,.cjs,package.json,package-lock.json,.npmrc,.eslintrc,.eslintrc.js,.eslintrc.json,.prettierrc,.prettierrc.js,.prettierrc.json"
  profiles[typescript]=".ts,.tsx,.mts,.cts,tsconfig.json,tsconfig.build.json,package.json,package-lock.json,.eslintrc,.eslintrc.js,.eslintrc.json,.prettierrc,.prettierrc.js,.prettierrc.json"
  profiles[node]="${profiles[javascript]},${profiles[typescript]}"
  profiles[react]=".js,.jsx,.ts,.tsx,package.json,tsconfig.json,.eslintrc,.prettierrc,vite.config.js,vite.config.ts,next.config.js,next.config.ts,.env.example"
  profiles[rust]=".rs,Cargo.toml,Cargo.lock,build.rs,rust-toolchain,rust-toolchain.toml"
  profiles[go]=".go,go.mod,go.sum,go.work,go.work.sum"
  profiles[java]=".java,.kt,.kts,.gradle,pom.xml,build.gradle,build.gradle.kts,settings.gradle,settings.gradle.kts,gradle.properties"
  profiles[web]=".html,.css,.scss,.sass,.less,.vue,.svelte"

  # Flags and options
  local extensions=""
  local profile=""
  local directories=()
  local help_flag=false
  local yes_flag=false
  local dry_run=false
  local max_files=400

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -e|--extensions) extensions="$2"; shift 2 ;;
      -d|--dir)
        # Validate directory exists
        if [[ ! -d "$2" ]]; then
          echo "Error: Directory does not exist: $2" >&2
          return 1
        fi
        directories+=("$2")
        shift 2
        ;;
      -m|--max-files) max_files="$2"; shift 2 ;;
      -y|--yes) yes_flag=true; shift ;;
      --dry-run) dry_run=true; shift ;;
      -h|--help) help_flag=true; shift ;;
      --python|--javascript|--typescript|--node|--react|--rust|--go|--java|--web)
        profile="${1#--}"; shift ;;
      *) echo "Unknown option: $1"; return 1 ;;
    esac
  done

  # Help message
  if [[ "$help_flag" == true ]]; then
    echo "Usage: getcontext [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --extensions EXT    Comma-separated file extensions (e.g., '.py,.js,.ts')"
    echo "  -d, --dir DIR           Search only in specified directory (can be repeated)"
    echo "  -m, --max-files N       Safety threshold before confirmation (default: 400)"
    echo "  -y, --yes               Skip confirmation prompt (non-interactive)"
    echo "      --dry-run           Show matching files and exit (no contents printed)"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Language Profiles:"
    echo "  --python                Python projects (.py, requirements.txt, pyproject.toml, etc.)"
    echo "  --javascript            JavaScript projects (.js, .jsx, package.json, etc.)"
    echo "  --typescript            TypeScript projects (.ts, .tsx, tsconfig.json, etc.)"
    echo "  --node                  Node.js projects (JavaScript + TypeScript)"
    echo "  --react                 React projects (.jsx, .tsx, vite.config, next.config, etc.)"
    echo "  --rust                  Rust projects (.rs, Cargo.toml, etc.)"
    echo "  --go                    Go projects (.go, go.mod, etc.)"
    echo "  --java                  Java/Kotlin projects (.java, .kt, pom.xml, etc.)"
    echo "  --web                   Web projects (.html, .css, .vue, .svelte, etc.)"
    echo ""
    echo "Examples:"
    echo "  getcontext                                    # All default extensions in current dir"
    echo "  getcontext --python                           # Python project context"
    echo "  getcontext --react                            # React project context"
    echo "  getcontext -e '.py,.js'                       # Only Python and JavaScript files"
    echo "  getcontext -d src -d lib                      # Search only src/ and lib/ directories"
    echo "  getcontext --rust -d backend                  # Rust files in backend/ directory"
    echo "  getcontext --react -d frontend                # React files in frontend/ directory"
    echo "  getcontext --dry-run                          # Preview files without contents"
    echo "  getcontext-save context.md --python           # Save Python context to file"
    echo "  getcontext-copy -d src                        # Copy src/ context to clipboard"
    echo ""
    echo "Helper Functions:"
    echo "  getcontext-save [FILE] [OPTIONS]  # Save context to file (default: context.txt)"
    echo "  getcontext-copy [OPTIONS]         # Copy context directly to clipboard"
    return 0
  fi

  # Determine extensions based on profile or explicit flag
  local default_exts=".js,.jsx,.ts,.tsx,.py,.go,.java,.cpp,.c,.h,.hpp,.rs,.rb,.php,.swift,.kt,.scala,.clj,.hs,.ml,.fs,.ex,.exs,.cr,.nim,.zig,.odin,.v,.dart,.sol,.md,.txt,.yml,.yaml,.json,.toml,.xml,.puml,.plantuml"

  local search_exts
  if [[ -n "$extensions" ]]; then
    # Explicit -e flag overrides everything
    search_exts="$extensions"
  elif [[ -n "$profile" ]]; then
    # Use profile extensions
    if [[ -n "${profiles[$profile]}" ]]; then
      search_exts="${profiles[$profile]}"
    else
      echo "Unknown profile: $profile" >&2
      echo "Available profiles: ${(k)profiles[@]}" >&2
      return 1
    fi
  else
    # Use default
    search_exts="$default_exts"
  fi

  # Convert comma-separated extensions into fd -e flags
  local -a fd_ext_flags
  IFS=',' read -rA raw_exts <<< "$search_exts"
  for ext in "${raw_exts[@]}"; do
    ext="${ext##*( )}"   # trim leading spaces
    ext="${ext%%*( )}"   # trim trailing spaces
    [[ -z "$ext" ]] && continue
    ext="${ext#.}"       # remove leading dot if present
    fd_ext_flags+=(-e "$ext")
  done

  # Build fd command with exclusions
  local -a fd_cmd
  local -a search_paths

  # Determine search paths
  if (( ${#directories[@]} > 0 )); then
    search_paths=("${directories[@]}")
  else
    search_paths=(.)
  fi

  fd_cmd=(command fd --type f "${fd_ext_flags[@]}"
    .
    --exclude node_modules
    --exclude .git
    --exclude dist
    --exclude build
    --exclude .next
    --exclude .nuxt
    --exclude target
    --exclude vendor
    --exclude __pycache__
    --exclude '*.min.js'
    --exclude '*.min.css'
    --exclude '*.map'
    --exclude '.env*'
    --exclude '*.log'
    --exclude '*.lock'
    --exclude 'package-lock.json'
    --exclude 'yarn.lock'
    -0
    "${search_paths[@]}")

  # Collect files (handles spaces/newlines safely)
  local -a files
  files=("${(0)$("${fd_cmd[@]}")}")

  local count=${#files[@]}

  # Dry run mode: just print the list and count
  if [[ "$dry_run" == true ]]; then
    echo "# Dry run"
    echo "# Directory: $(pwd)"
    echo "# Matched files: $count"
    if (( count > 0 )); then
      printf '%s\0' "${files[@]}" | tr '\0' '\n'
    fi
    return 0
  fi

  # If no files matched
  if (( count == 0 )); then
    echo "No files matched the specified extensions in $(pwd)."
    echo "Tip: try relaxing the set, e.g.: getcontext -e '.py,.md,.json'"
    return 1
  fi

  # Confirmation if file count is too large
  if (( count > max_files )) && [[ "$yes_flag" != true ]]; then
    echo "⚠️  getcontext found $count files (threshold: $max_files)."
    echo -n "Proceed with dumping contents? [y/N] "
    read -r reply
    if [[ ! "$reply" =~ ^([yY]|[yY][eE][sS])$ ]]; then
      echo "Aborted."
      return 1
    fi
  fi

  # Print header
  echo "# Context for $(pwd)"
  echo "# Generated on $(date)"
  echo ""

  # Print files one by one with fenced code blocks
  local sorted
  sorted="$(printf '%s\0' "${files[@]}" | tr '\0' '\n' | sort)"
  local file
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    echo "## $file"
    echo '```'
    cat "$file" 2>/dev/null || echo "(Could not read file)"
    echo '```'
    echo ""
  done <<< "$sorted"
}

# Copy context directly to clipboard
getcontext-copy() {
  local clip_cmd
  clip_cmd="$(_get_clipboard_command)"

  if [[ $? -ne 0 ]]; then
    echo "Error: No clipboard utility found." >&2
    echo "Install one of: pbcopy (macOS), xclip (Linux X11), wl-clipboard (Linux Wayland)" >&2
    return 1
  fi

  getcontext "$@" | eval "$clip_cmd"
  echo "Context copied to clipboard!"
}

# Save context to a file
getcontext-save() {
  local filename="${1:-context.txt}"
  shift
  getcontext "$@" > "$filename"
  echo "Context saved to $filename"
}
