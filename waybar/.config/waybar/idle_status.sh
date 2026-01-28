#!/bin/bash
# waybar's idle_status.sh
# This script checks the status of swayidle for Waybar.
# Uses explicit state file for race-free updates.

MANAGER_PID_FILE="/dev/shm/idle-mgr.pid"
STATE_FILE="/dev/shm/idle-mgr.state"

# Check if manager is running
is_manager_running() {
    [ -f "$MANAGER_PID_FILE" ] && pid=$(cat "$MANAGER_PID_FILE" 2>/dev/null) &&
        [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

if ! is_manager_running; then
    echo '{"text":"IDLE: OFF","class":"idle-stopped", "tooltip": "Idle manager is not running."}'
    exit 0
fi

# Read explicit state
STATE=$(cat "$STATE_FILE" 2>/dev/null)

if [ "$STATE" = "ON" ]; then
    echo '{"text":"IDLE: ON","class":"idle-active", "tooltip": "Idle management is active."}'
elif [ "$STATE" = "HOLD" ]; then
    echo '{"text":"IDLE: HOLD","class":"idle-inhibited", "tooltip": "Idle is inhibited by a running application."}'
else
    # Manager is running but initializing (State file not yet written)
    # Return "OFF" or "..." to prevent "HOLD" flicker.
    echo '{"text":"IDLE: OFF","class":"idle-stopped", "tooltip": "Idle manager initializing..."}'
fi