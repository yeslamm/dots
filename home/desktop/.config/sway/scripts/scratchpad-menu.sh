#!/usr/bin/env bash

set -euo pipefail

windows=$(swaymsg -t get_tree | jq -r '
  .. | select(.name? == "__i3_scratch")? 
     | recurse(.nodes[], .floating_nodes[]) 
     | select(.type? == "con" or .type? == "floating_con") 
     | select(.name != null and .name != "") 
     | "[\(.id)] \(.app_id // .window_properties.class // "window"): \(.name)"
')

if [[ -z "$windows" ]]; then
    notify-send -t 1200 -h string:x-canonical-private-synchronous:scratch "Scratchpad" "No hidden windows found."
    exit 0
fi

selected=$(echo "$windows" | fuzzel -d -p "Scratchpad > " -l 20 -w 90 || true)

if [[ -z "$selected" ]]; then
    exit 0
fi

con_id=$(echo "$selected" | sed -n 's/^\[\([0-9]*\)\].*/\1/p')

if [[ -n "$con_id" ]]; then
    swaymsg "[con_id=$con_id] focus"
fi
