#!/usr/bin/env bash
set -euo pipefail

ACTION=$(echo "$1" | tr '[:lower:]' '[:upper:]')
START_IDLE="$HOME/.config/sway/scripts/start_idle.sh"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
IDLE_FLAG="$RUNTIME_DIR/IDLE_ENABLED"

case "$ACTION" in
ON)
    touch "$IDLE_FLAG"
    if ! pgrep -x swayidle >/dev/null; then
        "$START_IDLE"
    fi
    notify-send -t 1500 -h string:x-canonical-private-synchronous:idlemgr 'IDLE: ON'
    pkill -RTMIN+12 waybar || true
    ;;
OFF)
    rm -f "$IDLE_FLAG"
    killall -q swayidle -u "$USER" || true
    notify-send -t 1500 -h string:x-canonical-private-synchronous:idlemgr 'IDLE: OFF'
    pkill -RTMIN+12 waybar || true
    ;;
TOGGLE)
    if [ -f "$IDLE_FLAG" ]; then
        "$0" OFF
    else
        "$0" ON
    fi
    ;;
*)
    echo "Usage: $0 {ON|OFF|TOGGLE}"
    exit 1
    ;;
esac
