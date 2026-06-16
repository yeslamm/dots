#!/usr/bin/env bash
# ~/dots/sway/.config/sway/scripts/screenshot.sh

set -euo pipefail

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
ACTION="${1:-}"
TEMP_IMG="$RUNTIME_DIR/frozen.ppm"

get_window_geometry() {
    swaymsg -t get_tree |
        jq -r '.. | select(.focused? == true and (.type? == "con" or .type? == "floating_con")) | 
               "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"' |
        head -n1
}

get_region() {
    local geom freeze_pid
    wayfreeze &
    freeze_pid=$!
    sleep 0.03

    geom=$(slurp \
        -d \
        -w 1 \
        -c "#78a9ff" \
        -s "#78a9ff1a" \
        -b "#0f0f0f55") || true

    kill "$freeze_pid" 2>/dev/null || true
    echo "$geom"
}

case "$ACTION" in
region | region-copy)
    GEOM=$(get_region)
    [[ -z "$GEOM" ]] && exit 0
    ;;
window | window-copy)
    GEOM=$(get_window_geometry)
    [[ -z "$GEOM" ]] && exit 0
    ;;
fullscreen | fullscreen-copy)
    GEOM=""
    ;;
*)
    echo "Usage: $0 {region|window|fullscreen|region-copy|window-copy|fullscreen-copy}"
    exit 1
    ;;
esac

declare -a grim_args=()
if [[ -n "$GEOM" ]]; then
    grim_args+=(-g "$GEOM")
fi

if [[ "$ACTION" =~ -copy$ ]]; then
    grim "${grim_args[@]}" - | wl-copy
    notify-send -t 2000 "Screenshot" "Copied to clipboard"
else
    trap 'rm -f "$TEMP_IMG"' EXIT
    grim -t ppm "${grim_args[@]}" "$TEMP_IMG"
    satty --filename "$TEMP_IMG"
fi
