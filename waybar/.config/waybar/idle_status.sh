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
    jq -nc --arg t "IDLE: ON" --arg d "Idle management is active." '{"text":$t, "class":"idle-active", "tooltip":$d}'
    ;;
"HOLD")
    jq -nc --arg t "IDLE: HOLD" --arg d "Inhibited by: $REASON" '{"text":$t, "class":"idle-inhibited", "tooltip":$d}'
    ;;
"PAUSED")
    jq -nc --arg t "IDLE: PAUSE" --arg d "Idle management is manually paused." '{"text":$t, "class":"idle-paused", "tooltip":$d}'
    ;;
"LOCKED")
    jq -nc --arg t "IDLE: LCKD" --arg d "Locked. Will re-suspend in < 30s if not unlocked." '{"text":$t, "class":"idle-locked", "tooltip":$d}'
    ;;
*)
    jq -nc --arg t "IDLE: OFF" --arg d "Initializing..." '{"text":$t, "class":"idle-stopped", "tooltip":$d}'
    ;;
esac
