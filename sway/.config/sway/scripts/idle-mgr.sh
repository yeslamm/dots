#!/bin/bash
# idle-mgr.sh
# Unified Idle Manager with Integrated Sentry Logic and Logging

set -euo pipefail

# --- Configuration ---
LOCK_FILE="/dev/shm/idle-mgr.lock"
PID_FILE="/dev/shm/idle-mgr.pid"
STATE_FILE="/dev/shm/idle-mgr.state"
LOG_FILE="/tmp/idle-mgr.log" # Ephemeral log, wiped on reboot
IDLE_APPS_FILE="$HOME/.config/sway/idle_apps"
IDLE_NF_APPS_FILE="$HOME/.config/sway/idle_nf_apps"
WAYBAR_SIGNAL=9

# Set to true for more verbosity
DEBUG=true

# --- 1. Logging Helper ---
log() {
    local level="$1"
    local msg="$2"

    # Log Rotation: If log exceeds 1MB, restart it
    if [ -f "$LOG_FILE" ] && [ "$(stat -c%s "$LOG_FILE")" -gt 1048576 ]; then
        echo "$(date '+%H:%M:%S') [INFO] Log Rotated" > "$LOG_FILE"
    fi

    local timestamp
    timestamp=$(date '+%H:%M:%S')
    echo "$timestamp [$level] $msg" >>"$LOG_FILE"

    # Optional: Also print to stderr if running in foreground
    if [[ -t 2 ]]; then
        echo "$timestamp [$level] $msg" >&2
    fi
}

# --- 2. Atomic Singleton ---
exec 8>"$LOCK_FILE"
if ! flock -n 8; then
    if [ -f "$PID_FILE" ]; then
        OLD_PID=$(cat "$PID_FILE")
        if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
            CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "ON")
            log "INFO" "Signaling existing instance (PID: $OLD_PID) to toggle state."
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

# Initialize log file
echo "--- Idle Manager Started ($(date)) ---" >"$LOG_FILE"

# --- 3. State Management ---
PAUSED=false
IDLE_PID=""
LOCKED_AT=""
CURRENT_POWER_SRC="NONE"

update_waybar() {
    pkill -RTMIN+$WAYBAR_SIGNAL waybar 2>/dev/null || true
}

set_state() {
    local new_state="$1"
    local old_state
    old_state=$(cat "$STATE_FILE" 2>/dev/null || echo "NONE")

    if [ "$old_state" != "$new_state" ]; then
        echo "$new_state" >"$STATE_FILE"
        log "STATE" "Transition: $old_state -> $new_state"
        update_waybar
    fi
}

stop_idle() {
    # 1. Kill the tracked PID
    if [ -n "$IDLE_PID" ]; then
        log "DEBUG" "Stopping managed swayidle (PID: $IDLE_PID)"
        kill "$IDLE_PID" 2>/dev/null
        wait "$IDLE_PID" 2>/dev/null
        IDLE_PID=""
    fi
    # 2. Cleanup ANY stray swayidle processes that are children of this script
    pkill -P "$$" swayidle 2>/dev/null || true
}

is_on_ac() {
    grep -q "1" /sys/class/power_supply/ACAD/online
}

start_idle() {
    local on_ac
    is_on_ac && on_ac=true || on_ac=false

    # Dynamic Timeouts (Seconds)
    # AC: 10m lock, 15m DPMS, 20m Suspend
    # BAT: 2m lock, 4m DPMS, 6m Suspend
    local t_dim t_lock t_dpms t_susp
    if [ "$on_ac" = true ]; then
        t_dim=570; t_lock=600; t_dpms=900; t_susp=1200
    else
        t_dim=90; t_lock=120; t_dpms=240; t_susp=360
    fi

    if [ -z "$IDLE_PID" ] || ! kill -0 "$IDLE_PID" 2>/dev/null; then
        log "DEBUG" "Starting swayidle (Mode: $([ "$on_ac" = true ] && echo "AC" || echo "BATTERY"))"
        swayidle -w \
            timeout $t_dim 'brightnessctl -s set 20%' resume 'brightnessctl -r' \
            timeout $t_lock 'swaylock -f -c 000000 -F -e -k -L' \
            timeout $t_dpms 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
            timeout $t_susp 'systemctl suspend' before-sleep 'swaylock -f -c 000000 -F -e -k -L' &
        IDLE_PID=$!
        set_state "ON"
    fi
}

# --- 4. Inhibition & Sentry Logic ---

