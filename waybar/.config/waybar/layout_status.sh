#!/bin/bash
# layout_status.sh - Robust split indicator

# We get the full tree and find the focused node.
# 1. If the focused node is in a container with splith/splitv, we show that.
# 2. If the focused node itself has a layout (like when you just pressed splitv/h), we show that.
TREE=$(swaymsg -t get_tree)

# Logic:
# Find focused node ($f)
# If $f.layout is not "none", use it.
# Else, find the parent of $f and use its layout.
LAYOUT=$(echo "$TREE" | jq -r '
    .. | select(.focused? == true) as $f |
    if ($f.layout != "none") then
        $f.layout
    else
        # Search for the container that contains the focused node in its .nodes array
        .. | select(.nodes? // [] | any(.focused? == true)) | .layout
    end' | head -n 1)

case "$LAYOUT" in
    "splith") echo '{"text":"[H]", "class":"split-h"}' ;;
    "splitv") echo '{"text":"[V]", "class":"split-v"}' ;;
    "tabbed") echo '{"text":"[T]", "class":"tabbed"}' ;;
    "stacked") echo '{"text":"[S]", "class":"stacked"}' ;;
    *) echo '{"text":"[-]", "class":"none"}' ;;
esac
