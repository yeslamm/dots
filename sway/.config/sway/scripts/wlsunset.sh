#!/usr/bin/env bash
# ~/dots/sway/.config/sway/scripts/wlsunset.sh

set -euo pipefail

LAT="31.1"
LON="30.9"
NIGHT_TEMP="4500"
DAY_TEMP="6500"

ACTION="${1:-toggle}"

case "$ACTION" in
on)
    if ! pgrep -x wlsunset >/dev/null; then
        wlsunset -l "$LAT" -L "$LON" -t "$NIGHT_TEMP" -T "$DAY_TEMP" &
    fi
    ;;
off)
    pkill -x wlsunset || true
    ;;
toggle)
    if pgrep -x wlsunset >/dev/null; then
        "$0" off
        notify-send "Blue Light Filter: OFF" \
            -t 1500 -h string:x-canonical-private-synchronous:gamma
    else
        wlsunset -l "$LAT" -L "$LON" -t "$NIGHT_TEMP" -T "$DAY_TEMP" &
        notify-send "Blue Light Filter: ON" \
            -t 1500 -h string:x-canonical-private-synchronous:gamma
    fi
    ;;
*)
    echo "Usage: $0 {on|off|toggle}"
    exit 1
    ;;
esac
