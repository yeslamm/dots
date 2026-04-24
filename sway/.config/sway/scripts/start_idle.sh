#!/bin/bash
# start_idle.sh
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
BRIGHT_FLAG="$RUNTIME_DIR/bright_dimmed"

# Cleanup stale state from previous runs
rm -f "$BRIGHT_FLAG"

killall swayidle 2>/dev/null
GATEKEEPER="$HOME/.config/sway/scripts/check_procs.sh"
LOCK_CMD="pgrep -x swaylock >/dev/null || swaylock -f"

swayidle -w \
    timeout 120 "$GATEKEEPER || { brightnessctl -q -s set 20% && touch \"$BRIGHT_FLAG\"; }" \
    resume "[ -f \"$BRIGHT_FLAG\" ] && { brightnessctl -q -r; rm \"$BRIGHT_FLAG\"; }" \
    timeout 180 "$GATEKEEPER || $LOCK_CMD" \
    timeout 240 "$GATEKEEPER || swaymsg 'output * power off'" resume 'swaymsg "output * power on"' \
    timeout 300 "$GATEKEEPER || ~/.config/sway/scripts/sentry.sh" \
    before-sleep "$LOCK_CMD" &

# Update UI
pkill -RTMIN+12 waybar || true
