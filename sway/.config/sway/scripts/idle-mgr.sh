#!/bin/bash
# idle-mgr.sh - "Hybrid Edition v2.2 (Standardized Edition)"
# Standardized paths and zero-polling architecture.

set -euo pipefail

# --- Environment & Paths ---
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
LOCK_FILE="$RUNTIME_DIR/idle-mgr.lock"
PID_FILE="$RUNTIME_DIR/idle-mgr.pid"
STATE_FILE="$RUNTIME_DIR/idle-mgr.state"
REASON_FILE="$STATE_FILE.reason"
LOG_FILE="$RUNTIME_DIR/idle-mgr.log"
WIN_INHIB_FILE="$RUNTIME_DIR/idle-mgr.win" # UI state buffer

IDLE_PROCS_FILE="$HOME/.config/sway/idle_procs"
WAYBAR_SIGNAL=9

# --- State & Flags ---
PAUSED=false
NEEDS_CHECK=true
IDLE_PID=""
LOCKED_AT=""
CURRENT_POWER_SRC="NONE"
LAST_CHECK_TIME=0
DEBOUNCE_NSEC=300000000 # 0.3s Debounce

# --- Caching ---
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
for cmd in jq swaymsg playerctl inotifywait wayland-pipewire-idle-inhibit pactl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        notify-send -u critical "Idle Manager" "Missing dependency: $cmd"
        exit 1
    fi
done

# --- Singleton & Process Control ---
exec 8>"$LOCK_FILE"
if ! flock -n 8; then
    # Another instance is already running (it owns the lock).
    # This short-lived process only sends a signal to toggle.
    if [ -f "$PID_FILE" ]; then
        OLD_PID=$(<"$PID_FILE")
        if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
            STATE=$(<"$STATE_FILE")
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
    # If swayidle is already running, do absolutely nothing. Return immediately.
    if [[ -n "$IDLE_PID" ]] && kill -0 "$IDLE_PID" 2>/dev/null; then
        return
    fi

    local on_ac
    on_ac=$(grep -q "1" /sys/class/power_supply/ACAD/online 2>/dev/null && echo true || echo false)

    local t_dim=90 t_lock=120 t_dpms=240 t_susp=360
    [[ "$on_ac" == "true" ]] && {
        t_dim=570
        t_lock=600
        t_dpms=900
        t_susp=1200
    }

    stop_idle # Safety cleanup before spawning
    swayidle -w \
        timeout "$t_dim" 'brightnessctl -s set 20%' resume 'brightnessctl -r' \
        timeout "$t_lock" 'swaylock -f -c 000000 -F -e -k -L' \
        timeout "$t_dpms" 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
        timeout "$t_susp" 'systemctl suspend' before-sleep 'swaylock -f -c 000000 -F -e -k -L' &
    IDLE_PID=$!
}

# --- Core Logic ---

check_and_act() {
    local now
    now=$(date +%s%N)

    # Wake Detection
    if [[ "$LAST_CHECK_TIME" -ne 0 ]] && (((now - LAST_CHECK_TIME) > 5000000000)); then
        log "INFO" "Wake detected. Resetting Sentry."
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
        pkill -x wayland-pipewire-idle-inhibit || true
        set_state "PAUSED" "Manual Toggle"
        return
    fi

    # Sentry (Lock)
    if pgrep -x "swaylock" >/dev/null; then
        local cur
        cur=$(awk '{print int($1)}' /proc/uptime)
        [[ -z "$LOCKED_AT" ]] && LOCKED_AT=$cur
        if ((cur - LOCKED_AT >= 60)); then
            log "SENTRY" "Locked for >60s, suspending system."
            systemctl suspend
            LOCKED_AT=""
            return
        fi
        stop_idle
        set_state "LOCKED" "Locked/Sentry"
        return
    else
        LOCKED_AT=""
    fi

    # =================================================================
    # 1. HARDWARE/SYSTEM INHIBITORS (Script must physically stop swayidle)
    # =================================================================

    # Background Processes
    if [[ -n "$NF_PATTERNS" ]]; then
        if pgrep -f -i "$NF_PATTERNS" >/dev/null; then
            local match
            match=$(pgrep -f -i -a "$NF_PATTERNS" | head -n 1 | awk '{print $2}')
            stop_idle
            set_state "HOLD" "Process: $match"
            return
        fi
    fi

    # =================================================================
    # 2. SOFTWARE/NATIVE INHIBITORS (Native/Sway handles it, script updates UI)
    # =================================================================

    # Self-Healing: Ensure native inhibitor is running in the background
    pgrep -f wayland-pipewire-idle-inhibit >/dev/null || wayland-pipewire-idle-inhibit &

    # Window Inhibitors (Sway Native)
    local win_inhib
    win_inhib=$(cat "$WIN_INHIB_FILE" 2>/dev/null || echo "NONE")

    if [[ "$win_inhib" != "NONE" ]]; then
        start_idle
        set_state "HOLD" "Window: $win_inhib"
        return
    fi

    # Media Playback (UI Only)
    if playerctl -a status 2>/dev/null | grep -q "Playing"; then
        start_idle
        set_state "HOLD" "Media Playback"
        return
    fi

    # Audio Stream (Pipewire) - UI Only (Inhibit handled by Native Daemon)
    if pactl list sinks | grep -q "State: RUNNING"; then
        start_idle
        set_state "HOLD" "Audio Stream"
        return
    fi

    # =================================================================
    # 3. DEFAULT (No inhibitors active)
    # =================================================================
    start_idle
    set_state "ON" "Active ($CURRENT_POWER_SRC)"
}

