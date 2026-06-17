#!/usr/bin/env bash
# ~/dots/sway/.config/sway/scripts/screenshot.sh

set -euo pipefail

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
ACTION="${1:-}"
TEMP_IMG="$RUNTIME_DIR/frozen.ppm"
FREEZE_PID=""

cleanup() {
    if [[ -n "$FREEZE_PID" ]]; then
        kill "$FREEZE_PID" 2>/dev/null || true
    fi
    if [[ "$ACTION" != *"-copy" && -f "$TEMP_IMG" ]]; then
        rm -f "$TEMP_IMG"
    fi
}
trap cleanup EXIT

get_window_geometry() {
    swaymsg -t get_tree |
        jq -r '.. | select(.focused? == true and (.type? == "con" or .type? == "floating_con")) | 
               "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"' |
        head -n1
}

case "$ACTION" in
region | region-copy)
    wayfreeze &
    FREEZE_PID=$!

    while ! pgrep -x wayfreeze >/dev/null; do
        kill -0 "$FREEZE_PID" 2>/dev/null || exit 1
        sleep 0.005
    done

    GEOM=$(slurp -d -w 1 -c "#78a9ff" -s "#78a9ff1a" -b "#0f0f0f55") || exit 0
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
    kill "$FREEZE_PID" 2>/dev/null || true
    FREEZE_PID=""
    notify-send -t 2000 "Screenshot" "Copied to clipboard"
else
    grim -t ppm "${grim_args[@]}" "$TEMP_IMG"
    kill "$FREEZE_PID" 2>/dev/null || true
    FREEZE_PID=""
    satty --filename "$TEMP_IMG"
fi
