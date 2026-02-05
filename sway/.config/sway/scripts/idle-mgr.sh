#!/bin/bash
# idle-mgr.sh - Bulletproof Singleton
# Uses a stable lock file that is NEVER deleted to prevent race conditions.

MANAGER_PID_FILE="/dev/shm/idle-mgr.pid"
STATE_FILE="/dev/shm/idle-mgr.state"
INHIBIT_APPS_FILE="$HOME/.config/sway/idle_inhibit_apps"

# --- 1. Aggressive & Stable Singleton ---
# Open the PID file (creating if necessary) and KEEP it open.
exec 9>>"$MANAGER_PID_FILE"

# Try to get the lock. If it fails, another instance is running.
if ! flock -n 9; then
    # Surgical Strike: Kill the current owner of the lock
    OLD_PID=$(cat "$MANAGER_PID_FILE" 2>/dev/null)
    if [ -n "$OLD_PID" ] && [ "$OLD_PID" -ne "$$" ]; then
        kill -9 "$OLD_PID" 2>/dev/null
    fi
    # Wait to acquire the lock
    flock -x 9
fi

# We have the lock. Update the file with our PID.
truncate -s 0 "$MANAGER_PID_FILE"
echo $$ >&9

# --- 2. State & Signal Management ---
PAUSED=false

set_state() {
    echo "$1" > "$STATE_FILE"
    pkill -SIGRTMIN+8 waybar
}

handle_pause() {
    if [ "$PAUSED" = true ]; then
        PAUSED=false
    else
        PAUSED=true
        kill_swayidle
        set_state "PAUSED"
    fi
}

cleanup() {
    # NEVER delete the PID file, just truncate its content.
    truncate -s 0 "$MANAGER_PID_FILE"
    rm -f "$STATE_FILE"
    
    pkill -x swayidle
    pkill -SIGRTMIN+8 waybar
    exit 0
}

trap handle_pause SIGUSR1
trap cleanup EXIT INT TERM

# --- 3. Logic ---

is_swayidle_running() {
    pgrep -x swayidle >/dev/null
}

kill_swayidle() {
    if is_swayidle_running; then
        pkill -x swayidle
        set_state "HOLD"
    fi
    if [ ! -f "$STATE_FILE" ] || { [ "$(cat "$STATE_FILE")" != "HOLD" ] && [ "$PAUSED" = false ]; }; then
         set_state "HOLD"
    fi
}

start_swayidle() {
    if ! is_swayidle_running; then
        swayidle -w \
            timeout 120 'swaylock -f -c 000000 -F -e -k -L' \
            timeout 240 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
            timeout 360 'systemctl suspend' before-sleep 'swaylock -f -c 000000 -F -e -k -L' &
        set_state "ON"
    fi
    if [ ! -f "$STATE_FILE" ] || [ "$(cat "$STATE_FILE")" != "ON" ]; then
         set_state "ON"
    fi
}

should_be_inhibited() {
    if [ -f "$INHIBIT_APPS_FILE" ]; then
        APPS_REGEX=$(grep -v '^#' "$INHIBIT_APPS_FILE" | grep -v '^$' | tr '\n' '|' | sed 's/|$//')
        if [ -n "$APPS_REGEX" ] && pgrep -x "$APPS_REGEX" >/dev/null; then
            return 0
        fi
    fi
    playerctl -a status 2>/dev/null | grep -q "Playing" && return 0
    pactl list sink-inputs 2>/dev/null | grep -q "Corked: no" && return 0
    return 1
}

# --- 4. Main Loop ---
notify-send -t 1000 "Idle manager started"

while true; do
    if [ "$PAUSED" = true ]; then
        sleep 5
        continue
    fi

    if should_be_inhibited; then
        kill_swayidle
    else
        start_swayidle
    fi
    sleep 5
done
