#!/usr/bin/env bash
set -euo pipefail

ACTION=$(echo "$1" | tr '[:lower:]' '[:upper:]')
START_IDLE="$HOME/.config/sway/scripts/start_idle.sh"

case "$ACTION" in
ON)
    if ! pgrep -x swayidle >/dev/null; then
        "$START_IDLE"
    fi
    notify-send -t 1500 -h string:x-canonical-private-synchronous:idlemgr 'IDLE: ON'
    pkill -RTMIN+12 waybar || true
    ;;
OFF)
    killall -q swayidle -u "$USER" || true
    notify-send -t 1500 -h string:x-canonical-private-synchronous:idlemgr 'IDLE: OFF'
    pkill -RTMIN+12 waybar || true
    ;;
TOGGLE)
    if pgrep -x swayidle >/dev/null; then
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
