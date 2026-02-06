#!/bin/bash
# idle-mgr.sh
# Hardened against set -e and Shellcheck compliant.

set -euo pipefail

LOCK_FILE="/dev/shm/idle-mgr.lock"
PID_FILE="/dev/shm/idle-mgr.pid"
STATE_FILE="/dev/shm/idle-mgr.state"
INHIBIT_APPS_FILE="$HOME/.config/sway/idle_inhibit_apps"
WAYBAR_SIGNAL=9

# --- 1. Atomic Singleton ---
exec 8>"$LOCK_FILE"
if ! flock -n 8; then
    if [ -f "$PID_FILE" ]; then
        OLD_PID=$(cat "$PID_FILE")
        if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
            CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "ON")
            if [ "$CURRENT_STATE" = "PAUSED" ]; then
                kill -SIGUSR2 "$OLD_PID" 2>/dev/null
            else
                kill -SIGUSR1 "$OLD_PID" 2>/dev/null
            fi
        fi
    fi
    exit 0
fi
echo $$ >"$PID_FILE"

# --- 2. State Management ---
PAUSED=false
IDLE_PID=""

update_waybar() {
    pkill -RTMIN+$WAYBAR_SIGNAL waybar 2>/dev/null || true
}

set_state() {
    local new_state="$1"
    if [ ! -f "$STATE_FILE" ] || [ "$(cat "$STATE_FILE")" != "$new_state" ]; then
        echo "$new_state" >"$STATE_FILE"
        update_waybar
    fi
}

stop_idle() {
    if [ -n "$IDLE_PID" ]; then
        kill "$IDLE_PID" 2>/dev/null
        wait "$IDLE_PID" 2>/dev/null
        IDLE_PID=""
    fi
    pkill -x swayidle 2>/dev/null || true
}

start_idle() {
    if [ -z "$IDLE_PID" ] || ! kill -0 "$IDLE_PID" 2>/dev/null; then
        swayidle -w \
            timeout 120 'swaylock -f -c 000000 -F -e -k -L' \
            timeout 240 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
            timeout 360 'systemctl suspend' before-sleep 'swaylock -f -c 000000 -F -e -k -L' &
        IDLE_PID=$!
        set_state "ON"
    fi
}

# --- 3. Inhibition Logic (Safe from set -e) ---

should_be_inhibited() {
    # 1. Focus Check
    local focused
    focused=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | (.app_id // .window_properties.class // "") + " " + (.name // "")' 2>/dev/null || true)

    if [ -n "$focused" ] && [ -f "$INHIBIT_APPS_FILE" ]; then
        while IFS= read -r pattern; do
            [[ "$pattern" =~ ^#.*$ || -z "$pattern" ]] && continue
            if [[ "$focused" =~ $pattern ]]; then return 0; fi
        done <"$INHIBIT_APPS_FILE"
    fi

    # 2. Media/Audio Check
    if playerctl -a status 2>/dev/null | grep -q "Playing"; then
        return 0
    fi

    if pw-dump | jq -e '.[] | select(.type == "PipeWire:Interface:Node" and .info.props."media.class" == "Stream/Output/Audio" and .info.state == "running")' >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

check_and_act() {
    if [ "${PAUSED}" = true ]; then
        [ -n "$IDLE_PID" ] && stop_idle
        set_state "PAUSED"
        return
    fi

    if should_be_inhibited; then
        [ -n "$IDLE_PID" ] && stop_idle
        set_state "HOLD"
    else
        start_idle
    fi
}

# --- 4. Signals & Cleanup ---

handle_pause() {
    PAUSED=true
    notify-send -t 1000 "Idle Manager" "Paused"
    check_and_act
}
handle_resume() {
    PAUSED=false
    notify-send -t 1000 "Idle Manager" "Resumed"
    check_and_act
}

cleanup() {
    local exit_code=$?
    set +e

    # Only notify on true crashes
    # 0=success, 1=false (from logic), 130=SIGINT, 143=SIGTERM
    if [[ $exit_code -ne 0 && $exit_code -ne 1 && $exit_code -ne 130 && $exit_code -ne 143 ]]; then
        notify-send -u critical "Idle Manager" "CRASHED (Exit Code: $exit_code)"
    fi

    # shellcheck disable=SC2046
    [ -n "$(jobs -p)" ] && kill $(jobs -p) 2>/dev/null || true

    stop_idle
    rm -f "$STATE_FILE" "$PID_FILE" "$LOCK_FILE"
    update_waybar
    exit "$exit_code"
}

trap handle_pause SIGUSR1
trap handle_resume SIGUSR2
trap "check_and_act" SIGALRM
trap cleanup EXIT INT TERM

# --- 5. Main ---
notify-send -t 1000 "Idle Manager" "Started"
update_waybar
check_and_act

(
    until swaymsg -t subscribe '["window"]' --monitor | jq --unbuffered -c 'select(.change == "focus" or .change == "title")' 2>/dev/null | while read -r _; do
        kill -SIGALRM $$ 2>/dev/null
    done; do
        sleep 2
    done
) &

(
    until playerctl status --follow 2>/dev/null | while read -r _; do
        sleep 0.1
        kill -SIGALRM $$ 2>/dev/null
    done; do
        sleep 5
    done
) &

(while true; do
    sleep 60
    kill -SIGALRM $$ 2>/dev/null
done) &

while true; do wait || true; done
