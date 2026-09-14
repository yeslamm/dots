#!/usr/bin/env bash
# ~/dots/desktop/.config/sway/scripts/power/lock-suspend.sh

set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/run/user/${UID}}/sway-power"
IDLE_FLAG="$STATE_DIR/idle_enabled"

WAS_IDLE_ACTIVE=false
[[ -f "$IDLE_FLAG" ]] && WAS_IDLE_ACTIVE=true

pgrep -x "swaylock" >/dev/null || swaylock -f
sleep 0.2

check_lock_status() {
    if ! pgrep -x "swaylock" >/dev/null; then
        if [[ "$WAS_IDLE_ACTIVE" == "true" ]]; then
            exec "$HOME/.config/sway/scripts/power/idle-mgr.sh" on
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
