#!/bin/bash
# toggle_gammastep.sh - Feedback-enabled Blue Light Filter
# Toggles gammastep and notifies the user.

set -euo pipefail

LAT="31.11167"
LON="30.94583"

if pgrep -x gammastep >/dev/null; then
    pkill -x gammastep
    notify-send "Gammastep" "Disabled (Blue light filter off)" \
        -t 1500 -h string:x-canonical-private-synchronous:gamma
else
    # Run in background to let the script finish
    gammastep -l "$LAT:$LON" &
    notify-send "Gammastep" "Enabled (Blue light filter active)" \
        -t 1500 -h string:x-canonical-private-synchronous:gamma
fi
