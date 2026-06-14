#!/usr/bin/env bash
# ~/dots/sway/.config/sway/scripts/sentry.sh

set -euo pipefail

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
IDLE_FLAG="$RUNTIME_DIR/IDLE_ENABLED"

if [[ -f "$IDLE_FLAG" ]]; then
    WAS_IDLE_ACTIVE=true
else
    WAS_IDLE_ACTIVE=false
fi

while true; do
    if ! pgrep -x "swaylock" >/dev/null; then
        if [[ "$WAS_IDLE_ACTIVE" == "true" ]]; then
            exec "$HOME/.config/sway/scripts/start-idle.sh"
        else
            pkill -RTMIN+12 waybar || true
            exit 0
        fi
    fi

    killall swayidle 2>/dev/null || true

    systemctl suspend

    swaymsg "output * power on" || true
    brightnessctl -q -r || true

    for ((i = 1; i <= 60; i++)); do
        if ! pgrep -x "swaylock" >/dev/null; then
            if [[ "$WAS_IDLE_ACTIVE" == "true" ]]; then
                exec "$HOME/.config/sway/scripts/start-idle.sh"
            else
                pkill -RTMIN+12 waybar || true
                exit 0
            fi
        fi
        sleep 1
    done
done
