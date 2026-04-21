#!/bin/bash

killall swayidle 2>/dev/null
GATEKEEPER="$HOME/.config/sway/scripts/check_procs.sh"

if [[ "$(cat /sys/class/power_supply/ACAD/online 2>/dev/null | head -n 1)" == "1" ]]; then
    # --- AC POWER PROFILES ---
    swayidle -w \
        timeout 570 "$GATEKEEPER || brightnessctl -q -s set 20%" resume 'brightnessctl -q -r' \
        timeout 600 "$GATEKEEPER || swaylock -f -c 000000 -F -e -k -L" \
        timeout 900 "$GATEKEEPER || swaymsg 'output * dpms off'" resume 'swaymsg "output * dpms on"' \
        timeout 1200 "$GATEKEEPER || ~/.config/sway/scripts/sentry.sh" \
        before-sleep 'swaylock -f -c 000000 -F -e -k -L' &
else
    # --- BATTERY PROFILES ---
    swayidle -w \
        timeout 90 "$GATEKEEPER || brightnessctl -q -s set 20%" resume 'brightnessctl -q -r' \
        timeout 120 "$GATEKEEPER || swaylock -f -c 000000 -F -e -k -L" \
        timeout 240 "$GATEKEEPER || swaymsg 'output * dpms off'" resume 'swaymsg "output * dpms on"' \
        timeout 360 "$GATEKEEPER || ~/.config/sway/scripts/sentry.sh" \
        before-sleep 'swaylock -f -c 000000 -F -e -k -L' &
fi

# Announce to the UI that the engine is running
pkill -RTMIN+12 waybar || true
