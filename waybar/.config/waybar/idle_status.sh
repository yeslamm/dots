#!/bin/bash
# waybar's idle_status.sh

PID_FILE="/dev/shm/idle-mgr.pid"
STATE_FILE="/dev/shm/idle-mgr.state"

is_manager_running() {
    [ -f "$PID_FILE" ] && pid=$(cat "$PID_FILE" 2>/dev/null) &&
        [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

if ! is_manager_running; then
    echo '{"text":"IDLE: OFF","class":"idle-stopped", "tooltip": "Idle manager is not running."}'
    exit 0
fi

STATE=$(cat "$STATE_FILE" 2>/dev/null)

if [ "$STATE" = "ON" ]; then
    echo '{"text":"IDLE: ON","class":"idle-active", "tooltip": "Idle management is active."}'
elif [ "$STATE" = "HOLD" ]; then
    echo '{"text":"IDLE: HOLD","class":"idle-inhibited", "tooltip": "Idle is inhibited by a running application."}'
elif [ "$STATE" = "PAUSED" ]; then
    echo '{"text":"IDLE: PAUSE","class":"idle-paused", "tooltip": "Idle management is paused."}'
else
    echo '{"text":"IDLE: ...","class":"idle-stopped", "tooltip": "Initializing..."}'
fi
