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

getcontext() {
  setopt local_options no_aliases  # ignore any aliases inside this function

  # Flags and options
  local extensions=""
  local help_flag=false
  local yes_flag=false
  local dry_run=false
  local max_files=400

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -e|--extensions) extensions="$2"; shift 2 ;;
      -m|--max-files) max_files="$2"; shift 2 ;;
      -y|--yes) yes_flag=true; shift ;;
      --dry-run) dry_run=true; shift ;;
      -h|--help) help_flag=true; shift ;;
      *) echo "Unknown option: $1"; return 1 ;;
    esac
  done

  # Help message
  if [[ "$help_flag" == true ]]; then
    echo "Usage: getcontext [-e extensions] [-m max_files] [-y] [--dry-run]"
    echo "  -e, --extensions    Comma-separated file extensions (e.g., '.py,.js,.ts')"
    echo "  -m, --max-files     Safety threshold before confirmation (default: 400)"
    echo "  -y, --yes           Skip confirmation prompt (non-interactive)"
    echo "      --dry-run       Show matching files and exit (no contents printed)"
    echo "  -h, --help          Show this help message"
    echo "Examples:"
    echo "  getcontext"
    echo "  getcontext -e '.py,.js'"
    echo "  getcontext -m 200"
    echo "  getcontext --dry-run"
    echo "  getcontext-save context.md -e '.py,.ts'"
    echo "  getcontext-copy"
    return 0
  fi

  # Default set of extensions if none provided
  local default_exts=".js,.jsx,.ts,.tsx,.py,.go,.java,.cpp,.c,.h,.hpp,.rs,.rb,.php,.swift,.kt,.scala,.clj,.hs,.ml,.fs,.ex,.exs,.cr,.nim,.zig,.odin,.v,.dart,.sol,.md,.txt,.yml,.yaml,.json,.toml,.xml,.puml,.plantuml"
  local search_exts="${extensions:-$default_exts}"

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
  fd_cmd=(command fd --type f "${fd_ext_flags[@]}" .
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
    -0)

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
  getcontext "$@" | pbcopy
  echo "Context copied to clipboard!"
}

# Save context to a file
getcontext-save() {
  local filename="${1:-context.txt}"
  shift
  getcontext "$@" > "$filename"
  echo "Context saved to $filename"
}
