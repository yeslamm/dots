#!/bin/bash
# ~/dots/sway/.config/sway/scripts/wlsunset.sh

set -euo pipefail

# shellcheck source=/dev/null
source "$HOME/.config/sway/geo"

NIGHT_TEMP="4500"
DAY_TEMP="6500"

if pgrep -x wlsunset >/dev/null; then
    pkill -x wlsunset
    notify-send "Blue Light Filter: OFF" \
        -t 1500 -h string:x-canonical-private-synchronous:gamma
else
    wlsunset -l "$LAT" -L "$LON" -t "$NIGHT_TEMP" -T "$DAY_TEMP" &
    notify-send "Blue Light Filter: ON" \
        -t 1500 -h string:x-canonical-private-synchronous:gamma
fi
