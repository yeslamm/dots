#!/bin/bash
# start_idle.sh

killall swayidle 2>/dev/null
GATEKEEPER="$HOME/.config/sway/scripts/check_procs.sh"
LOCK_CMD="pgrep -x swaylock >/dev/null || swaylock -f -c 000000 -F -e -k -L"

swayidle -w \
    timeout 120 "$GATEKEEPER || brightnessctl -q -s set 20%" resume 'brightnessctl -q -r' \
    timeout 180 "$GATEKEEPER || $LOCK_CMD" \
    timeout 240 "$GATEKEEPER || swaymsg 'output * power off'" resume 'swaymsg "output * power on"' \
    timeout 300 "$GATEKEEPER || ~/.config/sway/scripts/sentry.sh" \
    before-sleep "$LOCK_CMD" &

# Update UI
pkill -RTMIN+12 waybar || true
