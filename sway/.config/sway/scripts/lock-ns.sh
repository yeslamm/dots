#!/bin/bash
# lock-ns.sh - Force Pause while locking, then resume.

PID_FILE="/dev/shm/idle-mgr.pid"

# 1. Force Pause
if [ -f "$PID_FILE" ]; then
    CURRENT_PID=$(cat "$PID_FILE")
    [ -n "$CURRENT_PID" ] && kill -SIGUSR1 "$CURRENT_PID" 2>/dev/null
fi

cleanup() {
    [ -n "$TEMP_SWAYIDLE_PID" ] && kill "$TEMP_SWAYIDLE_PID" 2>/dev/null
    swaymsg "output * dpms on"
    
    # 2. Force Resume
    if [ -f "$PID_FILE" ]; then
        LIVE_PID=$(cat "$PID_FILE")
        [ -n "$LIVE_PID" ] && kill -SIGUSR2 "$LIVE_PID" 2>/dev/null
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