#!/bin/bash
# Lock-NS: Synchronous Blocking Lock (No Suspend)

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
FLAG="$RUNTIME_DIR/lock-ns-active"

# Tell Sentry to stand down and kill standard auto-idle
touch "$FLAG"
killall swayidle 2>/dev/null

# Start temporary aggressive idle for screen off (5 seconds)
swayidle -w timeout 5 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' &
TEMP_IDLE=$!

# Update Waybar UI to show Paused
pkill -RTMIN+12 waybar

# Run swaylock synchronously (Blocks here until unlocked)
swaylock -c 000000 -F -e -k -L

# --- UNLOCKED ---
kill $TEMP_IDLE 2>/dev/null
sleep 0.2
swaymsg "output * dpms on"
rm -f "$FLAG"
~/.config/sway/scripts/start_idle.sh &
pkill -RTMIN+12 waybar || true
