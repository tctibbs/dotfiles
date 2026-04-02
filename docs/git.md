# Git

Configured in `home/dot_gitconfig.tmpl` with chezmoi templating for identity.

## Identity

Chezmoi prompts for `personal` or `work` on first run. Work identity uses a separate `~/.gitconfig-work` included conditionally for `~/Work/` repositories.

## Core Settings

| Setting | Value |
|---------|-------|
| Default branch | `main` |
| Pull strategy | Rebase |
| Push | Auto-setup upstream tracking |
| Fetch | Auto-prune deleted remotes |
| Merge conflict style | `zdiff3` |
| Pager | delta (side-by-side, line numbers, navigate) |

## Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `amend` | `commit --amend --no-edit` | Amend last commit silently |
| `wip` | `!git add -A && git commit -m 'WIP'` | Quick work-in-progress commit |
| `undo` | `reset --soft HEAD~1` | Undo last commit, keep changes staged |
| `dft` | `difftool` | Difftastic structural diff |
| `dlog` | `log -p --ext-diff` | Log with difftastic diffs |
| `dshow` | `show --ext-diff` | Show commit with difftastic |

## Delta

[Delta](https://github.com/dandavison/delta) is configured as the default pager for diffs and logs:

- Side-by-side view
- Line numbers
- Navigate between hunks with `n`/`N`
