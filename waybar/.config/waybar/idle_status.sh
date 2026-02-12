#!/bin/bash
# waybar's idle_status.sh

PID_FILE="/dev/shm/idle-mgr.pid"
STATE_FILE="/dev/shm/idle-mgr.state"

# Use bash builtins to avoid forking 'cat' or 'kill' unnecessarily
if [[ ! -f "$PID_FILE" ]]; then
    echo '{"text":"IDLE: OFF","class":"idle-stopped", "tooltip": "Idle manager is not running."}'
    exit 0
fi

# Reading file into variable via builtin
PID=$(<"$PID_FILE")
if [[ -z "$PID" ]] || ! kill -0 "$PID" 2>/dev/null; then
    echo '{"text":"IDLE: OFF","class":"idle-stopped", "tooltip": "Idle manager is not running."}'
    exit 0
fi

# Use builtin to read state
STATE=$(<"$STATE_FILE")

case "$STATE" in
"ON")
    echo '{"text":"IDLE: ON","class":"idle-active", "tooltip": "Idle management is active."}'
    ;;
"HOLD")
    echo '{"text":"IDLE: HOLD","class":"idle-inhibited", "tooltip": "Idle is inhibited by a running application."}'
    ;;
"PAUSED")
    echo '{"text":"IDLE: PAUSE","class":"idle-paused", "tooltip": "Idle management is paused."}'
    ;;
"LOCKED")
    echo '{"text":"IDLE: LCKD","class":"idle-locked", "tooltip": "Locked. Will re-suspend in < 30s if not unlocked."}'
    ;;
*)
    echo '{"text":"IDLE: ...","class":"idle-stopped", "tooltip": "Initializing..."}'
    ;;
esac
