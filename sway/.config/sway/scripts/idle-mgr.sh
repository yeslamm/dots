#!/bin/bash
# idle-mgr.sh - "The Ultimate Elite Edition"
# Fully hardened, context-aware, and resource-optimized.

set -euo pipefail
set -o pipefail

# --- Configuration ---
LOCK_FILE="/dev/shm/idle-mgr.lock"
PID_FILE="/dev/shm/idle-mgr.pid"
STATE_FILE="/dev/shm/idle-mgr.state"
LOG_FILE="/tmp/idle-mgr.log"
IDLE_APPS_FILE="$HOME/.config/sway/idle_apps"
IDLE_NF_APPS_FILE="$HOME/.config/sway/idle_nf_apps"
IDLE_PROCS_FILE="$HOME/.config/sway/idle_procs"
WAYBAR_SIGNAL=9

# --- State Variables ---
PAUSED=false
IDLE_PID=""
LOCKED_AT="" # Wall-clock seconds
CURRENT_POWER_SRC="NONE"
LAST_REASON=""

# Global Pattern Cache
LAST_F_MTIME=0
LAST_NF_MTIME=0
LAST_PROC_MTIME=0
CACHED_F_PATTERNS=""
CACHED_NF_PATTERNS=""
CACHED_PROC_PATTERNS="yt-dlp|makepkg|fakeroot"

# --- 1. Logging & Helpers ---

log() {
    local level="$1" msg="$2"
    local timestamp
    timestamp=$(date '+%H:%M:%S')
    
    # Simple rotation: If log > 1MB, truncate it
    if [[ -f "$LOG_FILE" ]] && [[ $(stat -c%s "$LOG_FILE") -gt 1048576 ]]; then
        echo "$timestamp [INFO] Log Truncated and Reset" > "$LOG_FILE"
    fi
    
    echo "$timestamp [$level] $msg" >>"$LOG_FILE"
}

handle_pause()  { 
    PAUSED=true
    notify-send -t 1000 -h string:x-canonical-private-synchronous:state "Idle Manager" "Paused"
    check_and_act 
}

handle_resume() { 
    PAUSED=false
    notify-send -t 1000 -h string:x-canonical-private-synchronous:state "Idle Manager" "Resumed"
    check_and_act 
}

update_waybar() {
    pkill -RTMIN+$WAYBAR_SIGNAL waybar 2>/dev/null || true
}

set_state() {
    local new_state="$1" reason="${2:-}"
    local old_state="NONE"
    [[ -f "$STATE_FILE" ]] && old_state=$(cat "$STATE_FILE" 2>/dev/null || echo "NONE")

    if [[ "$old_state" != "$new_state" ]] || [[ "$reason" != "$LAST_REASON" ]]; then
        echo -n "$new_state" >"$STATE_FILE"
        LAST_REASON="$reason"
        local log_msg="Transition: $old_state -> $new_state"
        [[ -n "$reason" ]] && log_msg="$log_msg [Reason: $reason]"
        log "STATE" "$log_msg"
        update_waybar
    fi
}

stop_idle() {
    if [[ -n "$IDLE_PID" ]]; then
        kill "$IDLE_PID" 2>/dev/null
        wait "$IDLE_PID" 2>/dev/null
        IDLE_PID=""
    fi
}

cleanup() {
    local exit_code=$?
    # Kill all child processes (monitors) spawned by this script
    pkill -P "$$" 2>/dev/null || true
    stop_idle
    rm -f "$STATE_FILE" "$PID_FILE" "$LOCK_FILE"
    update_waybar
    exit "$exit_code"
}

# --- 2. Pattern & Resource Helpers ---

