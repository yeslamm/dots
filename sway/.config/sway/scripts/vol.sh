#!/bin/bash
# vol.sh - Hardened and Optimized Volume Control
# Minimal forks, atomic status retrieval.

set -euo pipefail

STEP=5

case "${1:-}" in
up) wpctl set-volume @DEFAULT_SINK@ ${STEP}%+ -l 1.0 ;;
down) wpctl set-volume @DEFAULT_SINK@ ${STEP}%- ;;
mute) wpctl set-mute @DEFAULT_SINK@ toggle ;;
*)
    echo "Usage: $0 up|down|mute"
    exit 1
    ;;
esac

# Atomic Status Retrieval
OUT=$(wpctl get-volume @DEFAULT_SINK@)
VOLUME=$(echo "$OUT" | awk '{print int($2 * 100)}')
MUTED=$([[ "$OUT" =~ [MUTED] ]] && echo "true" || echo "false")

if [[ "$MUTED" == "true" ]]; then
    notify-send "Muted" -t 1000 -h int:value:0 -h string:x-canonical-private-synchronous:volume -r 9991
else
    notify-send "Volume: ${VOLUME}%" -t 1000 -h int:value:"${VOLUME}" -h string:x-canonical-private-synchronous:volume -r 9991
fi
