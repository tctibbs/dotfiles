#!/bin/bash
#
# Regenerate the showcase comparison images.
#
#   scripts/capture-showcase.sh tab-bar
#
# Launches WezTerm twice with the same content — once on stock defaults, once
# with this configuration — and captures the same region from each. The images
# therefore cannot drift from what the config actually does.
#
# macOS only: it uses screencapture. The window is placed and sized from Lua,
# so the crop is reproducible, but the vertical offset depends on the menu bar
# and the tab bar height depends on your font size. Override if the crop is off:
#
#   SHOWCASE_Y=44 SHOWCASE_H=26 scripts/capture-showcase.sh tab-bar
#
# The script prints the output paths; look at them before committing.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEZTERM="${WEZTERM:-/Applications/WezTerm.app/Contents/MacOS/wezterm}"
WORK="$(mktemp -d)"
trap 'pkill -f "$WORK" 2>/dev/null || true; rm -rf "$WORK"' EXIT

COLS="${SHOWCASE_COLS:-150}"
ROWS="${SHOWCASE_ROWS:-20}"
Y="${SHOWCASE_Y:-34}"
H="${SHOWCASE_H:-28}"
W="${SHOWCASE_W:-1270}"
SETTLE="${SHOWCASE_SETTLE:-7}"

[ -x "$WEZTERM" ] || { echo "wezterm not found at $WEZTERM" >&2; exit 1; }

# --- the content both halves display ----------------------------------------
# Agent state is announced exactly the way wezterm-agent-state does, so the
# configured half shows real identity and state rather than a staged image.
demo_tabs() {
    # Note the doubled backslashes: Lua's \ddd escape is DECIMAL, so a bare
    # "\033" is "!" (33), not ESC (27). Emitting a literal backslash lets the
    # shell's printf do the octal interpretation.
    cat <<'LUA'
local function t(agent, state, title)
    local seq = string.format(
        "printf '\\033]1337;SetUserVar=agent_id=%%s\\007' \"$(printf '%s' | base64)\"; "
        .. "printf '\\033]1337;SetUserVar=agent_state=%%s\\007' \"$(printf '%s' | base64)\"; ",
        agent, state)
    seq = seq .. string.format("printf '\\033]0;%s\\007'; exec sleep 600", title)
    return { "/bin/sh", "-c", seq }
end

wezterm.on("gui-startup", function()
    local tabs = {
        t("claude", "working", "api-refactor"),
        t("copilot", "waiting", "service-deploy"),
        t("codex", "working", "data-pipeline"),
        t("antigravity", "idle", "docs-site"),
        { "/bin/zsh", "-f" },
        { "/opt/homebrew/bin/btop" },
    }
    local _, _, win = wezterm.mux.spawn_window({ args = tabs[1] })
    for i = 2, #tabs do win:spawn_tab({ args = tabs[i] }) end
    local gui = win:gui_window()
    if gui then pcall(function() gui:set_position(0, 0) end) end
end)
LUA
}

write_config() {
    local path="$1" configured="$2"
    {
        if [ "$configured" = yes ]; then
            printf 'local SP = "%s/home/private_dot_config/wezterm"\n' "$REPO"
            printf 'package.path = SP .. "/?.lua;" .. SP .. "/?/init.lua;" .. package.path\n'
        fi
        printf 'local wezterm = require("wezterm")\n'
        printf 'local config = wezterm.config_builder()\n'
        if [ "$configured" = yes ]; then
            for m in theme platform keys tabs status; do
                printf 'require("%s").apply(config)\n' "$m"
            done
        fi
        printf 'config.hide_tab_bar_if_only_one_tab = false\n'
        printf 'config.initial_cols = %s\n' "$COLS"
        printf 'config.initial_rows = %s\n' "$ROWS"
        demo_tabs
        printf 'return config\n'
    } > "$path"
}

capture() {
    local cfg="$1" out="$2" label="$3" width="${4:-$W}"
    pkill -f "$WORK" 2>/dev/null || true
    sleep 1
    open -na WezTerm --args --config-file "$cfg" start --always-new-process
    sleep "$SETTLE"
    screencapture -x -R"0,$Y,$width,$H" "$out"
    pkill -f "$WORK" 2>/dev/null || true
    echo "  $label -> $out"
}

case "${1:-}" in
    tab-bar)
        mkdir -p "$REPO/assets/showcase"
        write_config "$WORK/stock.lua" no
        write_config "$WORK/configured.lua" yes
        echo "Capturing tab-bar showcase (${COLS}x${ROWS}):"
        # The stock window has a title bar above its tabs; this configuration
        # puts window controls in the tab bar itself, so the two sit at
        # different heights.
        # Stock uses the system font, so its window is narrower than the
        # configured one at the same column count.
        Y=$((Y + 34)) capture "$WORK/stock.lua" "$REPO/assets/showcase/tab-bar-default.png" "stock    " "${SHOWCASE_W_STOCK:-1000}"
        capture "$WORK/configured.lua" "$REPO/assets/showcase/tab-bar-configured.png" "configured"
        echo "Check both images before committing."
        ;;
    *)
        echo "usage: $(basename "$0") tab-bar" >&2
        exit 2
        ;;
esac
