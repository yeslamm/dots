#!/bin/bash
# lock-ns.sh - Production Grade
# Robust signaling with live PID re-discovery in the cleanup trap.

MANAGER_PID_FILE="/dev/shm/idle-mgr.pid"

# 1. Initial Signaling
if [ -f "$MANAGER_PID_FILE" ]; then
    CURRENT_PID=$(cat "$MANAGER_PID_FILE")
    [ -n "$CURRENT_PID" ] && kill -SIGUSR1 "$CURRENT_PID" 2>/dev/null
fi

# 2. Cleanup Trap (Live PID discovery)
cleanup() {
    # 1. Turn screen back on
    [ -n "$TEMP_SWAYIDLE_PID" ] && kill "$TEMP_SWAYIDLE_PID" 2>/dev/null
    swaymsg "output * dpms on"
    
    # 2. Re-read PID file to signal the CURRENT manager (in case it restarted)
    if [ -f "$MANAGER_PID_FILE" ]; then
        LIVE_PID=$(cat "$MANAGER_PID_FILE")
        [ -n "$LIVE_PID" ] && kill -SIGUSR1 "$LIVE_PID" 2>/dev/null
    fi
    exit 0
}
trap cleanup EXIT INT TERM

swaylock -f -c 000000 -F -e -k -L

swayidle -w \
    timeout 5 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' &
TEMP_SWAYIDLE_PID=$!

while pgrep -x "swaylock" >/dev/null; do
    sleep 0.5
done
