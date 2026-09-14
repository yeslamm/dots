#!/usr/bin/env bash
# ~/dots/desktop/.config/sway/scripts/power/lock.sh

set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/run/user/${UID}}/sway-power"
[[ -d "$STATE_DIR" ]] || mkdir -p "$STATE_DIR"
IDLE_FLAG="$STATE_DIR/idle_enabled"
INHIBIT_FLAG="$STATE_DIR/idle_inhibit"

WAS_IDLE_ACTIVE=false
[[ -f "$IDLE_FLAG" ]] && WAS_IDLE_ACTIVE=true

cleanup() {
    rm -f "$INHIBIT_FLAG"
    swaymsg "output * power on" 2>/dev/null || true
    pkill -x swayidle 2>/dev/null || true

    if [[ "$WAS_IDLE_ACTIVE" == true ]]; then
        "$HOME/.config/sway/scripts/power/idle-mgr.sh" on
    fi

    pkill -RTMIN+12 waybar 2>/dev/null || true
}
trap cleanup EXIT

touch "$INHIBIT_FLAG"
pkill -x swayidle 2>/dev/null || true

swayidle -w timeout 5 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' &

pkill -RTMIN+12 waybar 2>/dev/null || true
swaylock
