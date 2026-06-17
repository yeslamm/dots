#!/usr/bin/env bash
# ~/dots/sway/.config/sway/scripts/idle-mgr.sh

set -euo pipefail

ACTION="${1:-}"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

IDLE_FLAG="$RUNTIME_DIR/IDLE_ENABLED"
BRIGHT_FLAG="$RUNTIME_DIR/bright_dimmed"
POWER_FLAG="$RUNTIME_DIR/display_off"

GATEKEEPER="$HOME/.config/sway/scripts/check-procs.sh"
LOCK_CMD="pgrep -x swaylock >/dev/null || swaylock -f"
SENTRY_CMD="$HOME/.config/sway/scripts/sentry.sh"

start_idle_daemon() {
    rm -f "$BRIGHT_FLAG" "$POWER_FLAG"
    killall swayidle 2>/dev/null || true

    swayidle -w \
        timeout 120 "$GATEKEEPER || { brightnessctl -q -s set 20% && touch \"$BRIGHT_FLAG\"; }" \
        resume "[ -f \"$BRIGHT_FLAG\" ] && { brightnessctl -q -r; rm \"$BRIGHT_FLAG\"; }" \
        timeout 180 "$GATEKEEPER || $LOCK_CMD" \
        timeout 240 "$GATEKEEPER || { swaymsg 'output * power off' && touch \"$POWER_FLAG\"; }" \
        resume "[ -f \"$POWER_FLAG\" ] && { swaymsg 'output * power on'; rm \"$POWER_FLAG\"; }" \
        timeout 300 "$GATEKEEPER || $SENTRY_CMD" \
        before-sleep "$LOCK_CMD" &

    pkill -RTMIN+12 waybar || true
}

case "$ACTION" in
on)
    touch "$IDLE_FLAG"
    if ! pgrep -x swayidle >/dev/null; then
        start_idle_daemon
    fi
    ;;
off)
    rm -f "$IDLE_FLAG" "$BRIGHT_FLAG" "$POWER_FLAG"
    killall -q swayidle -u "$USER" || true
    pkill -RTMIN+12 waybar || true
    ;;
toggle)
    if [[ -f "$IDLE_FLAG" ]]; then
        "$0" off
        notify-send -t 1500 -h string:x-canonical-private-synchronous:idlemgr 'IDLE: OFF'
    else
        "$0" on
        notify-send -t 1500 -h string:x-canonical-private-synchronous:idlemgr 'IDLE: ON'
    fi
    ;;
*)
    echo "Usage: $0 {on|off|toggle}"
    exit 1
    ;;
esac
