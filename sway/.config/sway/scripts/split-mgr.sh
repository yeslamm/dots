#!/bin/bash
# split-mgr.sh - Manages split state and Waybar updates

STATE_FILE="/dev/shm/sway-split.state"
WAYBAR_SIGNAL=12

get_current_layout() {
    swaymsg -t get_tree | jq -r '
        recurse(.nodes[], .floating_nodes[]) 
        | select(.nodes? // [] | any(.focused? == true)) 
        | .layout' | tail -n 1
}

# Ensure state file exists
if [ ! -f "$STATE_FILE" ]; then
    LAYOUT=$(get_current_layout)
    if [ "$LAYOUT" = "splitv" ]; then echo "v" > "$STATE_FILE"
    else echo "h" > "$STATE_FILE"; fi
fi

case "$1" in
    "v")
        swaymsg split v && echo "v" > "$STATE_FILE"
        ;;
    "h")
        swaymsg split h && echo "h" > "$STATE_FILE"
        ;;
    "query")
        VAL=$(cat "$STATE_FILE")
        if [ "$VAL" = "v" ]; then
            echo '{"text":"[V]", "class":"v"}'
        else
            echo '{"text":"[H]", "class":"h"}'
        fi
        exit 0
        ;;
    "update")
        LAYOUT=$(get_current_layout)
        if [ "$LAYOUT" = "splitv" ]; then echo "v" > "$STATE_FILE"
        elif [ "$LAYOUT" = "splith" ]; then echo "h" > "$STATE_FILE"
        fi
        ;;
esac

pkill -RTMIN+$WAYBAR_SIGNAL waybar
