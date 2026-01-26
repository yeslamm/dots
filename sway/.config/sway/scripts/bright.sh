#!/bin/bash
# bright-notify.sh
# Script to change brightness with brightnessctl and send a notification.

# --- Configuration ---
STEP=5%

# --- Helper Functions ---
get_brightness() {
    brightnessctl -m | cut -d, -f4 | tr -d '%'
}

# --- Main Logic ---
case "$1" in
"up")
    brightnessctl set +$STEP
    ;;
"down")
    # "-n 1" ensures we don't go below 1 (black screen)
    # If your brightnessctl is very old and fails, remove "-n 1"
    brightnessctl set ${STEP}- -n 1
    ;;
*)
    echo "Usage: $0 up|down"
    exit 1
    ;;
esac

# --- Notification Logic ---
BRIGHTNESS=$(get_brightness)

notify-send "Brightness: ${BRIGHTNESS}%" \
    -t 1000 \
    -h int:value:"${BRIGHTNESS}" \
    -h string:x-canonical-private-synchronous:brightness \
    -r 9992
pkill -SIGRTMIN+11 waybar
