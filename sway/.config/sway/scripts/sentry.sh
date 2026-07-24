#!/usr/bin/env bash
# ~/dots/sway/.config/sway/scripts/sentry.sh

set -euo pipefail

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
IDLE_FLAG="$RUNTIME_DIR/IDLE_ENABLED"

WAS_IDLE_ACTIVE=false
[[ -f "$IDLE_FLAG" ]] && WAS_IDLE_ACTIVE=true

sleep 0.2

check_lock_status() {
    if ! pgrep -x "swaylock" >/dev/null; then
        if [[ "$WAS_IDLE_ACTIVE" == "true" ]]; then
            exec "$HOME/.config/sway/scripts/idle-mgr.sh" on
        else
            pkill -RTMIN+12 waybar 2>/dev/null || true
            exit 0
        fi
    fi
}

while true; do
    check_lock_status

    pkill -x swayidle 2>/dev/null || true
    systemctl suspend

    swaymsg "output * power on" 2>/dev/null || true
    brightnessctl -q -r 2>/dev/null || true

    for ((i = 1; i <= 30; i++)); do
        check_lock_status
        sleep 1
    done
done
