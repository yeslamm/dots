#!/bin/bash
# media.sh
# Polling version.

COMMAND="$1"
TIMEOUT_SEC=2
MAX_ATTEMPTS=$((TIMEOUT_SEC * 10))

get_metadata() {
    playerctl metadata --format "{{ artist }} - {{ title }}" 2>/dev/null
}

OLD_METADATA=$(get_metadata)

case "$COMMAND" in
"prev")
    playerctl previous
    ;;
"play-pause")
    playerctl play-pause
    ;;
"next")
    playerctl next
    ;;
*)
    echo "Usage: $0 prev|play-pause|next"
    exit 1
    ;;
esac

if [ "$COMMAND" = "next" ] || [ "$COMMAND" = "prev" ]; then
    for ((i = 0; i < MAX_ATTEMPTS; i++)); do
        CURRENT=$(get_metadata)
        STATUS=$(playerctl status 2>/dev/null)

        if [ "$STATUS" = "Stopped" ]; then
            exit 0
        fi

        if [ "$CURRENT" != "$OLD_METADATA" ] && [ -n "$CURRENT" ]; then
            NEW_METADATA="$CURRENT"
            break
        fi
        sleep 0.1
    done
else
    sleep 0.1
    NEW_METADATA=$(get_metadata)
fi

if [ -z "$NEW_METADATA" ]; then
    NEW_METADATA=$(get_metadata)
fi

if [ -z "$NEW_METADATA" ]; then
    NEW_METADATA="Unknown Track"
fi

if [[ "$COMMAND" =~ ^(next|prev)$ ]]; then
    if [ "$NEW_METADATA" = "$OLD_METADATA" ] || [ "$NEW_METADATA" = "Unknown Track" ]; then
        exit 0
    fi
fi

STATUS=$(playerctl status 2>/dev/null)

if [ "$STATUS" = "Playing" ]; then
    notify-send "Now Playing" "$NEW_METADATA" \
        -t 2000 \
        -h string:x-canonical-private-synchronous:media
elif [ "$STATUS" = "Paused" ]; then
    notify-send "Paused" "$NEW_METADATA" \
        -t 2000 \
        -h string:x-canonical-private-synchronous:media
fi