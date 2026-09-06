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
# Look on PATH first: Homebrew, MacPorts and a source build all put wezterm
# there, and the app bundle is only one valid location. Override with
# WEZTERM=/path/to/wezterm.
find_wezterm() {
    [ -n "${WEZTERM:-}" ] && { printf '%s' "$WEZTERM"; return; }
    command -v wezterm 2>/dev/null && return
    for c in /Applications/WezTerm.app/Contents/MacOS/wezterm \
             "$HOME/Applications/WezTerm.app/Contents/MacOS/wezterm"; do
        [ -x "$c" ] && { printf '%s' "$c"; return; }
    done
}
WEZTERM="$(find_wezterm)"

# Resolved at run time so the demo does not depend on one machine's layout.
SHELL_BIN="$(command -v zsh || command -v bash || echo /bin/sh)"
MONITOR_BIN="$(command -v btop || command -v htop || command -v top || echo "$SHELL_BIN")"
WORK="$(mktemp -d)"
trap 'pkill -f "$WORK" 2>/dev/null || true; rm -rf "$WORK"' EXIT

COLS="${SHOWCASE_COLS:-150}"
ROWS="${SHOWCASE_ROWS:-20}"
Y="${SHOWCASE_Y:-34}"
H="${SHOWCASE_H:-28}"
W="${SHOWCASE_W:-1270}"
SETTLE="${SHOWCASE_SETTLE:-7}"

if [ -z "$WEZTERM" ] || [ ! -x "$WEZTERM" ]; then
    echo "wezterm not found. Put it on PATH or set WEZTERM=/path/to/wezterm" >&2
    exit 1
fi

# screencapture and `open -na` are macOS-only, so only this tool is limited —
# the configuration it captures is cross-platform.
case "$(uname -s)" in
    Darwin) ;;
    *) echo "$(basename "$0") needs macOS: it uses screencapture and open." >&2; exit 1 ;;
esac

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
        { "@@SHELL@@", "-f" },
        { "@@MONITOR@@" },
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
        demo_tabs | sed -e "s|@@SHELL@@|$SHELL_BIN|g" -e "s|@@MONITOR@@|$MONITOR_BIN|g"
        printf 'return config\n'
    } > "$path"
}

# Name of the frontmost application. screencapture takes a screen region, so
# anything in front of that region lands in the image instead — twice during
# development that silently wrote another window over a committed asset.
front_app() {
    lsappinfo info -only name "$(lsappinfo front 2>/dev/null)" 2>/dev/null \
        | sed -n 's/.*"LSDisplayName"="\([^"]*\)".*/\1/p'
}

capture() {
    local cfg="$1" out="$2" label="$3" width="${4:-$W}"
    local staged="$WORK/$(basename "$out")"
    STAGED_PAIRS="$STAGED_PAIRS$staged|$out
"

    pkill -f "$WORK" 2>/dev/null || true
    sleep 1
    open -na WezTerm --args --config-file "$cfg" start --always-new-process
    sleep "$SETTLE"

    # screencapture grabs a screen region, not a window. Without this check a
    # failed or slow launch silently writes whatever else was on screen over a
    # committed asset — during development that produced a browser window and
    # an unrelated app before anyone noticed.
    local pid
    pid="$(pgrep -f "$cfg" | head -1)"
    if [ -z "$pid" ]; then
        echo "  $label: WezTerm did not start; leaving $out untouched" >&2
        return 1
    fi

    local front
    front="$(front_app)"
    if [ "$front" != "WezTerm" ]; then
        echo "  $label: $front is in front, not WezTerm; leaving $out untouched" >&2
        pkill -f "$WORK" 2>/dev/null || true
        return 1
    fi

    # Capture to the work directory first, and only install over the committed
    # asset once there is something to install.
    screencapture -x -R"0,$Y,$width,$H" "$staged"
    pkill -f "$WORK" 2>/dev/null || true

    if [ ! -s "$staged" ]; then
        echo "  $label: capture produced nothing; leaving $out untouched" >&2
        return 1
    fi

    echo "  $label captured"
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
        failed=0
        STAGED_PAIRS=""
        Y=$((Y + 34)) capture "$WORK/stock.lua" "$REPO/assets/showcase/tab-bar-default.png" "stock    " "${SHOWCASE_W_STOCK:-1000}" || failed=1
        capture "$WORK/configured.lua" "$REPO/assets/showcase/tab-bar-configured.png" "configured" || failed=1
        # All or nothing: a half-updated pair is worse than none, since the
        # two images are only meaningful side by side.
        if [ "$failed" -ne 0 ]; then
            echo "A capture failed; both images were left as they were." >&2
            exit 1
        fi
        printf '%s' "$STAGED_PAIRS" | while IFS='|' read -r staged out; do
            [ -n "$staged" ] && mv "$staged" "$out"
        done
        echo "Look at both images before committing."
        ;;
    *)
        echo "usage: $(basename "$0") tab-bar" >&2
        exit 2
        ;;
esac
