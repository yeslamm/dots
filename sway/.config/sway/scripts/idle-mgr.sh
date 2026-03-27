#!/bin/bash
# idle-mgr.sh - "Definitive Edition v1.3" (Hardened & Bug-Fixed)
# Standardized paths, integer-based debounce, and performance-tuned.

set -euo pipefail

# --- Environment & Paths (Standardized) ---
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
LOCK_FILE="$RUNTIME_DIR/idle-mgr.lock"
PID_FILE="$RUNTIME_DIR/idle-mgr.pid"
STATE_FILE="$RUNTIME_DIR/idle-mgr.state"
REASON_FILE="$STATE_FILE.reason"
LOG_FILE="/tmp/idle-mgr.log"

IDLE_APPS_FILE="$HOME/.config/sway/idle_apps"
IDLE_NF_APPS_FILE="$HOME/.config/sway/idle_nf_apps"
WAYBAR_SIGNAL=9

# --- State ---
PAUSED=false
IDLE_PID=""
LOCKED_AT=""
CURRENT_POWER_SRC="NONE"
LAST_CHECK_TIME=0
# 0.2s in nanoseconds (Integer only for Bash math)
DEBOUNCE_NSEC=200000000

# --- Caching ---
F_PATTERNS=""
NF_PATTERNS=""

log() {
    local timestamp
    timestamp=$(date '+%H:%M:%S')
    echo "$timestamp [$1] $2" >>"$LOG_FILE"
}

# --- Singleton & Process Control ---
exec 8>"$LOCK_FILE"
if ! flock -n 8; then
    if [ -f "$PID_FILE" ]; then
        OLD_PID=$(cat "$PID_FILE" 2>/dev/null || true)
        if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
            STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "ON")
            if [[ "$STATE" == "PAUSED" ]]; then
                kill -SIGUSR2 "$OLD_PID"
                notify-send -t 1000 -h string:x-canonical-private-synchronous:state " Idle Manager: Resumed"
            else
                kill -SIGUSR1 "$OLD_PID"
                notify-send -t 1000 -h string:x-canonical-private-synchronous:state " Idle Manager: Paused"
            fi
        fi
    fi
    exit 0
fi
echo $$ >"$PID_FILE"

update_waybar() { pkill -RTMIN+$WAYBAR_SIGNAL waybar 2>/dev/null || true; }

set_state() {
    local new_state="$1" reason="${2:-}"
    local old_state old_reason
    old_state=$(cat "$STATE_FILE" 2>/dev/null || echo "NONE")
    old_reason=$(cat "$REASON_FILE" 2>/dev/null || echo "")

    if [[ "$old_state" != "$new_state" ]] || [[ "$reason" != "$old_reason" ]]; then
        echo -n "$new_state" >"$STATE_FILE"
        echo -n "$reason" >"$REASON_FILE"
        log "STATE" "$old_state -> $new_state ($reason)"
        update_waybar
    fi
}

load_patterns() {
    [[ -f "$IDLE_APPS_FILE" ]] && F_PATTERNS=$(grep -vE '^#|^$' "$IDLE_APPS_FILE" | tr '\n' '|' | sed 's/|$//' || true)
    [[ -f "$IDLE_NF_APPS_FILE" ]] && NF_PATTERNS=$(grep -vE '^#|^$' "$IDLE_NF_APPS_FILE" | tr '\n' '|' | sed 's/|$//' || true)
}

stop_idle() {
    if [[ -n "$IDLE_PID" ]]; then
        kill "$IDLE_PID" 2>/dev/null && wait "$IDLE_PID" 2>/dev/null || true
        IDLE_PID=""
    fi
    # Only kill swayidle processes that are direct children of THIS script
    pkill -P "$$" swayidle 2>/dev/null || true
}

start_idle() {
    # If already running, don't restart (prevents screen flicker)
    pgrep -x swayidle >/dev/null && [[ "$(cat "$STATE_FILE" 2>/dev/null)" == "ON" ]] && return

    local on_ac
    on_ac=$(grep -q "1" /sys/class/power_supply/ACAD/online 2>/dev/null && echo true || echo false)

    local t_dim=90 t_lock=120 t_dpms=240 t_susp=360
    [[ "$on_ac" == "true" ]] && {
        t_dim=570
        t_lock=600
        t_dpms=900
        t_susp=1200
    }

    stop_idle
    swayidle -w \
        timeout "$t_dim" 'brightnessctl -s set 20%' resume 'brightnessctl -r' \
        timeout "$t_lock" 'swaylock -f -c 000000 -F -e -k -L' \
        timeout "$t_dpms" 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
        timeout "$t_susp" 'systemctl suspend' before-sleep 'swaylock -f -c 000000 -F -e -k -L' &
    IDLE_PID=$!
    set_state "ON" "Active ($([ "$on_ac" == "true" ] && echo AC || echo BAT))"
}

# --- Core Logic ---

