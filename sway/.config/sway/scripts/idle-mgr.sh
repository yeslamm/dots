#!/bin/bash
# idle-mgr.sh - "Hardened Edition v1.6" (Definitive)
# Optimized for event-driven reliability and high efficiency.

set -euo pipefail

# --- Environment & Paths ---
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
LOCK_FILE="$RUNTIME_DIR/idle-mgr.lock"
PID_FILE="$RUNTIME_DIR/idle-mgr.pid"
STATE_FILE="$RUNTIME_DIR/idle-mgr.state"
REASON_FILE="$STATE_FILE.reason"
LOG_FILE="$RUNTIME_DIR/idle-mgr.log"

IDLE_APPS_FILE="$HOME/.config/sway/idle_apps"
IDLE_PROCS_FILE="$HOME/.config/sway/idle_procs"
WAYBAR_SIGNAL=9

# --- State & Flags ---
PAUSED=false
NEEDS_CHECK=true
IDLE_PID=""
LOCKED_AT=""
CURRENT_POWER_SRC="NONE"
LAST_CHECK_TIME=0
DEBOUNCE_NSEC=300000000 # 0.3s Debounce (Snappy Response)

# --- Caching ---
F_PATTERNS=""
NF_PATTERNS=""

# --- Logging ---
log() {
    local timestamp
    timestamp=$(date '+%H:%M:%S')
    if [[ -f "$LOG_FILE" ]] && [[ $(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0) -gt 1048576 ]]; then
        mv "$LOG_FILE" "$LOG_FILE.old"
    fi
    echo "$timestamp [$1] $2" >>"$LOG_FILE"
}

# --- Dependency Check ---
for cmd in jq pw-dump swaymsg playerctl fuser inotifywait; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        notify-send -u critical "Idle Manager" "Missing dependency: $cmd"
        exit 1
    fi
done

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
    [[ -f "$IDLE_PROCS_FILE" ]] && NF_PATTERNS=$(grep -vE '^#|^$' "$IDLE_PROCS_FILE" | tr '\n' '|' | sed 's/|$//' || true)
}

stop_idle() {
    if [[ -n "$IDLE_PID" ]]; then
        kill "$IDLE_PID" 2>/dev/null && wait "$IDLE_PID" 2>/dev/null || true
        IDLE_PID=""
    fi
    pkill -P "$$" swayidle 2>/dev/null || true
}

start_idle() {
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
    local now
    now=$(date +%s%N)

    # Wake Detection: If the time jump is > 5s (and not the first run), we likely just woke from suspend.
    # Reset LOCKED_AT to prevent an immediate re-suspend loop.
    if [[ "$LAST_CHECK_TIME" -ne 0 ]] && (((now - LAST_CHECK_TIME) > 5000000000)); then
        log "INFO" "Wake detected (Time jump: $(((now - LAST_CHECK_TIME) / 1000000000))s). Resetting Sentry."
        LOCKED_AT=""
    fi

    if (((now - LAST_CHECK_TIME) < DEBOUNCE_NSEC)); then return; fi
    LAST_CHECK_TIME=$now

    # Power Source Switch Detection
    local p_src
    p_src=$(grep -q "1" /sys/class/power_supply/ACAD/online 2>/dev/null && echo "AC" || echo "BATTERY")
    [[ "$CURRENT_POWER_SRC" != "$p_src" ]] && {
        CURRENT_POWER_SRC="$p_src"
        stop_idle
    }

    # Manual Pause
    if [[ "$PAUSED" == "true" ]]; then
        stop_idle
        set_state "PAUSED" "Manual Toggle"
        return
    fi

    # Sentry (Lock) - Kept above inhibitors as requested
    if pgrep -x "swaylock" >/dev/null; then
        local cur
        cur=$(awk '{print int($1)}' /proc/uptime)
        [[ -z "$LOCKED_AT" ]] && LOCKED_AT=$cur
        if ((cur - LOCKED_AT >= 60)); then
            log "SENTRY" "Locked for >60s, suspending system."
            systemctl suspend
            LOCKED_AT="" # Reset after triggering to prevent loop if suspend fails
            return
        fi
        stop_idle
        set_state "LOCKED" "Locked/Sentry"
        return
    else
        LOCKED_AT=""
    fi

    # 1. Webcam (Universal Meeting Protection)
    if fuser /dev/video* >/dev/null 2>&1; then
        stop_idle
        set_state "HOLD" "Webcam Active"
        return
    fi

    # 2. Window Patterns (Focused or Background Processes)
    if [[ -n "$F_PATTERNS" ]]; then
        local focused
        focused=$(cat "$RUNTIME_DIR/focused_app" 2>/dev/null || echo "unknown")
        if [[ "$focused" != "unknown" ]] && echo "$focused" | grep -Ei "$F_PATTERNS" >/dev/null; then
            stop_idle
            set_state "HOLD" "App Focus: $focused"
            return
        fi
    fi

    if [[ -n "$NF_PATTERNS" ]]; then
        if pgrep -f -i "$NF_PATTERNS" >/dev/null; then
            local match
            match=$(pgrep -f -i -a "$NF_PATTERNS" | head -n 1 | awk '{print $2}')
            stop_idle
            set_state "HOLD" "Process Active: $match"
            return
        fi
    fi

    # 3. Media (MPRIS Control)
    if playerctl -a status 2>/dev/null | grep -q "Playing"; then
        stop_idle
        set_state "HOLD" "Media Playback"
        return
    fi

    # 4. Audio (Raw PipeWire/ALSA Stream)
    if grep -qv "closed" /proc/asound/card*/pcm*/sub*/status 2>/dev/null; then
        local node_name
        node_name=$(pw-dump | jq -r '.[] | select(.type == "PipeWire:Interface:Node" and .info.state == "running" and .info.props."media.class" == "Stream/Output/Audio" and (.info.props."node.name" | test("notification|alert|event|easyeffects"; "i") | not)) | .info.props["node.name"]' | head -n 1 || true)
        if [[ -n "$node_name" ]]; then
            stop_idle
            set_state "HOLD" "Audio Stream Active"
            return
        fi
    fi

    start_idle
}

