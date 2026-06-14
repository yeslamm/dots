#!/usr/bin/env bash
# ~/dots/sway/.config/sway/scripts/lock-ns.sh

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
FLAG="$RUNTIME_DIR/IDLE_INHIBIT"
IDLE_FLAG="$RUNTIME_DIR/IDLE_ENABLED"

if [[ -f "$IDLE_FLAG" ]]; then
    WAS_IDLE_ACTIVE=true
else
    WAS_IDLE_ACTIVE=false
fi

trap '
       rm -f "$FLAG"
       swaymsg "output * power on" 2>/dev/null

       killall swayidle 2>/dev/null

       if [ "$WAS_IDLE_ACTIVE" = true ]; then
           ~/.config/sway/scripts/start-idle.sh &
       fi

       pkill -RTMIN+12 waybar 2>/dev/null
   ' EXIT

touch "$FLAG"
killall swayidle 2>/dev/null

swayidle -w timeout 5 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' &

pkill -RTMIN+12 waybar 2>/dev/null
swaylock
