# Tab bar

Both screenshots show the same six tabs — four coding agents, a shell and a
process monitor. Only the configuration differs.

## Stock WezTerm

![Default WezTerm tab bar](../../assets/showcase/tab-bar-default.png)

Numbered tabs, a close button on each, one system font, no colour beyond the
active-tab highlight. Every tab looks alike whatever is running in it.

Tab 5 is a shell, but reads `wezterm-gui`: when a program sets no title, the
tab falls back to the terminal's own window title.

## Configured

![Configured tab bar](../../assets/showcase/tab-bar-configured.png)

Tab 5 is now labelled `zsh`. Each tab carries an icon for what is running,
agents are tinted by identity, and a dot shows what each one is doing. The tab
waiting on input turns solid red so it reads from across the screen, and the
rollup on the right counts states across the window — here one waiting, two
working, one idle.

## States

| Shown as | Meaning |
|----------|---------|
| yellow dot | working |
| green dot | idle |
| whole tab red | waiting on you |
| smaller dot | inferred from unseen output, not reported |

Agents report state by writing a user variable. Where none is reported, an
unfocused agent tab that produced output is treated as wanting attention —
drawn with a smaller dot, so a guess never looks like a fact. A tab identified
only by a title match gets an icon but never a state, since any program can
print a matching title.

## What does the work

| Feature | What it gives |
|---------|---------------|
| `format-tab-title` | Full control of tab content. Returns styled segments, so each part carries its own colour and weight. |
| `use_fancy_tab_bar = false` | The retro bar draws in the terminal font, so Nerd Font glyphs render, and a tab can set its own background. The fancy bar uses a proportional system font and composites its own chrome over the title. |
| `wezterm.nerdfonts` | Glyphs by name rather than pasted codepoints. A wrong name is `nil`, which the agent validator reports at startup instead of drawing a box. |
| `column_width` + `truncate_right` | Width-correct layout. Lua's `#` counts bytes — an ellipsis is three bytes but one cell — so byte arithmetic both over-reserves and can slice a character in half. |
| OSC 1337 `SetUserVar` | How a program inside a pane reports state to the terminal. Read back through `PaneInformation.user_vars`. |
| `user-var-changed` | Writing a user variable rebuilds the tab bar, so state appears when reported rather than on a poll. |
| `has_unseen_output` | Output since a pane was last focused. The fallback attention signal, needing nothing from the program. |
| `update-status` + `set_right_status` | The rollup. Reads the same variables the tabs do, so the two cannot disagree. |
| `tab_bar_style` | Matches the new-tab button to the tabs. |
| `INTEGRATED_BUTTONS` | Window controls inside the tab bar rather than a separate title bar. Works with the retro bar. |

Everything above lives in `wezterm/tabs/`, `wezterm/agents/` and
`wezterm/status.lua`. Colours come from `wezterm/palette.lua`.

## Adding an agent

One new file plus one line in the registry; the renderer needs no changes.
[../wezterm.md](../wezterm.md) has the contract and the hook wiring per agent.

---

Regenerate these images:

```sh
scripts/capture-showcase.sh tab-bar
```
