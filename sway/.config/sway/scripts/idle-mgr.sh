#!/bin/bash
# idle-mgr.sh
# Optimized: Uses explicit state file to prevent UI race conditions.

SWAYIDLE_PID_FILE="/dev/shm/swayidle.pid"
MANAGER_PID_FILE="/dev/shm/idle-mgr.pid"
STATE_FILE="/dev/shm/idle-mgr.state"

# Prevent multiple instances
if [ -f "$MANAGER_PID_FILE" ]; then
    existing_pid=$(cat "$MANAGER_PID_FILE" 2>/dev/null)
    if [ -n "$existing_pid" ] && kill -0 "$existing_pid" 2>/dev/null; then
        notify-send -t 1000 "Idle manager already running"
        # Force an update just in case the UI is desynced
        pkill -SIGRTMIN+8 waybar
        exit 0
    fi
fi

echo $$ >"$MANAGER_PID_FILE"

# Helper: Write state and signal Waybar
set_state() {
    echo "$1" > "$STATE_FILE"
    pkill -SIGRTMIN+8 waybar
}

# Cleanup on exit
cleanup() {
    # Check if we are still the "official" manager (process ID matches the PID file)
    if [ -f "$MANAGER_PID_FILE" ] && [ "$(cat "$MANAGER_PID_FILE")" = "$$" ]; then
        # We are the owner. Clean up everything.
        rm -f "$MANAGER_PID_FILE" "$SWAYIDLE_PID_FILE" "$STATE_FILE"
        pkill -SIGRTMIN+8 waybar
    else
        # We are NOT the owner (a new instance has likely overwritten the PID file).
        # Do nothing. Die silently to protect the new instance.
        :
    fi
    exit 0
}
trap cleanup EXIT INT TERM

# Send startup notification
notify-send -t 1000 "Idle manager started"

is_swayidle_running() {
    if [ -f "$SWAYIDLE_PID_FILE" ]; then
        pid=$(cat "$SWAYIDLE_PID_FILE" 2>/dev/null)
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

kill_swayidle() {
    if is_swayidle_running; then
        pkill -x swayidle
        rm -f "$SWAYIDLE_PID_FILE"
        # State changed: Active -> Inhibited
        set_state "HOLD"
    fi
    # Ensure state is set even if swayidle wasn't running (e.g., initial inhibition)
    if [ ! -f "$STATE_FILE" ] || [ "$(cat "$STATE_FILE")" != "HOLD" ]; then
         set_state "HOLD"
    fi
}

start_swayidle() {
    if ! is_swayidle_running; then
        # Flags applied: -f (daemonize), -c 000000 (black), -F (failed count),
        # -e (no empty password), -k (layout), -L (no caps text)
        exec swayidle -w \
            timeout 120 'swaylock -f -c 000000 -F -e -k -L' \
            timeout 240 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
            timeout 360 'systemctl suspend' before-sleep 'swaylock -f -c 000000 -F -e -k -L' &
        echo $! >"$SWAYIDLE_PID_FILE"
        # State changed: Inhibited -> Active
        set_state "ON"
    fi
    # Ensure state is set even if swayidle was already running
    if [ ! -f "$STATE_FILE" ] || [ "$(cat "$STATE_FILE")" != "ON" ]; then
         set_state "ON"
    fi
}

should_be_inhibited() {
    # 1. Application inhibition (Fastest - pgrep loop)
    INHIBIT_APPS_FILE="$HOME/.config/sway/idle_inhibit_apps"
    if [ -f "$INHIBIT_APPS_FILE" ]; then
        while IFS= read -r app_pattern; do
            if [[ -z "$app_pattern" || "$app_pattern" =~ ^# ]]; then continue; fi
            if pgrep -x "$app_pattern" >/dev/null; then return 0; fi
        done <"$INHIBIT_APPS_FILE"
    fi

    # 2. Application inhibition (Medium - playerctl)
    if playerctl -a status 2>/dev/null | grep -q "Playing"; then return 0; fi

    # 3. Audio inhibition (Slower - pactl)
    if pactl list sink-inputs 2>/dev/null | grep -q "Corked: no"; then return 0; fi

    return 1
}

# Main daemon loop
while true; do
    if should_be_inhibited;
    then
        kill_swayidle
    else
        start_swayidle
    fi
    sleep 5
done