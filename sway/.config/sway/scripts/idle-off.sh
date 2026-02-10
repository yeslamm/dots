#!/bin/bash
# idle-off.sh - Aggressive stop

PID_FILE="/dev/shm/idle-mgr.pid"
STATE_FILE="/dev/shm/idle-mgr.state"
LOCK_FILE="/dev/shm/idle-mgr.lock"
WAYBAR_SIGNAL=9

# 1. Kill the manager via PID file
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    kill "$PID" 2>/dev/null
fi

# 2. Aggressive cleanup of any stragglers
pkill -f "idle-mgr.sh"
pkill -x swayidle

sleep 0.1

# 3. Wipe state
rm -f "$PID_FILE" "$STATE_FILE" "$LOCK_FILE"

# 4. Refresh Waybar
pkill -RTMIN+$WAYBAR_SIGNAL waybar

notify-send -t 1000 -h string:x-canonical-private-synchronous:state "Idle Manager" "Fully Stopped"
