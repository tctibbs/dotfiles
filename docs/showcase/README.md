# Showcase

What this configuration actually changes, one page per feature.

| Page | Covers |
|------|--------|
| [tab-bar.md](tab-bar.md) | Tabs that show which coding agent is running and what it is doing |
| [directories.md](directories.md) | Reopening tabs in the directories they were in |

Where a change is visual, the page shows the same content twice — stock
defaults and configured — so the only difference is the configuration.

## Planned

Rough order of usefulness, not a commitment:

- **prompt** — starship: git state, directory icons, what each segment means
- **shell** — eza, bat, fd, dust and procs against the coreutils equivalents,
  on the same directory
- **tmux** — popup scratchpad, prefix bindings, status line
- **editor** — VS Code: Catppuccin, error lens, file nesting
- **windows-terminal** — the Windows counterpart

## Regenerating the images

```sh
scripts/capture-showcase.sh tab-bar
```

Captures both halves from a real window rather than a mockup, so the images
cannot drift from what the config does. macOS only.
