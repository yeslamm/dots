#!/bin/bash
# sentry.sh - Production Grade
# Robust signaling with live PID re-discovery in the cleanup trap.

MANAGER_PID_FILE="/dev/shm/idle-mgr.pid"

# 1. Initial Signaling
if [ -f "$MANAGER_PID_FILE" ]; then
    CURRENT_PID=$(cat "$MANAGER_PID_FILE")
    [ -n "$CURRENT_PID" ] && kill -SIGUSR1 "$CURRENT_PID" 2>/dev/null
fi

# 2. Cleanup Trap (Live PID discovery)
cleanup() {
    if [ -f "$MANAGER_PID_FILE" ]; then
        LIVE_PID=$(cat "$MANAGER_PID_FILE")
        [ -n "$LIVE_PID" ] && kill -SIGUSR1 "$LIVE_PID" 2>/dev/null
    fi
    exit 0
}
trap cleanup EXIT INT TERM

sleep 3
read -r START_UPTIME _ </proc/uptime
START_UPTIME=${START_UPTIME%.*}

while true; do
    if ! pgrep -x "swaylock" >/dev/null; then
        exit 0
    fi

    read -r CURRENT_UPTIME _ </proc/uptime
    CURRENT_UPTIME=${CURRENT_UPTIME%.*}
    AWAKE_TIME=$((CURRENT_UPTIME - START_UPTIME))

    if [ "$AWAKE_TIME" -ge 30 ]; then
        if pgrep -x "swaylock" >/dev/null; then
            systemctl suspend
            sleep 5
            read -r CURRENT_UPTIME _ </proc/uptime
            START_UPTIME=${CURRENT_UPTIME%.*}
        fi
    fi
    sleep 1
done