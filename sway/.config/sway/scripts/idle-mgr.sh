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

is_on_ac() {
    ! grep -q "Discharging" /sys/class/power_supply/BAT*/status 2>/dev/null
}

start_idle_daemon() {
    rm -f "$BRIGHT_FLAG" "$POWER_FLAG"
    pkill -x swayidle 2>/dev/null || true

    if is_on_ac; then
        local t_dim=300
        local t_lock=600
        local t_off=900
        local t_sentry=1200
    else
        local t_dim=120
        local t_lock=180
        local t_off=240
        local t_sentry=300
    fi

    swayidle -w \
        timeout "$t_dim" "$GATEKEEPER || { brightnessctl -q -s set 20% && touch \"$BRIGHT_FLAG\"; }" \
        resume "[ -f \"$BRIGHT_FLAG\" ] && { brightnessctl -q -r; rm -f \"$BRIGHT_FLAG\"; }" \
        timeout "$t_lock" "$GATEKEEPER || $LOCK_CMD" \
        timeout "$t_off" "$GATEKEEPER || { swaymsg 'output * power off' && touch \"$POWER_FLAG\"; }" \
        resume "[ -f \"$POWER_FLAG\" ] && { swaymsg 'output * power on'; rm -f \"$POWER_FLAG\"; }" \
        timeout "$t_sentry" "$GATEKEEPER || $SENTRY_CMD" \
        before-sleep "$LOCK_CMD" &

    pkill -RTMIN+12 waybar 2>/dev/null || true
}

case "$ACTION" in
on)
    touch "$IDLE_FLAG"
    start_idle_daemon
    ;;
off)
    rm -f "$IDLE_FLAG" "$BRIGHT_FLAG" "$POWER_FLAG"
    pkill -x swayidle 2>/dev/null || true
    pkill -RTMIN+12 waybar 2>/dev/null || true
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
    echo "Usage: $(basename "$0") {on|off|toggle}" >&2
    exit 1
    ;;
esac
