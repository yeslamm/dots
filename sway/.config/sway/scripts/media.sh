#!/bin/bash
# media.sh - Play/Pause Specialist
# Optimized for a single responsibility: toggling and notifying.

set -euo pipefail

# Perform the action
playerctl play-pause

# Tiny delay to allow the player to update its status
sleep 0.08

# Fetch status and metadata
STATUS=$(playerctl status 2>/dev/null || echo "Stopped")
METADATA=$(playerctl metadata --format "{{ artist }} - {{ title }}" 2>/dev/null || echo "Unknown Track")

# Exit if nothing is happening
[[ "$STATUS" == "Stopped" ]] && exit 0

# Send the notification
if [[ "$STATUS" == "Playing" ]]; then
    notify-send "Now Playing" "$METADATA" \
        -t 1500 -h string:x-canonical-private-synchronous:media
else
    notify-send "Paused" "$METADATA" \
        -t 1500 -h string:x-canonical-private-synchronous:media
fi
