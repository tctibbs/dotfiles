# Remembering directories

Restart your machine, open WezTerm, and your tabs are back in the projects you
were working in.

Stock WezTerm gives you one window in your home directory; whatever you had
open is gone. Configured, the tab bar comes back as:

```
 ~   dotfiles   api-refactor   data-pipeline
```

Each tab is in its project directory and named after it. Resume whichever agent
was there:

```sh
claude --continue
codex resume
```

## What is saved

Every two minutes, one entry per tab in `~/.local/share/wezterm/tabs.json`:

```json
{ "version": 1, "windows": [ { "tabs": [ { "cwd": "/Users/you/code/api-refactor" } ] } ] }
```

That is the whole state. Delete the file to start clean.

| Saved | Not saved |
|-------|-----------|
| each tab's working directory | running programs |
| tab order and window grouping | pane splits, scrollback, workspaces |

## Why it does not restore programs

Because a terminal cannot honestly do that. The plugins advertising session
restore are re-running a saved command line, which works for a shell and not
much else.

Directories are the part that survives a reboot with its meaning intact, and a
path means the same thing whichever agent you were using. Nothing here needs to
know about Claude Code, Codex, Copilot or Antigravity, and nothing breaks when
one of them changes its CLI.

## What does the work

| Feature | What it gives |
|---------|---------------|
| `mux.all_windows`, `window:tabs()` | Walking the live layout to snapshot it |
| `pane:get_current_working_dir()` | The directory, as a `Url`. Older releases returned a `file://` string, so both are handled |
| `gui-startup` | Recreating tabs before the first window appears. An explicit command on the command line skips the restore |
| `json_encode` / `json_parse` | The state file, written alongside and renamed, so a crash mid-write cannot leave unparseable JSON |
| `update-status` | The save clock — see below |

`update-status` is an odd choice until you try the obvious one:
`wezterm.time.call_after` fires once and cannot re-arm from inside its own
callback, so the state file freezes at the startup snapshot while appearing to
work. `update-status` is driven by WezTerm itself.

Lives in `wezterm/sessions.lua`.
