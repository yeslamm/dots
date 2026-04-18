#!/usr/bin/env bash
# fuzzel-kill.sh - GUI-Aware Window Killer (Recursive Tree Edition)

set -euo pipefail

MODE=${1:-TERM}

if [[ "$MODE" == "KILL" ]]; then
    PROMPT="SIGKILL: "
    SIGNAL=9
else
    PROMPT="SIGTERM: "
    SIGNAL=15
fi

# Recursive function to cleanly kill a process and its entire bloodline
kill_tree() {
    local parent=$1
    local sig=$2

    # Find all direct children of this parent
    local children
    children=$(pgrep -P "$parent" 2>/dev/null || true)

    # Drill down and kill grandchildren first
    for child in $children; do
        kill_tree "$child" "$sig"
    done

    # Kill the parent last
    kill -"$sig" "$parent" 2>/dev/null || true
}

# 1. Fetch raw data: PID<tab>App<tab>Title
RAW_LIST=$(swaymsg -t get_tree | jq -r '
    .. | select((.type? == "con" or .type? == "floating_con") and .pid? != null) | 
    "\(.pid)\t\(.app_id // .window_properties.class // "Unknown")\t\(.name)"
')

# 2. Build hidden mapping list: PID<tab>App  Title
MAPPED_LIST=$(echo "$RAW_LIST" | awk -F'\t' '{printf "%s\t%s  %s\n", $1, $2, $3}')

# 3. Create the clean UI list for Fuzzel
DISPLAY_LIST=$(echo "$MAPPED_LIST" | cut -f2-)

# Select target
TARGET=$(echo "$DISPLAY_LIST" | fuzzel --dmenu --prompt="$PROMPT" -w 80 -l 15)

if [[ -n "$TARGET" ]]; then
    # 4. Reverse Lookup: Find the exact PID
    PID=$(echo "$MAPPED_LIST" | awk -F'\t' -v target="$TARGET" '$2 == target {print $1; exit}')

    # Grab App Name for notification
    APP_NAME=$(echo "$TARGET" | awk '{print $1}')

    # Execute the recursive strike
    kill_tree "$PID" "$SIGNAL"

    if [[ "$MODE" == "KILL" ]]; then
        notify-send -t 2000 -h string:x-canonical-private-synchronous:kill "Force Killed Tree: $APP_NAME"
    else
        notify-send -t 2000 -h string:x-canonical-private-synchronous:kill "Sent Close Signal to Tree: $APP_NAME"
    fi
fi
