#!/usr/bin/env bash
# ~/dots/desktop/.config/sway/scripts/idle-mgr.sh

set -euo pipefail

SELF="$(realpath "$0")"
ACTION="${1:-}"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/${UID}}"

IDLE_FLAG="$RUNTIME_DIR/IDLE_ENABLED"
BRIGHT_FLAG="$RUNTIME_DIR/bright_dimmed"
POWER_FLAG="$RUNTIME_DIR/display_off"
PROCS_FILE="$HOME/.config/sway/idle_procs"

LOCK_CMD="pgrep -x swaylock >/dev/null || swaylock -f"
SENTRY_CMD="$HOME/.config/sway/scripts/sentry.sh"

is_on_ac() {
    local f status
    for f in /sys/class/power_supply/BAT*/status; do
        [[ -r "$f" ]] || continue
        read -r status <"$f" 2>/dev/null || true
        [[ "$status" == "Discharging" ]] && return 1
    done
    return 0
}

is_inhibited() {
    [[ -s "$PROCS_FILE" ]] || return 1
    local pats
    pats=$(awk 'NF && !/^[[:space:]]*#/ {print $1}' "$PROCS_FILE" | paste -sd '|' -)
    [[ -n "$pats" ]] && pgrep -i -x "$pats" >/dev/null
}

restore_state() {
    if [[ -f "$BRIGHT_FLAG" ]]; then
        brightnessctl -q -r 2>/dev/null || true
        rm -f "$BRIGHT_FLAG"
    fi
    if [[ -f "$POWER_FLAG" ]]; then
        swaymsg 'output * power on' 2>/dev/null || true
        rm -f "$POWER_FLAG"
    fi
}

start_idle_daemon() {
    restore_state
    pkill -x swayidle 2>/dev/null || true

    if is_on_ac; then
        local t_dim=300 t_lock=600 t_off=900 t_sentry=1200
    else
        local t_dim=120 t_lock=180 t_off=240 t_sentry=300
    fi

    swayidle -w \
        timeout "$t_dim" "$SELF check || { brightnessctl -q -s set 20% && touch \"$BRIGHT_FLAG\"; }" \
        resume "[ -f \"$BRIGHT_FLAG\" ] && { brightnessctl -q -r; rm -f \"$BRIGHT_FLAG\"; }" \
        timeout "$t_lock" "$SELF check || $LOCK_CMD" \
        timeout "$t_off" "$SELF check || { swaymsg 'output * power off' && touch \"$POWER_FLAG\"; }" \
        resume "[ -f \"$POWER_FLAG\" ] && { swaymsg 'output * power on'; rm -f \"$POWER_FLAG\"; }" \
        timeout "$t_sentry" "$SELF check || $SENTRY_CMD" \
        before-sleep "$LOCK_CMD" &

    pkill -RTMIN+12 waybar 2>/dev/null || true
}

case "$ACTION" in
check)
    is_inhibited
    ;;
on)
    touch "$IDLE_FLAG"
    start_idle_daemon
    ;;
off)
    rm -f "$IDLE_FLAG"
    restore_state
    pkill -x swayidle 2>/dev/null || true
    pkill -RTMIN+12 waybar 2>/dev/null || true
    ;;
toggle)
    if [[ -f "$IDLE_FLAG" ]]; then
        "$SELF" off
        notify-send -t 1500 -h string:x-canonical-private-synchronous:idlemgr 'IDLE: OFF'
    else
        "$SELF" on
        notify-send -t 1500 -h string:x-canonical-private-synchronous:idlemgr 'IDLE: ON'
    fi
    ;;
*)
    echo "Usage: $(basename "$0") [on|off|toggle|check]" >&2
    exit 1
    ;;
esac