should_be_inhibited() {
    local tree
    tree=$(swaymsg -t get_tree 2>/dev/null || true)
    [ -z "$tree" ] && return 1

    # 1. Non-focus Check
    if [ -f "$IDLE_NF_APPS_FILE" ]; then
        local all_windows
        all_windows=$(echo "$tree" | jq -r '.. | select(.type? == "con" or .type? == "floating_con") | (.app_id // .window_properties.class // "") + " " + (.name // "")' 2>/dev/null || true)
        local nf_patterns
        nf_patterns=$(grep -vE '^#|^$' "$IDLE_NF_APPS_FILE" | tr '\n' '|' | sed 's/|$//' || true)
        if [ -n "$nf_patterns" ] && echo "$all_windows" | grep -Ei "$nf_patterns" >/dev/null; then
            [ "$DEBUG" = true ] && log "DEBUG" "Inhibited by background app matching pattern"
            return 0
        fi
    fi

    # 2. Focus Check
    if [ -f "$IDLE_APPS_FILE" ]; then
        local focused
        focused=$(echo "$tree" | jq -r '.. | select(.focused? == true) | (.app_id // .window_properties.class // "") + " " + (.name // "")' 2>/dev/null || true)
        local f_patterns
        f_patterns=$(grep -vE '^#|^$' "$IDLE_APPS_FILE" | tr '\n' '|' | sed 's/|$//' || true)
        if [ -n "$focused" ] && [ -n "$f_patterns" ] && echo "$focused" | grep -Ei "$f_patterns" >/dev/null; then
            [ "$DEBUG" = true ] && log "DEBUG" "Inhibited by focused app: $focused"
            return 0
        fi
    fi

    # 3. Media Check
    if playerctl -a status 2>/dev/null | grep -q "Playing"; then
        [ "$DEBUG" = true ] && log "DEBUG" "Inhibited by active media playback"
        return 0
    fi
    if pw-dump | jq -e '.[] | select(.type == "PipeWire:Interface:Node" and .info.props."media.class" == "Stream/Output/Audio" and .info.state == "running")' >/dev/null 2>&1; then
        [ "$DEBUG" = true ] && log "DEBUG" "Inhibited by active PipeWire audio stream"
        return 0
    fi

    return 1
}

check_and_act() {
    # --- A. Power Source Change Check ---
    local p_src
    is_on_ac && p_src="AC" || p_src="BATTERY"
    if [ "$CURRENT_POWER_SRC" != "$p_src" ]; then
        log "INFO" "Power Source Changed: $CURRENT_POWER_SRC -> $p_src"
        CURRENT_POWER_SRC="$p_src"
        [ -n "$IDLE_PID" ] && stop_idle # Force restart with new timeouts
    fi

    # --- B. Manual Pause ---
    if [ "${PAUSED}" = true ]; then
        [ -n "$IDLE_PID" ] && stop_idle
        set_state "PAUSED"
        return
    fi

    # --- C. Sentry Logic ---
    if pgrep -x "swaylock" >/dev/null; then
        local current_uptime
        current_uptime=$(awk '{print int($1)}' /proc/uptime)

        if [ -z "$LOCKED_AT" ]; then
            LOCKED_AT=$current_uptime
            log "INFO" "Sentry Armed: swaylock detected at uptime $LOCKED_AT"
        fi

        local elapsed=$((current_uptime - LOCKED_AT))
        if [ "$elapsed" -ge 30 ]; then
            log "WARN" "Sentry Trigger: System locked/awake for ${elapsed}s. Suspending."
            LOCKED_AT=""
            systemctl suspend
            return
        fi

        [ -n "$IDLE_PID" ] && stop_idle
        set_state "LOCKED"
        return
    else
        if [ -n "$LOCKED_AT" ]; then
            log "INFO" "Sentry Disarmed: System unlocked."
            LOCKED_AT=""
        fi
    fi

    # --- D. Inhibition vs Idle ---
    if should_be_inhibited; then
        [ -n "$IDLE_PID" ] && stop_idle
        set_state "HOLD"
    else
        start_idle
    fi
}

# --- 5. Signals & Cleanup ---

handle_pause() {
    PAUSED=true
    log "INFO" "Received SIGUSR1: Pausing manager"
    notify-send -t 1000 -h string:x-canonical-private-synchronous:state "Idle Manager" "Paused"
    check_and_act
}
handle_resume() {
    PAUSED=false
    log "INFO" "Received SIGUSR2: Resuming manager"
    notify-send -t 1000 -h string:x-canonical-private-synchronous:state "Idle Manager" "Resumed"
    check_and_act
}

cleanup() {
    local exit_code=$?
    set +e
    log "INFO" "Manager shutting down (Exit Code: $exit_code)"
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

# --- 6. Main ---
log "INFO" "Idle Manager Initialized"
update_waybar
check_and_act

# Background monitors
(
    trap "" SIGALRM # Prevent subshell from handling signals meant for parent
    until swaymsg -t subscribe '["window"]' --monitor | jq --unbuffered -c 'select(.change == "focus" or .change == "title")' 2>/dev/null | while read -r _; do
        kill -SIGALRM "$$" 2>/dev/null
    done; do sleep 2; done
) &

(
    trap "" SIGALRM
    until playerctl status --follow 2>/dev/null | while read -r _; do
        sleep 0.1
        kill -SIGALRM "$$" 2>/dev/null
    done; do sleep 5; done
) &

(
    trap "" SIGALRM
    while true; do
        if pgrep -x "swaylock" >/dev/null; then
            sleep 1
        else
            sleep 10
        fi
        kill -SIGALRM "$$" 2>/dev/null
    done
) &

while true; do wait || true; done
