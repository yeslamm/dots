#!/bin/bash
# vol.sh - Hardened and Optimized Volume Control
# Treats 0% as muted for visual consistency.

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

# Atomic status retrieval (one call to wpctl)
STATUS=$(wpctl get-volume @DEFAULT_SINK@)

# Parse volume and muted state
# Status looks like: "Volume: 0.45" or "Volume: 0.00 [MUTED]"
VOL=$(echo "$STATUS" | awk '{printf "%.0f\n", $2 * 100}')
IS_MUTED=$(echo "$STATUS" | grep -q "\[MUTED\]" && echo "true" || echo "false")

# Logic: Notify "Muted" if either the toggle is on OR volume is 0
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
