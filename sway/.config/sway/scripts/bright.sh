#!/bin/bash
# bright.sh - Hardened and Optimized Brightness Control
# Minimal forks, safe floor levels.

set -euo pipefail

STEP=5%
WAYBAR_SIGNAL=11

case "${1:-}" in
up) brightnessctl set "+$STEP" ;;
down) brightnessctl set "${STEP}-" -n 1 ;;
*)
    echo "Usage: $0 up|down"
    exit 1
    ;;
esac

# Optimized extraction using machine-readable output
BRIGHTNESS=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

notify-send "Brightness: ${BRIGHTNESS}%" -t 1000 -h int:value:"${BRIGHTNESS}" -h string:x-canonical-private-synchronous:brightness -r 9992

pkill -RTMIN+$WAYBAR_SIGNAL waybar 2>/dev/null || true
