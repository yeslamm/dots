#!/bin/bash
# screenshot.sh - Finalized, Optimized, and Bug-fixed

SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
FILE_NAME="$SAVE_DIR/Screenshot_$(date +'%Y-%m-%d_%H:%M:%S').png"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Helper: Fast focused window lookup
get_focused_info() {
    local target
    target=$(swaymsg -t get_tree | jq -r 'first(.. | select(.focused? == true and (.type? == "con" or .type? == "floating_con"))) |
   "\(.id);\(.fullscreen_mode);\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"')
    echo "$target"
}

# Helper: Frozen region selection
get_region() {
    local geom freeze_pid
    wayfreeze &
    freeze_pid=$!
    sleep 0.1
    geom=$(slurp)
    kill "$freeze_pid" 2>/dev/null
    echo "$geom"
}

# --- SATTY MODES (Interactive) ---
if [[ "$1" =~ ^(region|window|fullscreen)$ ]]; then
    win_data=$(get_focused_info)
    IFS=';' read -r win_id is_full geometry <<<"$win_data"
    temp_img="$RUNTIME_DIR/frozen.ppm"

    trap 'rm -f "$temp_img"' EXIT

    case "$1" in
    region)
        geometry=$(get_region)
        [[ -z "$geometry" ]] && exit 1
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
    [[ "$is_full" == "1" ]] && swaymsg "[con_id=$win_id] fullscreen enable"
    exit 0
fi

# --- DIRECT MODES (Instant) ---
case "$1" in
grim-copy) grim - | wl-copy ;;
grim-save) grim "$FILE_NAME" ;;
region-copy)
    geometry=$(get_region)
    [[ -z "$geometry" ]] && exit 1
    grim -g "$geometry" - | wl-copy
    ;;
region-save)
    geometry=$(get_region)
    [[ -z "$geometry" ]] && exit 1
    grim -g "$geometry" "$FILE_NAME"
    ;;
window-copy)
    geometry=$(get_focused_info | cut -d';' -f3)
    grim -g "$geometry" - | wl-copy
    ;;
window-save)
    geometry=$(get_focused_info | cut -d';' -f3)
    grim -g "$geometry" "$FILE_NAME"
    ;;
*)
    echo "Usage: $0 {region|window|fullscreen|grim-copy|grim-save|region-copy|region-save|window-copy|window-save}"
    exit 1
    ;;
esac

# Notifications
if [[ "$1" =~ -copy$ ]]; then
    notify-send -t 2000 "Screenshot" "Copied to clipboard"
elif [[ "$1" =~ -save$ ]]; then
    notify-send -t 2000 "Screenshot" "Saved to $SAVE_DIR"
fi
