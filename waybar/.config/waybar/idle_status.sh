#!/bin/bash
# waybar's idle_status.sh

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
PID_FILE="$RUNTIME_DIR/idle-mgr.pid"
STATE_FILE="$RUNTIME_DIR/idle-mgr.state"

# Use bash builtins to avoid forking 'cat' or 'kill' unnecessarily
if [[ ! -f "$PID_FILE" ]]; then
    printf '{"text":"IDLE: OFF","class":"idle-stopped", "tooltip": "Idle manager is not running."}\n'
    exit 0
fi

# Reading file into variable via builtin
PID=$(<"$PID_FILE")
if [[ -z "$PID" ]] || ! kill -0 "$PID" 2>/dev/null; then
    printf '{"text":"IDLE: OFF","class":"idle-stopped", "tooltip": "Idle manager is not running."}\n'
    exit 0
fi

# Use builtin to read state and reason
STATE=$(<"$STATE_FILE")
REASON=""
[[ -f "${STATE_FILE}.reason" ]] && REASON=$(<"${STATE_FILE}.reason")

# Tooltip: Check if native inhibitor is running
NATIVE_RUNNING="OFF"
pgrep -f wayland-pipewire-idle-inhibit >/dev/null 2>&1 && NATIVE_RUNNING="ON"

# Escape reason for JSON (minimalist)
REASON="${REASON//\"/\\\"}"

case "$STATE" in
"ON")
    printf '{"text":"IDLE: ON", "class":"idle-active", "tooltip":"Idle management is active.\\nNative Inhibitor: %s"}\n' "$NATIVE_RUNNING"
    ;;
"HOLD")
    printf '{"text":"IDLE: HOLD", "class":"idle-inhibited", "tooltip":"Inhibited by: %s\\nNative Inhibitor: %s"}\n' "$REASON" "$NATIVE_RUNNING"
    ;;
"PAUSED")
    printf '{"text":"IDLE: PAUSE", "class":"idle-paused", "tooltip":"Idle management is manually paused.\\nNative Inhibitor: %s"}\n' "$NATIVE_RUNNING"
    ;;
"LOCKED")
    printf '{"text":"IDLE: LCKD", "class":"idle-locked", "tooltip":"Locked. Sentry Active.\\nNative Inhibitor: %s"}\n' "$NATIVE_RUNNING"
    ;;
*)
    printf '{"text":"IDLE: OFF", "class":"idle-stopped", "tooltip":"Initializing..."}\n'
    ;;
esac
