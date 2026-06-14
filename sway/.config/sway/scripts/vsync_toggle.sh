#!/usr/bin/env bash

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
STATE_FILE="$RUNTIME_DIR/vsync-flag"

if [ ! -f "$STATE_FILE" ]; then
    CURRENT_STATE="on"
else
    CURRENT_STATE=$(<"$STATE_FILE")
fi

if [ "$CURRENT_STATE" = "on" ]; then
    swaymsg "output * allow_tearing yes; output * max_render_time off"
    echo "off" >"$STATE_FILE"
    notify-send -t 2000 -h string:x-canonical-private-synchronous:vsync "Vsync: OFF"
else
    swaymsg "output * allow_tearing no; output * max_render_time 3"
    echo "on" >"$STATE_FILE"
    notify-send -t 2000 -h string:x-canonical-private-synchronous:vsync "Vsync: ON"
fi
