#!/bin/bash
# Lock-NS: Synchronous Blocking Lock (No Suspend)

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
FLAG="$RUNTIME_DIR/IDLE_INHIBIT"

# Tell Sentry to stand down and kill standard auto-idle
touch "$FLAG"
killall swayidle 2>/dev/null

# Start temporary aggressive idle for screen off (5 seconds)
swayidle -w timeout 5 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' &
TEMP_IDLE=$!

# Update Waybar UI to show Paused
pkill -RTMIN+12 waybar

# Run swaylock synchronously (Blocks here until unlocked)
swaylock

# --- UNLOCKED ---
kill $TEMP_IDLE 2>/dev/null
sleep 0.2
swaymsg "output * power on"
rm -f "$FLAG"
~/.config/sway/scripts/start_idle.sh &
pkill -RTMIN+12 waybar || true
