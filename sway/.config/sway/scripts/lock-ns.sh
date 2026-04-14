#!/bin/bash
# lock-ns.sh - "Synchronous Blocking Edition"
# Standardized paths and zero-polling architecture.

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
PID_FILE="$RUNTIME_DIR/idle-mgr.pid"

# 1. Force Pause the manager
if [ -f "$PID_FILE" ]; then
    CURRENT_PID=$(cat "$PID_FILE")
    [ -n "$CURRENT_PID" ] && kill -SIGUSR1 "$CURRENT_PID" 2>/dev/null
fi

# Note: We do NOT kill wayland-pipewire-idle-inhibit here.
# This means music will keep the screen awake while locked (intended).
# However, Sentry in idle-mgr.sh will still trigger suspend if you lock-and-leave.

cleanup() {
    # Surgical Cleanup: Kill only swayidle started by this script
    [ -n "${TEMP_SWAYIDLE_PID:-}" ] && kill "$TEMP_SWAYIDLE_PID" 2>/dev/null && wait "$TEMP_SWAYIDLE_PID" 2>/dev/null || true
    pkill -P "$$" swayidle 2>/dev/null || true
    
    # Ensure display is back on
    swaymsg "output * dpms on"
    
    # 2. Force Resume the manager
    if [ -f "$PID_FILE" ]; then
        LIVE_PID=$(cat "$PID_FILE" 2>/dev/null || true)
        [ -n "$LIVE_PID" ] && kill -SIGUSR2 "$LIVE_PID" 2>/dev/null
    fi
}
# Trap for cleanup on unlock or if the script is terminated
trap cleanup EXIT INT TERM

# Start temporary aggressive idle in background
swayidle -w \
    timeout 5 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' &
TEMP_SWAYIDLE_PID=$!

# Run swaylock synchronously (WITHOUT -f). 
# The script blocks here until you unlock.
swaylock -c 000000 -F -e -k -L

# On exit, the 'cleanup' trap handles everything.
