# Installation Scripts

This directory contains platform-specific installation scripts for various CLI tools.

## Structure

```
install/
├── linux/
│   ├── common-tools.sh        # Generic script for system package manager tools
│   └── aarch64/              # Architecture-specific scripts
│       ├── eza.sh            # Manual download from GitHub releases
│       ├── fd.sh             # Manual download from GitHub releases
│       ├── procs.sh          # Manual download from GitHub releases
│       ├── dust.sh           # Manual download from GitHub releases
│       └── fzf.sh            # Git clone installation
└── darwin/                   # macOS scripts (future)
    └── common-tools.sh       # Homebrew-based system tools
```

## Generic common-tools.sh

The `common-tools.sh` script consolidates the installation of tools that can be installed via the system package manager:

- **btop**: Resource monitor with charts and themes
- **tldr**: Simplified community-driven command help
- **bat**: Syntax-highlighted file viewer (with symlink handling for Debian/Ubuntu)
- **zoxide**: Smart cd command

### Cross-platform support:

- **Linux**: Uses `apt` package manager
- **macOS**: Uses `Homebrew` package manager (requires Homebrew to be installed)

### Benefits of consolidation:

1. **Reduced redundancy**: Single script instead of multiple similar scripts
2. **Efficient package management**: One package manager update call instead of multiple
3. **Easier maintenance**: Update one script instead of four
4. **Consistent error handling**: Unified approach to installation checks
5. **Cross-platform**: Same script works on Linux and macOS

## Individual Scripts

The remaining scripts in architecture-specific directories handle tools that require:

- **Manual downloads**: Tools downloaded from GitHub releases (eza, fd, procs, dust)
- **Git installations**: Tools installed via git clone (fzf)
- **Custom installation logic**: Tools with specific installation requirements

## Adding New Tools

### For system package manager tools:
Add the tool name to the `COMMON_TOOLS` array in `common-tools.sh`.

### For manual installation:
Create a new script in the appropriate architecture directory following the existing patterns.

## Platform Support

Currently supports:
- **Linux aarch64**: Full support with all scripts
- **macOS**: System tools via Homebrew (individual scripts not yet implemented) 