#!/usr/bin/env bash

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
FLAG="$RUNTIME_DIR/IDLE_INHIBIT"
IDLE_FLAG="$RUNTIME_DIR/IDLE_ENABLED"

# Use the Intent Flag to decide if we should restore idle on unlock
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
           ~/.config/sway/scripts/start_idle.sh &
       fi

       pkill -RTMIN+12 waybar 2>/dev/null
   ' EXIT

touch "$FLAG"
killall swayidle 2>/dev/null

# Temporary swayidle for the lock screen duration
swayidle -w timeout 5 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' &

pkill -RTMIN+12 waybar 2>/dev/null
swaylock
