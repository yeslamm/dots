#!/bin/bash

###############################################################################
# SWAY PROTECTIVE SENTRY (The "Bag-Safe" Timer)
###############################################################################

# 1. MEMORY: Check state
if pgrep -f "idle-mgr.sh" >/dev/null; then
    WAS_MANAGER_RUNNING=true
    pkill -f "idle-mgr.sh"
else
    WAS_MANAGER_RUNNING=false
fi

# 2. TRAP: Ensure the manager is restored on ANY exit (success, crash, or kill)
cleanup() {
    if [ "$WAS_MANAGER_RUNNING" = true ]; then
        # Check if it's already running to avoid duplicates
        pgrep -f "idle-mgr.sh" >/dev/null || ~/.config/sway/scripts/idle-mgr.sh &
    fi
    exit 0
}
trap cleanup EXIT INT TERM

# Initial stabilization
sleep 3
read -r START_UPTIME _ </proc/uptime
START_UPTIME=${START_UPTIME%.*}

while true; do
    # CHECK: Did the user unlock?
    # If unlocked, script exits and 'trap' restores the manager if needed.
    if ! pgrep -x "swaylock" >/dev/null; then
        exit 0
    fi

    # Calculate real-world "awake" time via kernel uptime
    read -r CURRENT_UPTIME _ </proc/uptime
    CURRENT_UPTIME=${CURRENT_UPTIME%.*}
    AWAKE_TIME=$((CURRENT_UPTIME - START_UPTIME))

    # Safety Net: 30 seconds of being awake while locked
    if [ "$AWAKE_TIME" -ge 30 ]; then
        # Final safety check: still locked?
        if pgrep -x "swaylock" >/dev/null; then
            systemctl suspend
            # Allow system time to fall asleep and wake up stabilization
            sleep 5
            # RESET: Update the starting point to current uptime after waking up.
            read -r CURRENT_UPTIME _ </proc/uptime
            START_UPTIME=${CURRENT_UPTIME%.*}
        fi
    fi

    # Poll every 1s (Optimized balance between responsiveness and battery)
    sleep 1
done