update_pattern_caches() {
    local mtime
    
    # Focused Apps
    if [[ -f "$IDLE_APPS_FILE" ]]; then
        mtime=$(stat -c %Y "$IDLE_APPS_FILE" 2>/dev/null || echo 0)
        if (( mtime > LAST_F_MTIME )); then
            CACHED_F_PATTERNS=$(grep -vE '^#|^$' "$IDLE_APPS_FILE" | tr '\n' '|' | sed 's/|$//' || true)
            LAST_F_MTIME=$mtime
        fi
    else
        CACHED_F_PATTERNS=""; LAST_F_MTIME=0
    fi

    # Background Apps
    if [[ -f "$IDLE_NF_APPS_FILE" ]]; then
        mtime=$(stat -c %Y "$IDLE_NF_APPS_FILE" 2>/dev/null || echo 0)
        if (( mtime > LAST_NF_MTIME )); then
            CACHED_NF_PATTERNS=$(grep -vE '^#|^$' "$IDLE_NF_APPS_FILE" | tr '\n' '|' | sed 's/|$//' || true)
            LAST_NF_MTIME=$mtime
        fi
    else
        CACHED_NF_PATTERNS=""; LAST_NF_MTIME=0
    fi

    # Background Processes
    if [[ -f "$IDLE_PROCS_FILE" ]]; then
        mtime=$(stat -c %Y "$IDLE_PROCS_FILE" 2>/dev/null || echo 0)
        if (( mtime > LAST_PROC_MTIME )); then
            CACHED_PROC_PATTERNS=$(grep -vE '^#|^$' "$IDLE_PROCS_FILE" | tr '\n' '|' | sed 's/|$//' || true)
            LAST_PROC_MTIME=$mtime
        fi
    fi
}

get_power_status() {
    # Maintaining ACAD check for your specific laptop hardware
    if grep -q "0" /sys/class/power_supply/ACAD/online 2>/dev/null; then
        echo "BATTERY"
    else
        # Check all batteries (BAT1 on your system) for critical low charge
        shopt -s nullglob
        for bat in /sys/class/power_supply/BAT*; do
            if [[ -f "$bat/capacity" ]] && (( $(<"$bat/capacity") < 15 )); then
                echo "BATTERY"
                shopt -u nullglob
                return
            fi
        done
        shopt -u nullglob
        echo "AC"
    fi
}

# --- 3. Main Logic ---

start_idle() {
    local mode="$1"
    local t_dim t_lock t_dpms t_susp

    if [[ "$mode" == "AC" ]]; then
        t_dim=570; t_lock=600; t_dpms=900; t_susp=1200
    else
        t_dim=90; t_lock=120; t_dpms=240; t_susp=360
    fi

    if [[ -z "$IDLE_PID" ]] || ! kill -0 "$IDLE_PID" 2>/dev/null; then
        log "INFO" "Swayidle: Starting $mode profile"
        swayidle -w \
            timeout $t_dim 'brightnessctl -s set 20%' resume 'brightnessctl -r' \
            timeout $t_lock 'swaylock -f -c 000000 -F -e -k -L' \
            timeout $t_dpms 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
            timeout $t_susp 'systemctl suspend' before-sleep 'swaylock -f -c 000000 -F -e -k -L' &
        IDLE_PID=$!
        set_state "ON"
    fi
}