# --- Initialization & Orchestration ---

cleanup() {
    local exit_code=$?
    log "INFO" "Shutdown initiated (Code: $exit_code)"
    stop_idle
    pkill -x wayland-pipewire-idle-inhibit || true
    # Surgical Cleanup: Kill only jobs started by this specific shell process
    local pids
    pids=$(jobs -p)
    if [[ -n "$pids" ]]; then
        # shellcheck disable=SC2086
        kill $pids 2>/dev/null || true
    fi
    rm -f "$PID_FILE" "$STATE_FILE" "$REASON_FILE" "$LOCK_FILE" "$WIN_INHIB_FILE"
    update_waybar
    exit "$exit_code"
}

trap "PAUSED=true; NEEDS_CHECK=true" SIGUSR1
trap "PAUSED=false; NEEDS_CHECK=true" SIGUSR2
trap "NEEDS_CHECK=true" SIGALRM
trap cleanup EXIT INT TERM

load_patterns

# Ensure a single, fresh instance of the native inhibitor
pkill -x wayland-pipewire-idle-inhibit || true
wayland-pipewire-idle-inhibit &

# Background Monitors (Kept as jobs for surgical cleanup)
(
    trap "" SIGALRM
    swaymsg -t subscribe '["window"]' --monitor | jq --unbuffered -r '
      select(.change == "focus" or .change == "fullscreen_mode" or .change == "mark") |
      if (.container.marks // [] | index("explicit")) then ("Explicit: " + (.container.app_id // .container.window_properties.class // "Win"))
      elif (.container.marks // [] | index("implicit")) then ("Implicit: " + (.container.app_id // .container.window_properties.class // "Win"))
      elif .container.fullscreen_mode == 1 then ("F: " + (.container.app_id // .container.window_properties.class // "Win"))
      else "NONE"
      end
    ' 2>/dev/null | while read -r status; do
        echo -n "$status" >"$WIN_INHIB_FILE"
        kill -SIGALRM "$$" 2>/dev/null
    done
) &

(
    trap "" SIGALRM
    until playerctl status --follow 2>/dev/null | while read -r _; do kill -SIGALRM "$$" 2>/dev/null; done; do sleep 5; done
) &

# Audio Event Monitor (Instant response for YouTube/Browsers)
(
    trap "" SIGALRM
    until pactl subscribe 2>/dev/null | grep --line-buffered "sink" | while read -r _; do
        kill -SIGALRM "$$" 2>/dev/null
    done; do sleep 5; done
) &

(
    trap "" SIGALRM
    while true; do
        sleep 60 # Heartbeat Safety Check (Zero-Polling)
        kill -SIGALRM "$$" 2>/dev/null
    done
) &

if command -v inotifywait >/dev/null; then
    (
        trap "" SIGALRM
        while inotifywait -e modify "$IDLE_PROCS_FILE" 2>/dev/null; do
            load_patterns
            kill -SIGALRM "$$" 2>/dev/null
        done
    ) &
fi

# --- The Main Event Loop ---
log "INFO" "Idle Manager v2.2 (Standardized) Started"
while true; do
    if [[ "$NEEDS_CHECK" == "true" ]]; then
        NEEDS_CHECK=false
        check_and_act
    fi
    # True Zero-Polling: Wait for a signal. Kill the sleep process afterwards to prevent leaks.
    sleep infinity &
    SLEEP_PID=$!
    wait "$SLEEP_PID" || true
    kill "$SLEEP_PID" 2>/dev/null || true
done
