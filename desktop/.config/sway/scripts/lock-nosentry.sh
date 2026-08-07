#!/usr/bin/env bash
# ~/dots/desktop/.config/sway/scripts/lock-nosentry.sh

set -euo pipefail

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/${UID}}"
FLAG="$RUNTIME_DIR/IDLE_INHIBIT"
IDLE_FLAG="$RUNTIME_DIR/IDLE_ENABLED"

WAS_IDLE_ACTIVE=false
[[ -f "$IDLE_FLAG" ]] && WAS_IDLE_ACTIVE=true

cleanup() {
    rm -f "$FLAG"
    swaymsg "output * power on" 2>/dev/null || true
    pkill -x swayidle 2>/dev/null || true

    if [[ "$WAS_IDLE_ACTIVE" == true ]]; then
        "$HOME/.config/sway/scripts/idle-mgr.sh" on
    fi

    pkill -RTMIN+12 waybar 2>/dev/null || true
}
trap cleanup EXIT

touch "$FLAG"
pkill -x swayidle 2>/dev/null || true

swayidle -w timeout 5 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' &

pkill -RTMIN+12 waybar 2>/dev/null || true
swaylock
