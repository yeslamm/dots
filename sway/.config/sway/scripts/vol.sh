#!/bin/bash
# vol.sh - Ultra-Optimized Volume Control

set -euo pipefail

STEP="5%"

case "${1:-}" in
up)
    wpctl set-volume @DEFAULT_SINK@ "$STEP+" -l 1.0
    ;;
down)
    wpctl set-volume @DEFAULT_SINK@ "$STEP-"
    ;;
mute)
    wpctl set-mute @DEFAULT_SINK@ toggle
    ;;
*)
    echo "Usage: $0 {up|down|mute}"
    exit 1
    ;;
esac

STATUS=$(wpctl get-volume @DEFAULT_SINK@)

eval "$(echo "$STATUS" | awk '{printf "VOL=%.0f\nIS_MUTED=%s\n", $2 * 100, ($3 == "[MUTED]" ? "true" : "false")}')"

# UI Logic Notification
if [[ "$IS_MUTED" == "true" ]] || [[ "$VOL" -eq 0 ]]; then
    notify-send "Muted" \
        -t 1000 \
        -h int:value:0 \
        -h string:x-canonical-private-synchronous:volume \
        -r 9991
else
    notify-send "Volume: ${VOL}%" \
        -t 1000 \
        -h int:value:"${VOL}" \
        -h string:x-canonical-private-synchronous:volume \
        -r 9991
fi
