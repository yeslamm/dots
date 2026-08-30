#!/usr/bin/env bash
# ~/.config/sway/scripts/power-watcher.sh

set -euo pipefail

LAST_STATE=""
IDLE_FLAG="${XDG_RUNTIME_DIR:-/run/user/${UID}}/IDLE_ENABLED"

is_on_ac() {
    local f status
    for f in /sys/class/power_supply/BAT*/status; do
        [[ -r "$f" ]] || continue
        read -r status <"$f" 2>/dev/null || true
        [[ "$status" == "Discharging" ]] && return 1
    done
    return 0
}

upower --monitor | grep --line-buffered -E "device changed|power_supply" | while read -r _; do
    if [[ -f "$IDLE_FLAG" ]]; then
        if is_on_ac; then
            CURR_STATE="AC"
        else
            CURR_STATE="BAT"
        fi

        if [[ "$CURR_STATE" != "$LAST_STATE" ]]; then
            LAST_STATE="$CURR_STATE"
            "$HOME/.config/sway/scripts/idle-mgr.sh" on
        fi
    fi
done
