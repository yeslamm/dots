#!/usr/bin/env bash
set -euo pipefail

SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
FILE_NAME="$SAVE_DIR/Screenshot_$(date +'%Y-%m-%d_%H:%M:%S').png"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
ACTION="${1:-}" # Safe expansion prevents unbound variable crash if no args passed

get_focused_info() {
    local target
    target=$(swaymsg -t get_tree | jq -r 'first(.. | select(.focused? == true and (.type? == "con" or .type? == "floating_con"))) |
   "\(.id);\(.fullscreen_mode);\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"')
    echo "$target"
}

get_region() {
    local geom freeze_pid
    wayfreeze &
    freeze_pid=$!
    sleep 0.1
    geom=$(slurp) || true
    kill "$freeze_pid" 2>/dev/null || true
    echo "$geom"
}

if [[ "$ACTION" =~ ^(region|window|fullscreen)$ ]]; then
    win_data=$(get_focused_info)
    IFS=';' read -r win_id is_full geometry <<<"$win_data"
    temp_img="$RUNTIME_DIR/frozen.ppm"

    trap 'rm -f "$temp_img"' EXIT

    case "$ACTION" in
    region)
        geometry=$(get_region)
        [[ -z "$geometry" ]] && exit 0
        grim -t ppm -g "$geometry" "$temp_img"
        ;;
    window)
        grim -t ppm -g "$geometry" "$temp_img"
        ;;
    fullscreen)
        grim -t ppm "$temp_img"
        ;;
    esac

    satty --filename "$temp_img"
    [[ "$is_full" == "1" ]] && swaymsg "[con_id=$win_id] fullscreen enable" || true
    exit 0
fi

if [[ "$ACTION" =~ ^window- ]]; then
    geometry=$(get_focused_info | cut -d';' -f3)
fi

case "$ACTION" in
grim-copy)
    grim - | wl-copy
    ;;
grim-save)
    grim "$FILE_NAME"
    ;;
region-copy)
    geometry=$(get_region)
    [[ -z "$geometry" ]] && exit 0
    grim -g "$geometry" - | wl-copy
    ;;
region-save)
    geometry=$(get_region)
    [[ -z "$geometry" ]] && exit 0
    grim -g "$geometry" "$FILE_NAME"
    ;;
window-copy)
    grim -g "$geometry" - | wl-copy
    ;;
window-save)
    grim -g "$geometry" "$FILE_NAME"
    ;;
*)
    echo "Usage: $0 {region|window|fullscreen|grim-copy|grim-save|region-copy|region-save|window-copy|window-save}"
    exit 1
    ;;
esac

if [[ "$ACTION" =~ -copy$ ]]; then
    notify-send -t 2000 "Screenshot" "Copied to clipboard"
elif [[ "$ACTION" =~ -save$ ]]; then
    notify-send -t 2000 "Screenshot" "Saved to $SAVE_DIR"
fi
