#!/bin/bash

# Get the PID of the focused window
PID=$(swaymsg -t get_tree | jq '.. | select(.type? == "con" and .focused == true).pid')

# Check if we actually found a PID
if [ -z "$PID" ] || [ "$PID" = "null" ]; then
    notify-send "Kill Focused" "No focused window found." -u low
    exit 1
fi

# 1. The Polite Knock (SIGTERM)
kill -15 "$PID"

# 2. The Countdown
# Check 10 times (1 second total) if it's still alive
for _ in {1..10}; do
    if ! kill -0 "$PID" 2>/dev/null; then
        # It's gone, we are done.
        exit 0
    fi
    sleep 0.1
done

# 3. The Double Tap (SIGKILL)
# If we are here, it ignored the polite request.
kill -9 "$PID"
notify-send "Kill Focused" "Process $PID was frozen and has been force killed." -u critical

