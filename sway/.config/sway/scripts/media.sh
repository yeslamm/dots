#!/bin/bash
# media.sh
# Optimized: Uses event-driven monitoring (--follow) instead of polling loops.

COMMAND="$1"
# Max time to wait for the next song to load (in seconds)
TIMEOUT_SEC=2
# Calculate max iterations based on 0.1s sleep (2 * 10 = 20 iterations)
MAX_ATTEMPTS=$((TIMEOUT_SEC * 10))

# --- Helper: Get Formatted Metadata ---
get_metadata() {
    playerctl metadata --format "{{ artist }} - {{ title }}" 2>/dev/null
}

# 1. Capture Current State
OLD_METADATA=$(get_metadata)

# 2. Execute Command
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

# 3. Optimized Wait Logic (Polling Method)
if [ "$COMMAND" = "next" ] || [ "$COMMAND" = "prev" ]; then
    # Fix: Use C-style loop so 'i' is officially "used" in the condition
    for ((i = 0; i < MAX_ATTEMPTS; i++)); do
        CURRENT=$(get_metadata)
        STATUS=$(playerctl status 2>/dev/null)

        # If player stopped, we reached end of playlist. Exit immediately.
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
    # For play/pause, we don't need to wait for a title change
    sleep 0.1
    NEW_METADATA=$(get_metadata)
fi

# Fallback: If timeout occurred or data is empty, use whatever is current
if [ -z "$NEW_METADATA" ]; then
    NEW_METADATA=$(get_metadata)
fi

# Fallback 2: If still empty (no player running)
if [ -z "$NEW_METADATA" ]; then
    NEW_METADATA="Unknown Track"
fi

# --- SMART SUPPRESSION: Only notify if the song actually changed ---
if [[ "$COMMAND" =~ ^(next|prev)$ ]]; then
    if [ "$NEW_METADATA" = "$OLD_METADATA" ] || [ "$NEW_METADATA" = "Unknown Track" ]; then
        exit 0
    fi
fi

# 4. Notification
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

