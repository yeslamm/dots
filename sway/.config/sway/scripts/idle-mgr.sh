#!/usr/bin/env bash
# ~/dots/sway/.config/sway/scripts/idle-mgr.sh

set -euo pipefail

ACTION="${1:-}"
START_IDLE="$HOME/.config/sway/scripts/start-idle.sh"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
IDLE_FLAG="$RUNTIME_DIR/IDLE_ENABLED"

case "$ACTION" in
on)
    touch "$IDLE_FLAG"
    if ! pgrep -x swayidle >/dev/null; then
        "$START_IDLE"
    fi
    ;;
off)
    rm -f "$IDLE_FLAG"
    killall -q swayidle -u "$USER" || true
    pkill -RTMIN+12 waybar || true
    ;;
toggle)
    if [ -f "$IDLE_FLAG" ]; then
        "$0" off
        notify-send -t 1500 -h string:x-canonical-private-synchronous:idlemgr 'IDLE: OFF'
    else
        "$0" on
        notify-send -t 1500 -h string:x-canonical-private-synchronous:idlemgr 'IDLE: ON'
    fi
    ;;
*)
    echo "Usage: $0 {on|off|toggle}"
    exit 1
    ;;
esac