check_and_act() {
    # A. Power Source Check
    local p_src
    p_src=$(get_power_status)
    if [[ "$CURRENT_POWER_SRC" != "$p_src" ]]; then
        CURRENT_POWER_SRC="$p_src"
        stop_idle
    fi

    # B. Manual Pause
    if [[ "${PAUSED}" == true ]]; then
        [[ -n "$IDLE_PID" ]] && stop_idle
        set_state "PAUSED" "Manual"
        return
    fi

    # C. Sentry (Lock Safety)
    # Uses wall-clock time (date +%s) to survive suspend/resume
    if pgrep -x "swaylock" >/dev/null; then
        local now
        now=$(date +%s)
        [[ -z "$LOCKED_AT" ]] && LOCKED_AT=$now
        
        if (( now - LOCKED_AT >= 30 )); then
            LOCKED_AT=""
            log "WARN" "Sentry: Suspending locked system"
            systemctl suspend
            return
        fi
        [[ -n "$IDLE_PID" ]] && stop_idle
        set_state "LOCKED" "Sentry"
        return
    else
        LOCKED_AT=""
    fi

    # D. Inhibition - Cheap to Heavy
    
    # 1. Process Check
    update_pattern_caches
    if [[ -n "$CACHED_PROC_PATTERNS" ]]; then
        if pgrep -x "$CACHED_PROC_PATTERNS" >/dev/null; then
            [[ -n "$IDLE_PID" ]] && stop_idle
            set_state "HOLD" "Process Inhibitor"
            return
        fi
    fi

    # 2. Media Check
    if playerctl -a status 2>/dev/null | grep -q "Playing"; then
        [[ -n "$IDLE_PID" ]] && stop_idle
        set_state "HOLD" "Media Playing"
        return
    fi

    # 3. Window Tree Check
    local tree_data
    tree_data=$(swaymsg -t get_tree | jq -r '.. | select(.type? == "con" or .type? == "floating_con") | (if .focused == true then "FOCUS " else "" end) + (.app_id // .window_properties.class // "Unknown") + " " + (.name // "Untitled")' 2>/dev/null || true)
    
    if [[ -n "$tree_data" ]]; then
        if [[ -n "$CACHED_NF_PATTERNS" ]]; then
            local match
            match=$(echo "$tree_data" | grep -Ei "$CACHED_NF_PATTERNS" | head -n 1 || true)
            if [[ -n "$match" ]]; then
                [[ -n "$IDLE_PID" ]] && stop_idle
                set_state "HOLD" "App (BG): ${match#FOCUS }"
                return
            fi
        fi

        if [[ -n "$CACHED_F_PATTERNS" ]]; then
            local match
            match=$(echo "$tree_data" | grep "^FOCUS " | grep -Ei "$CACHED_F_PATTERNS" | head -n 1 || true)
            if [[ -n "$match" ]]; then
                [[ -n "$IDLE_PID" ]] && stop_idle
                set_state "HOLD" "App (Focus): ${match#FOCUS }"
                return
            fi
        fi
    fi

    # 4. PipeWire Check
    if pw-dump | jq -e '.[] | select(.type == "PipeWire:Interface:Node" and .info.props."media.class" == "Stream/Output/Audio" and .info.state == "running")' >/dev/null 2>&1; then
        [[ -n "$IDLE_PID" ]] && stop_idle
        set_state "HOLD" "Audio Stream"
        return
    fi

    start_idle "$CURRENT_POWER_SRC"
}

# --- 4. Initialization & Singleton ---

exec 8>"$LOCK_FILE"
if ! flock -n 8; then
    if [[ -f "$PID_FILE" ]]; then
        OLD_PID=$(cat "$PID_FILE" 2>/dev/null || echo "")
        if [[ -n "$OLD_PID" ]] && kill -0 "$OLD_PID" 2>/dev/null; then
            CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "ON")
            [[ "$CURRENT_STATE" == "PAUSED" ]] && kill -SIGUSR2 "$OLD_PID" || kill -SIGUSR1 "$OLD_PID"
        fi
    fi
    exit 0
fi
echo -n $$ >"$PID_FILE"

trap handle_pause SIGUSR1
trap handle_resume SIGUSR2
trap "check_and_act" SIGALRM
trap cleanup EXIT INT TERM

# --- 5. Execution ---

update_waybar
check_and_act

(
    trap "" SIGALRM
    until swaymsg -t subscribe '["window"]' --monitor | jq --unbuffered -c 'select(.change == "focus" or .change == "new" or .change == "close")' 2>/dev/null | while read -r _; do
        sleep 0.2
        kill -SIGALRM "$$" 2>/dev/null
    done; do sleep 2; done
) &

(
    trap "" SIGALRM
    until playerctl status --follow 2>/dev/null | while read -r _; do
        kill -SIGALRM "$$" 2>/dev/null
    done; do sleep 5; done
) &

(
    trap "" SIGALRM
    while true; do
        if pgrep -x "swaylock" >/dev/null; then
            sleep 1
        else
            sleep 30
        fi
        kill -SIGALRM "$$" 2>/dev/null
    done
) &

while true; do wait || true; done
