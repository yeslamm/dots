#!/bin/bash
# vol-notify.sh
# Script to change volume with wpctl and send a simple notification.

# --- Configuration ---
STEP=5

# --- Main Logic ---
case "$1" in
"up")
    wpctl set-volume @DEFAULT_SINK@ ${STEP}%+ -l 1.0
    ;;
"down")
    wpctl set-volume @DEFAULT_SINK@ ${STEP}%-
    ;;
"mute")
    wpctl set-mute @DEFAULT_SINK@ toggle
    ;;
*)
    echo "Usage: $0 up|down|mute"
    exit 1
    ;;
esac

# --- Status Retrieval & Notification ---

# Get volume status in one go
WPCTL_OUT=$(wpctl get-volume @DEFAULT_SINK@)

# Check Mute Status
if [[ "$WPCTL_OUT" == *"[MUTED]"* ]]; then
    # We explicitly pass "int:value:0" so the slider appears but is empty
    notify-send "Muted" \
        -t 1000 \
        -h int:value:0 \
        -h string:x-canonical-private-synchronous:volume \
        -r 9991
else
    # Parse percentage (extract decimal like 0.40 and convert to integer percentage)
    VOLUME=$(echo "$WPCTL_OUT" | grep -oP '\d+\.\d+' | awk '{print int($1 * 100)}')

    notify-send "Volume: ${VOLUME}%" \
        -t 1000 \
        -h int:value:"${VOLUME}" \
        -h string:x-canonical-private-synchronous:volume \
        -r 9991
fi
pkill -SIGRTMIN+10 waybar
