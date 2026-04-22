#!/bin/bash
# wlsunset.sh - Feedback-enabled Blue Light Filter
# Toggles wlsunset and notifies the user.

set -euo pipefail

LAT="31.11167"
LON="30.94583"
NIGHT_TEMP="4500"
DAY_TEMP="6500"

if pgrep -x wlsunset >/dev/null; then
    pkill -x wlsunset
    notify-send "Blue Light Filter" "Disabled (Night color off)" \
        -t 1500 -h string:x-canonical-private-synchronous:gamma
else
    # Run in background to let the script finish
    wlsunset -l "$LAT" -L "$LON" -t "$NIGHT_TEMP" -T "$DAY_TEMP" &
    notify-send "Blue Light Filter" "Enabled (Night color on)" \
        -t 1500 -h string:x-canonical-private-synchronous:gamma
fi
