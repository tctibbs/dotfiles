# Showcase

Side-by-side comparisons of this configuration against stock defaults, with
the features behind each difference.

Each page shows the same content twice — once with the tool's defaults, once
configured — so the difference is the configuration and nothing else.

| Page | Covers |
|------|--------|
| [tab-bar.md](tab-bar.md) | WezTerm tabs: coding agent identity and state, process icons, powerline styling |

## Planned

Rough order of usefulness, not a commitment:

- **prompt** — starship: git state, directory icons, what the segments mean
- **shell** — the modern CLI replacements (eza, bat, fd, dust, procs) against
  their coreutils equivalents, on the same directory
- **tmux** — the popup scratchpad, prefix bindings, status line
- **editor** — VS Code: Catppuccin, error lens, file nesting
- **windows-terminal** — the Windows counterpart to the WezTerm setup

## Regenerating the images

```sh
scripts/capture-showcase.sh tab-bar
```

Captures both halves from a real WezTerm window rather than a mockup, so the
images cannot drift from what the config actually does. Requires macOS.
