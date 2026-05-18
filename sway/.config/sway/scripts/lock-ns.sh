#!/bin/bash
# Lock-NS: Synchronous Blocking Lock (No Suspend)

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
FLAG="$RUNTIME_DIR/IDLE_INHIBIT"

trap 'rm -f "$FLAG"; swaymsg "output * power on"; ~/.config/sway/scripts/start_idle.sh &' EXIT

touch "$FLAG"
killall swayidle 2>/dev/null

swayidle -w timeout 5 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' &

pkill -RTMIN+12 waybar
swaylock
