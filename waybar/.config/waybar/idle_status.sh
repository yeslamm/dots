#!/bin/bash
# waybar's idle_status.sh

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
PID_FILE="$RUNTIME_DIR/idle-mgr.pid"
STATE_FILE="$RUNTIME_DIR/idle-mgr.state"

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

# Use builtin to read state and reason
STATE=$(<"$STATE_FILE")
REASON=""
[[ -f "${STATE_FILE}.reason" ]] && REASON=$(<"${STATE_FILE}.reason")

case "$STATE" in
"ON")
    echo '{"text":"IDLE: ON","class":"idle-active", "tooltip": "Idle management is active."}'
    ;;
"HOLD")
    echo "{\"text\":\"IDLE: HOLD\",\"class\":\"idle-inhibited\", \"tooltip\": \"Inhibited by: $REASON\"}"
    ;;
"PAUSED")
    echo '{"text":"IDLE: PAUSE","class":"idle-paused", "tooltip": "Idle management is manually paused."}'
    ;;
"LOCKED")
    echo '{"text":"IDLE: LCKD","class":"idle-locked", "tooltip": "Locked. Will re-suspend in < 30s if not unlocked."}'
    ;;
*)
    echo '{"text":"IDLE: OFF","class":"idle-stopped", "tooltip": "Initializing..."}'
    ;;
esac
