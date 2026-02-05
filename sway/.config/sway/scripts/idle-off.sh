#!/bin/bash
# idle-off.sh - High-Speed Surgical Stop

MANAGER_PID_FILE="/dev/shm/idle-mgr.pid"
STATE_FILE="/dev/shm/idle-mgr.state"

# 1. Kill the manager by its specific PID
if [ -f "$MANAGER_PID_FILE" ]; then
    PID=$(cat "$MANAGER_PID_FILE")
    if [ -n "$PID" ]; then
        kill -9 "$PID" 2>/dev/null
    fi
fi

# 2. Cleanup state but DO NOT delete the PID file (keep flock stable)
truncate -s 0 "$MANAGER_PID_FILE"
rm -f "$STATE_FILE"

# 3. Aggressive fallback for any remaining instances
# This ensures that even if the PID file was wrong, they all die.
pgrep -f "idle-mgr.sh" | grep -v "^$$" | xargs kill -9 2>/dev/null
pkill -x swayidle

# 4. Signal Waybar
pkill -SIGRTMIN+8 waybar

notify-send -t 1000 "Idle processes stopped"
