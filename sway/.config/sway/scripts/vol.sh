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

# Get volume status and parse in one go to reduce forks
WPCTL_OUT=$(wpctl get-volume @DEFAULT_SINK@)

# Use awk to handle both volume and mute status in one pass
read -r VOLUME MUTED <<< $(echo "$WPCTL_OUT" | awk '{
    vol = int($2 * 100);
    muted = ($3 == "[MUTED]" ? 1 : 0);
    print vol, muted
}')

if [[ "$MUTED" == "1" ]]; then
    notify-send "Muted" \
        -t 1000 \
        -h int:value:0 \
        -h string:x-canonical-private-synchronous:volume \
        -r 9991
else
    notify-send "Volume: ${VOLUME}%" \
        -t 1000 \
        -h int:value:"${VOLUME}" \
        -h string:x-canonical-private-synchronous:volume \
        -r 9991
fi
pkill -SIGRTMIN+10 waybar
