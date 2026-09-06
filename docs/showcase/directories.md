# Remembering directories

Restart the machine, open WezTerm, and the tabs are back in the projects you
were working in, each named after its directory:

```
 ~   dotfiles   api-refactor   data-pipeline
```

Programs are not restarted — resume with `claude --continue` or `codex resume`.
Saving only directories is what keeps this agent-agnostic: nothing breaks when
an agent changes its CLI.

Every two minutes each tab's directory is written to
`~/.local/share/wezterm/tabs.json`; delete it to start clean. Splits,
scrollback and workspaces are not saved.

`gui-startup` recreates the tabs; `update-status` drives the save clock, since
`wezterm.time.call_after` fires once and cannot re-arm itself. Lives in
`wezterm/sessions.lua`.
