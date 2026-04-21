#!/bin/bash

# Define the save directory and format
SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
FILE_NAME="$SAVE_DIR/Screenshot_$(date +'%Y-%m-%d_%H:%M:%S').png"

# ==============================================================================
# --- SATTY MODES (Requires jq parsing to restore fullscreen games/apps) ---
# ==============================================================================
if [[ "$1" == "region" || "$1" == "window" || "$1" == "fullscreen" ]]; then

    # 1. Grab window info
    TARGET=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true and (.type? == "con" or .type? == "floating_con")) | "\(.id);\(.fullscreen_mode);\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"' | head -n 1)
    IFS=';' read -r WIN_ID IS_FULL GEOMETRY <<<"$TARGET"

    # 2. Capture raw pixels (-t ppm) for instant handoff
    case "$1" in
    region)
        # Define the secure runtime path
        RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
        TEMP_IMG="$RUNTIME_DIR/frozen.ppm"

        wayfreeze &
        FREEZE_PID=$!
        sleep 0.1
        GEOMETRY=$(slurp -d)
        if [ -n "$GEOMETRY" ]; then
            grim -t ppm -g "$GEOMETRY" "$TEMP_IMG"
            kill $FREEZE_PID
            satty --filename "$TEMP_IMG"
            rm "$TEMP_IMG"
        else
            kill $FREEZE_PID
        fi
        ;;
    window)
        grim -t ppm -g "$GEOMETRY" - | satty --filename -
        ;;
    fullscreen)
        grim -t ppm - | satty --filename -
        ;;
    esac

    # 3. Restore Fullscreen when Satty closes
    if [ "$IS_FULL" = "1" ]; then
        swaymsg "[con_id=$WIN_ID] fullscreen enable"
    fi
    exit 0
fi

# ==============================================================================
# --- DIRECT MODES (Instant, silent, background compression) ---
# ==============================================================================
case "$1" in
grim-copy)
    grim - | wl-copy
    notify-send -t 2000 "Screenshot" "Fullscreen copied to clipboard"
    ;;
grim-save)
    grim "$FILE_NAME"
    notify-send -t 2000 "Screenshot" "Saved to ~/Pictures/Screenshots"
    ;;
region-copy)
    wayfreeze &
    FREEZE_PID=$!
    sleep 0.1
    GEOMETRY=$(slurp -d)
    if [ -n "$GEOMETRY" ]; then
        grim -g "$GEOMETRY" - | wl-copy
        kill $FREEZE_PID
        notify-send -t 2000 "Screenshot" "Region copied to clipboard"
    else
        kill $FREEZE_PID
    fi
    ;;
region-save)
    wayfreeze &
    FREEZE_PID=$!
    sleep 0.1
    GEOMETRY=$(slurp -d)
    if [ -n "$GEOMETRY" ]; then
        grim -g "$GEOMETRY" "$FILE_NAME"
        kill $FREEZE_PID
        notify-send -t 2000 "Screenshot" "Region saved to ~/Pictures/Screenshots"
    else
        kill $FREEZE_PID
    fi
    ;;
window-copy)
    GEOMETRY=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true and (.type? == "con" or .type? == "floating_con")) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | head -n 1)
    grim -g "$GEOMETRY" - | wl-copy
    notify-send -t 2000 "Screenshot" "Window copied to clipboard"
    ;;
window-save)
    GEOMETRY=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true and (.type? == "con" or .type? == "floating_con")) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | head -n 1)
    grim -g "$GEOMETRY" "$FILE_NAME"
    notify-send -t 2000 "Screenshot" "Window saved to ~/Pictures/Screenshots"
    ;;
*)
    echo "Usage: $0 {region|window|fullscreen|grim-copy|grim-save|region-copy|region-save}"
    exit 1
    ;;
esac
