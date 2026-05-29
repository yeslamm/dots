#!/bin/bash
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

[[ -f "$RUNTIME_DIR/IDLE_INHIBIT" ]] && exit 0

pgrep -x "swaylock" >/dev/null || exit 0

killall swayidle 2>/dev/null

systemctl suspend

swaymsg "output * power on"

brightnessctl -q -r

for ((i = 1; i <= 60; i++)); do
    if ! pgrep -x "swaylock" >/dev/null; then
        "$HOME/.config/sway/scripts/start_idle.sh" &
        exit 0
    fi
    sleep 1
done

exec "$HOME/.config/sway/scripts/sentry.sh"
