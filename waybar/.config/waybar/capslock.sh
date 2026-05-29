#!/bin/bash
# capslock.sh - Zero-latency monitor with transition alerts

# Initialize state to prevent a ghost notification when Waybar starts up
if grep -q '1' /sys/class/leds/*capslock/brightness 2>/dev/null; then
    PREV_STATE="ON"
else
    PREV_STATE="OFF"
fi

while true; do
    if grep -q '1' /sys/class/leds/*capslock/brightness 2>/dev/null; then
        CURR_STATE="ON"
        echo "CAPS"
    else
        CURR_STATE="OFF"
        echo ""
    fi

    # Trigger notification ONLY when the state explicitly changes
    if [[ "$CURR_STATE" != "$PREV_STATE" ]]; then
        notify-send "Caps Lock: ${CURR_STATE}" \
            -t 1000 \
            -h string:x-canonical-private-synchronous:capslock \
            -r 9993
        PREV_STATE="$CURR_STATE"
    fi

    sleep 0.1
done
