#!/bin/bash
# bright.sh - Logarithmic Brightness Control

set -euo pipefail

# Read current brightness BEFORE changing it
CURRENT_BRIGHTNESS=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

# Dynamic step calculation for human-eye logarithmic perception
if [ "$CURRENT_BRIGHTNESS" -le 10 ]; then
    STEP=1 # 1% steps when screen is very dim
elif [ "$CURRENT_BRIGHTNESS" -le 30 ]; then
    STEP=2 # 2% steps in the mid-low range
else
    STEP=5 # 5% steps when already bright
fi

case "${1:-}" in
up) brightnessctl set "+${STEP}%" ;;
down) brightnessctl set "${STEP}%-" -n 1 ;;
*)
    echo "Usage: $0 up|down"
    exit 1
    ;;
esac

# Read the new brightness for the notification
NEW_BRIGHTNESS=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

notify-send "Brightness: ${NEW_BRIGHTNESS}%" -t 1000 -h int:value:"${NEW_BRIGHTNESS}" -h string:x-canonical-private-synchronous:brightness -r 9992
