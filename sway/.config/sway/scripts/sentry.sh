#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
IDLE_FLAG="$RUNTIME_DIR/IDLE_ENABLED"

# Capture intent before we enter the suspend loop
if [[ -f "$IDLE_FLAG" ]]; then
    WAS_IDLE_ACTIVE=true
else
    WAS_IDLE_ACTIVE=false
fi

while true; do
    # If the user has unlocked, restore the environment and exit
    if ! pgrep -x "swaylock" >/dev/null; then
        if [[ "$WAS_IDLE_ACTIVE" == "true" ]]; then
            # exec replaces the sentry process with the idle manager
            exec "$HOME/.config/sway/scripts/start_idle.sh"
        else
            pkill -RTMIN+12 waybar || true
            exit 0
        fi
    fi

    # Kill any temporary idle timers (like from lock-ns.sh)
    killall swayidle 2>/dev/null || true

    # Suspend (This handles both the initial lid close and any ghost wakeups)
    systemctl suspend

    # --- WAKE UP POINT ---
    swaymsg "output * power on" || true
    brightnessctl -q -r || true

    # Safety window: If not unlocked within 60s, loop back and suspend again
    for ((i = 1; i <= 60; i++)); do
        if ! pgrep -x "swaylock" >/dev/null; then
            if [[ "$WAS_IDLE_ACTIVE" == "true" ]]; then
                exec "$HOME/.config/sway/scripts/start_idle.sh"
            else
                pkill -RTMIN+12 waybar || true
                exit 0
            fi
        fi
        sleep 1
    done
done
