#!/bin/bash
# idle-off.sh - Standardized Cleanup

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
PID_FILE="$RUNTIME_DIR/idle-mgr.pid"
STATE_FILE="$RUNTIME_DIR/idle-mgr.state"
REASON_FILE="$STATE_FILE.reason"
LOCK_FILE="$RUNTIME_DIR/idle-mgr.lock"
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
rm -f "$PID_FILE" "$STATE_FILE" "$REASON_FILE" "$LOCK_FILE"

# 4. Refresh Waybar
pkill -RTMIN+$WAYBAR_SIGNAL waybar

notify-send -t 1000 -h string:x-canonical-private-synchronous:state "Idle Manager" "Fully Stopped"
