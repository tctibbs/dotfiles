# Git Configuration

Shared git config with useful defaults and aliases. No user identity included - configure `user.name` and `user.email` per-machine.

## Installation

```bash
./install.sh
```

## Defaults

| Setting | Value | Description |
|---------|-------|-------------|
| `init.defaultBranch` | `main` | New repos use `main` branch |
| `pull.rebase` | `true` | Rebase on pull for cleaner history |
| `push.autoSetupRemote` | `true` | No more `--set-upstream` needed |
| `fetch.prune` | `true` | Auto-cleanup deleted remote branches |
| `merge.conflictStyle` | `diff3` | Shows base version in merge conflicts |

## Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `git amend` | `commit --amend --no-edit` | Amend last commit, keep message |
| `git wip` | `add -A && commit -m "WIP"` | Quick save all changes |
| `git undo` | `reset HEAD~1 --soft` | Undo last commit, keep changes |

## Usage Examples

```bash
# Quick save before switching branches
git wip

# Later, undo the WIP commit and make a proper one
git undo
git commit -m "feat: actual commit message"

# Add forgotten file to last commit
git add forgotten-file.txt
git amend
```
