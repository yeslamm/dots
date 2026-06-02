#!/bin/bash
# Lock-NS: Synchronous Blocking Lock (No Suspend)

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
FLAG="$RUNTIME_DIR/IDLE_INHIBIT"

if pgrep -x "swayidle" >/dev/null; then
    WAS_IDLE_ACTIVE=true
else
    WAS_IDLE_ACTIVE=false
fi

trap '
    rm -f "$FLAG"
    swaymsg "output * power on"

    killall swayidle 2>/dev/null

    if [ "$WAS_IDLE_ACTIVE" = true ]; then
        ~/.config/sway/scripts/start_idle.sh &
    fi

    pkill -RTMIN+12 waybar
' EXIT

touch "$FLAG"
killall swayidle 2>/dev/null

swayidle -w timeout 5 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' &

pkill -RTMIN+12 waybar
swaylock
