# Windows Terminal

A second supported terminal alongside [WezTerm](wezterm.md). Windows Terminal
has no Lua config and no custom tab rendering, so the powerline tab bar and its
styling live only in WezTerm. What *does* carry over is the part that matters
day to day: **which tab is a coding agent, and whether it is working, idle, or
waiting on you.**

## Coding agent tabs

The `wezterm-agent-state` helper (`~/.local/bin`) that agents' hooks already
call now emits a second sequence alongside the user variables:

| Sequence | Consumed by | Effect |
|----------|-------------|--------|
| `OSC 1337 SetUserVar` | WezTerm | Drives the full Lua tab bar (icon, colour, state dot, status rollup). |
| `OSC 9;4` progress | Windows Terminal, ConEmu, Ghostty, … | A coloured **progress ring on the tab** plus a taskbar indicator. |

One call covers every terminal, and each ignores what it does not understand.
The ring is skipped under WezTerm, whose tab bar already shows the state —
see [When it fires](#when-it-fires). The WezTerm side and the hook wiring are
unchanged; [wezterm.md](wezterm.md) has both.

### State → ring

The [ConEmu OSC 9;4 sequence](https://learn.microsoft.com/en-us/windows/terminal/tutorials/progress-bar-sequences)
maps onto the same three canonical states as the WezTerm tab bar:

| Agent state | OSC 9;4 | Windows Terminal shows |
|-------------|---------|------------------------|
| working | `3` indeterminate | animated ring on the tab |
| waiting (needs you) | `2` error | **red** ring on the tab + taskbar |
| idle / clear | `0` hidden | ring removed |

State aliases (`busy`, `blocked`, `approval`, `done`, …) are normalised the
same way as in `agents/state.lua`; the two lists are kept in sync by hand.

### When it fires

`OSC 9;4` is emitted for every terminal **except WezTerm**, which is detected
by the `WEZTERM_PANE` environment variable. WezTerm's tab bar already renders
state from the user vars, so a second taskbar ring there would just be noise.

Override with an environment variable:

| `WEZTERM_AGENT_PROGRESS` | Behaviour |
|--------------------------|-----------|
| unset / `auto` | emit everywhere except WezTerm (default) |
| `always` | emit in WezTerm too |
| `never` | never emit the ring |

## What does not carry over

These depend on WezTerm's Lua `format-tab-title` / `update-status` and have no
Windows Terminal equivalent:

- the powerline tab bar and per-tab background colours (there is no runtime
  escape to recolour a Windows Terminal tab — the "whole tab flips red" for
  *waiting* is replaced by the red `OSC 9;4` ring);
- the small vs. large state dot distinction;
- the right-status rollup of agent states across the window;
- foreground-process icons in the tab bar;
- Lua session restore (reopening tabs in their directories). Windows Terminal
  can only define static startup tabs in `settings.json`.

## Setup

Nothing to script. Two things to check in Windows Terminal `settings.json`:

- the profile uses a Nerd Font (`FiraCode Nerd Font Mono`), matching WezTerm, so
  any glyphs an agent prints in its title render correctly;
- `suppressApplicationTitle` is **not** enabled, so agents that set their own
  tab title still show it.
