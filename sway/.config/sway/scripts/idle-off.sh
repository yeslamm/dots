#!/bin/bash
# idle-off.sh - "UNIX Graceful Exit"

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
PID_FILE="$RUNTIME_DIR/idle-mgr.pid"

WAYBAR_SIGNAL=12

# Stop manager
if [[ -f "$PID_FILE" ]]; then
    PID=$(<"$PID_FILE")
    [[ -n "$PID" ]] && kill -TERM "$PID" 2>/dev/null
else
    pkill -TERM -f "idle-mgr.sh" 2>/dev/null || true
fi

# Force Waybar OFF
rm -f "$RUNTIME_DIR/idle-mgr.state"
pkill -RTMIN+$WAYBAR_SIGNAL waybar 2>/dev/null || true

notify-send -t 1000 -h string:x-canonical-private-synchronous:idlemgr " Idle Manager: Fully Stopped"
