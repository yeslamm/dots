#!/bin/bash
# lock-ns.sh

# 1. Save State & Stop Main Idle Manager
MANAGER_PID_FILE="/dev/shm/idle-mgr.pid"
if [ -f "$MANAGER_PID_FILE" ] && kill -0 "$(cat "$MANAGER_PID_FILE")" 2>/dev/null; then
    WAS_MANAGER_RUNNING=true
    pkill -f "idle-mgr.sh"
    pkill -x swayidle
else
    WAS_MANAGER_RUNNING=false
fi

# 2. Cleanup Trap (Runs on Unlock)
cleanup() {
    if [ -n "$TEMP_SWAYIDLE_PID" ]; then
        kill "$TEMP_SWAYIDLE_PID" 2>/dev/null
    fi
    swaymsg "output * dpms on"

    if [ "$WAS_MANAGER_RUNNING" = true ]; then
        # Check if it's already running to avoid duplicates
        pgrep -f "idle-mgr.sh" >/dev/null || ~/.config/sway/scripts/idle-mgr.sh &
    fi
    exit 0
}
trap cleanup EXIT INT TERM

# 3. Lock the Screen FIRST
swaylock -f -c 000000 -F -e -k -L

# 4. Start Temporary Swayidle (DPMS ONLY)
swayidle -w \
    timeout 5 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' &
TEMP_SWAYIDLE_PID=$!

# 5. Wait for Swaylock
while pgrep -x "swaylock" >/dev/null; do
    sleep 0.5
done