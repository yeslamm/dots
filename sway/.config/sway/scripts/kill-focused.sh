#!/bin/bash
# kill-focused.sh
# Forcefully kills the focused window and its underlying process.

# 1. Get Focused Window Details (PID and Name)
FOCUSED_JSON=$(swaymsg -t get_tree | jq -r 'recurse(.nodes[]?, .floating_nodes[]?) | select(.focused == true)')
PID=$(echo "$FOCUSED_JSON" | jq -r '.pid')
NAME=$(echo "$FOCUSED_JSON" | jq -r '.app_id // .name')

# 2. Validation
if [ "$PID" = "null" ] || [ -z "$PID" ]; then
    notify-send "Force Kill" "Cannot kill: No process associated with this window." \
        -u low -t 2500 -h string:x-canonical-private-synchronous:kill
    exit 1
fi

# 3. Kill the Process (SIGKILL) & Feedback
# usage of -9 ensures it dies even if frozen.
if kill -9 "$PID"; then
    notify-send "Force Kill" "Terminated: $NAME (PID: $PID)" \
        -u normal -t 2500 -h string:x-canonical-private-synchronous:kill
else
    notify-send "Force Kill" "Failed to kill process $PID" \
        -u critical -t 2500 -h string:x-canonical-private-synchronous:kill
fi