# --- Initialization & Orchestration ---

cleanup() {
    local exit_code=$?
    log "INFO" "Shutdown initiated (Code: $exit_code)"
    stop_idle
    # Surgical Cleanup: Kill only jobs started by this shell instance
    local pids
    pids=$(jobs -p)
    if [[ -n "$pids" ]]; then
        # shellcheck disable=SC2086
        kill $pids 2>/dev/null || true
    fi
    rm -f "$PID_FILE" "$STATE_FILE" "$REASON_FILE" "$LOCK_FILE" "$RUNTIME_DIR/focused_app"
    update_waybar
    exit "$exit_code"
}

# Traps now only set a flag for the main loop
trap "PAUSED=true; NEEDS_CHECK=true" SIGUSR1
trap "PAUSED=false; NEEDS_CHECK=true" SIGUSR2
trap "NEEDS_CHECK=true" SIGALRM
trap cleanup EXIT INT TERM

load_patterns

# Background Monitors (Event Sources)
(
    trap "" SIGALRM
    until swaymsg -t subscribe '["window"]' --monitor | jq --unbuffered -r 'select(.change == "focus") | .container.app_id // .container.window_properties.class // "unknown"' 2>/dev/null | while read -r app; do
        echo -n "$app" >"$RUNTIME_DIR/focused_app"
        kill -SIGALRM "$$" 2>/dev/null
    done; do sleep 2; done
) &
(
    trap "" SIGALRM
    until playerctl status --follow 2>/dev/null | while read -r _; do kill -SIGALRM "$$" 2>/dev/null; done; do sleep 5; done
) &
(
    trap "" SIGALRM
    while true; do
        sleep 2 # Throttled to 2s for battery efficiency (fallback heartbeat)
        kill -SIGALRM "$$" 2>/dev/null
    done
) &

# Optional: Watch patterns for changes
if command -v inotifywait >/dev/null; then
    (
        trap "" SIGALRM
        while inotifywait -e modify "$IDLE_APPS_FILE" "$IDLE_PROCS_FILE" 2>/dev/null; do
            load_patterns
            kill -SIGALRM "$$" 2>/dev/null
        done
    ) &
fi

# --- The Main Event Loop ---
log "INFO" "Idle Manager v1.6 Started"
while true; do
    if [[ "$NEEDS_CHECK" == "true" ]]; then
        NEEDS_CHECK=false
        check_and_act
    fi
    sleep 0.1
done
