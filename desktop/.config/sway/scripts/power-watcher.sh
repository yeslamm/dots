#!/usr/bin/env bash
# ~/.config/sway/scripts/power-watcher.sh

set -euo pipefail

LAST_STATE=""

upower --monitor | grep --line-buffered -E "device changed|power_supply" | while read -r _; do

    if [[ -f "${XDG_RUNTIME_DIR:-/run/user/${UID}}/IDLE_ENABLED" ]]; then
        if grep -q "Discharging" /sys/class/power_supply/BAT*/status 2>/dev/null; then
            CURR_STATE="BAT"
        else
            CURR_STATE="AC"
        fi

        if [[ "$CURR_STATE" != "$LAST_STATE" ]]; then
            LAST_STATE="$CURR_STATE"
            "$HOME/.config/sway/scripts/idle-mgr.sh" on
        fi
    fi
done
