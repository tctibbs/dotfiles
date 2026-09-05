# Remembering directories

Close WezTerm, restart the machine, open WezTerm — and your tabs are back in
the projects you were working in.

## Stock WezTerm

One window, one tab, your home directory. Whatever you had open is gone, and
you navigate back by hand.

## Configured

Every two minutes the directory of each tab is written to
`~/.local/share/wezterm/tabs.json`. On the next launch those tabs reopen in the
same places, each named after its project:

```
 ~   dotfiles   Code   nestflix
```

Then resume whichever agent was there:

```sh
ccc            # claude --dangerously-skip-permissions -c
codex resume
```

## What this is not

It does not restart programs, and that is deliberate. Restoring a live process
is not something a terminal can honestly do — the tools that claim to are
re-running a saved command line. Directories are the part that carries real
meaning across a reboot, and they are the same for every agent, so nothing here
needs to know whether you were running Claude Code, Codex, Copilot or
Antigravity.

| Saved | Not saved |
|-------|-----------|
| each tab's working directory | running programs |
| tab order and window grouping | pane splits, scrollback, workspaces |

## What does the work

| Feature | What it gives |
|---------|---------------|
| `mux.all_windows`, `window:tabs()` | Walking the live layout to snapshot it. |
| `pane:get_current_working_dir()` | The directory itself, as a `file://` URL. |
| `update-status` | The save clock. `wezterm.time.call_after` cannot re-arm from inside its own callback — it fires once — so the state file would freeze at the startup snapshot. |
| `gui-startup` | Recreating the tabs before the first window appears. Launching with an explicit command skips the restore. |
| `json_encode` / `json_parse` | The state file, written to a temporary path and renamed, so a crash mid-write cannot leave unparseable JSON. |

Lives in `wezterm/sessions.lua`.