check_and_act() {
    # 1. Debounce (Prevent signal spam) - NanoSec Math
    local now
    now=$(date +%s%N)
    if (((now - LAST_CHECK_TIME) < DEBOUNCE_NSEC)); then return; fi
    LAST_CHECK_TIME=$now

    # 2. Power & Manual
    local p_src
    p_src=$(grep -q "1" /sys/class/power_supply/ACAD/online 2>/dev/null && echo "AC" || echo "BATTERY")
    [[ "$CURRENT_POWER_SRC" != "$p_src" ]] && {
        CURRENT_POWER_SRC="$p_src"
        stop_idle
    }
    [[ "$PAUSED" == "true" ]] && {
        stop_idle
        set_state "PAUSED" "Manual Toggle"
        return
    }

    # 3. Sentry (Lock)
    if pgrep -x "swaylock" >/dev/null; then
        local cur
        cur=$(awk '{print int($1)}' /proc/uptime)
        [[ -z "$LOCKED_AT" ]] && LOCKED_AT=$cur
        if ((cur - LOCKED_AT >= 30)); then
            systemctl suspend
            return
        fi
        stop_idle
        set_state "LOCKED" "Locked/Sentry"
        return
    else
        LOCKED_AT=""
    fi

    # 4. Inhibition
    # A. Windows & Wayland Inhibitors (Optimized JQ)
    local win_data
    win_data=$(swaymsg -t get_tree 2>/dev/null | jq -c '.. | select(.type? == "con" or .type? == "floating_con") | {f: .focused, id: (.app_id // .window_properties.class // "unknown"), n: (.name // ""), i: .idle_inhibitors?.application?}' 2>/dev/null || true)

    if [[ -n "$win_data" ]]; then
        # Check for Wayland-native idle inhibitors (e.g. Firefox/MPV/Games)
        if echo "$win_data" | grep -q '"i":"enabled"'; then
            local inhibitor_app
            inhibitor_app=$(echo "$win_data" | jq -r 'select(.i == "enabled") | "\(.id) [\(.n)]"' | head -n 1 || true)
            stop_idle
            set_state "HOLD" "Wayland Protocol: $inhibitor_app"
            return
        fi

        if [[ -n "$F_PATTERNS" ]]; then
            local focused
            focused=$(echo "$win_data" | jq -r 'select(.f == true) | "\(.id) [\(.n)]"' | head -n 1 || true)
            if [[ -n "$focused" ]] && echo "$focused" | grep -Ei "$F_PATTERNS" >/dev/null; then
                stop_idle
                set_state "HOLD" "App Focus: $focused"
                return
            fi
        fi
        if [[ -n "$NF_PATTERNS" ]]; then
            local match
            match=$(echo "$win_data" | jq -r 'select(.id != "unknown") | "\(.id) [\(.n)]"' | grep -Ei "$NF_PATTERNS" | head -n 1 || true)
            if [[ -n "$match" ]]; then
                stop_idle
                set_state "HOLD" "App Background: $match"
                return
            fi
        fi
    fi

    # B. Media (Playerctl)
    if playerctl -a status 2>/dev/null | grep -q "Playing"; then
        stop_idle
        set_state "HOLD" "Media Playback"
        return
    fi

    # C. Audio
    local pw_node
    pw_node=$(pw-dump | jq -r '.[] | select(.type == "PipeWire:Interface:Node" and .info.state == "running" and .info.props."media.class" == "Stream/Output/Audio" and (.info.props."node.name" | test("chromium|firefox|brave|librewolf|notification"; "i") | not)) | .info.props["node.name"]' | head -n 1 || true)
    [[ -n "$pw_node" ]] && {
        stop_idle
        set_state "HOLD" "Audio: $pw_node"
        return
    }


    start_idle
}

# --- Initialization & Orchestration ---

cleanup() {
    local exit_code=$?
    log "INFO" "Shutdown initiated (Code: $exit_code)"
    stop_idle
    pkill -P "$$" 2>/dev/null || true
    rm -f "$PID_FILE" "$STATE_FILE" "$REASON_FILE" "$LOCK_FILE"
    update_waybar
    exit "$exit_code"
}

trap "PAUSED=true; check_and_act" SIGUSR1
trap "PAUSED=false; check_and_act" SIGUSR2
trap "check_and_act" SIGALRM
trap cleanup EXIT INT TERM

load_patterns
check_and_act

# Background Monitors (The Orchestration)
(
    trap "" SIGALRM
    until swaymsg -t subscribe '["window"]' --monitor | jq --unbuffered -c 'select(.change == "focus")' 2>/dev/null | while read -r _; do kill -SIGALRM "$$" 2>/dev/null; done; do sleep 2; done
) &
(
    trap "" SIGALRM
    until playerctl status --follow 2>/dev/null | while read -r _; do kill -SIGALRM "$$" 2>/dev/null; done; do sleep 5; done
) &
(
    trap "" SIGALRM
    while true; do
        sleep 10
        kill -SIGALRM "$$" 2>/dev/null
    done
) &

# Watch patterns for changes (Optional, requires inotify-tools)
if command -v inotifywait >/dev/null; then
    (
        trap "" SIGALRM
        while inotifywait -e modify "$IDLE_APPS_FILE" "$IDLE_NF_APPS_FILE" 2>/dev/null; do
            load_patterns
            kill -SIGALRM "$$" 2>/dev/null
        done
    ) &
fi

while true; do wait || true; done
