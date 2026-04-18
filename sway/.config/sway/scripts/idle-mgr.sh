#!/bin/bash
# idle-mgr.sh - "Hybrid Edition v3.6 (God-Tier)"
# Rules: Pure Daemon. Zero-Fork State Checks. Process Pruning. Perfect IPC.

set -euo pipefail

# --- Environment & Paths ---
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
LOCK_FILE="$RUNTIME_DIR/idle-mgr.lock"
PID_FILE="$RUNTIME_DIR/idle-mgr.pid"
LOG_FILE="$RUNTIME_DIR/idle-mgr.log"
STATE_FILE="$RUNTIME_DIR/idle-mgr.state"

IDLE_PROCS_FILE="$HOME/.config/sway/idle_procs"

# --- Constants ---
WAYBAR_SIGNAL=12

# --- State ---
PAUSED=false
NEEDS_CHECK=true
IDLE_PID=""
LOCKED_AT=""
CURRENT_POWER_SRC="NONE"

# --- Memory Cache ---
MEM_STATE="INIT"
MEM_REASON=""

# --- Logging ---
log() {
    local timestamp
    timestamp=$(date '+%H:%M:%S')
    if [[ -f "$LOG_FILE" ]] && [[ $(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0) -gt 1048576 ]]; then
        mv "$LOG_FILE" "$LOG_FILE.old"
    fi
    printf "%s [%s] %s\n" "$timestamp" "$1" "$2" >>"$LOG_FILE"
}

# --- Singleton & Process Control ---
# shellcheck disable=SC2188
exec 8>"$LOCK_FILE"
if ! flock -n 8; then
    # Keybind execution pokes the running instance with a TOGGLE signal
    if [[ -f "$PID_FILE" ]]; then
        OLD_PID=$(<"$PID_FILE")
        [[ -n "$OLD_PID" ]] && kill -0 "$OLD_PID" 2>/dev/null && kill -SIGRTMIN+1 "$OLD_PID"
    fi
    exit 0
fi
printf "%s" "$$" >"$PID_FILE"

# --- In-Memory IPC Logic ---
set_pause() {
    local target_state="$1"
    [[ "$PAUSED" == "$target_state" ]] && return # Do nothing if already in desired state

    PAUSED="$target_state"
    if [[ "$PAUSED" == "true" ]]; then
        notify-send -t 1500 -h string:x-canonical-private-synchronous:idlemgr " Idle Manager: Paused"
    else
        notify-send -t 1500 -h string:x-canonical-private-synchronous:idlemgr " Idle Manager: Resumed"
    fi
    NEEDS_CHECK=true
}

toggle_pause() {
    if [[ "$PAUSED" == "true" ]]; then
        set_pause "false"
    else
        set_pause "true"
    fi
}

track_state() {
    local new_state="$1" reason="${2:-}"
    if [[ "$MEM_STATE" != "$new_state" ]] || [[ "$MEM_REASON" != "$reason" ]]; then
        log "STATE" "${MEM_STATE} -> ${new_state} (${reason})"
        MEM_STATE="$new_state"
        MEM_REASON="$reason"

        # UI Labels: ON, HOLD, PAUSE, LOCK
        local display_state
        case "$new_state" in
            "ON")     display_state="ON"    ;;
            "HOLD")   display_state="HOLD"  ;;
            "PAUSED") display_state="PAUSE" ;;
            "LOCKED") display_state="LOCK"  ;;
            *)        display_state="$new_state" ;;
        esac

        # Write state for Waybar
        printf "%s\n%s" "$display_state" "$reason" > "$STATE_FILE"
        pkill -RTMIN+$WAYBAR_SIGNAL waybar 2>/dev/null || true
    fi
}

stop_idle() {
    if [[ -n "$IDLE_PID" ]]; then
        kill "$IDLE_PID" 2>/dev/null && wait "$IDLE_PID" 2>/dev/null || true
        IDLE_PID=""
    fi
    pkill -P "$$" swayidle 2>/dev/null || true
}

start_idle() {
    if [[ -n "$IDLE_PID" ]] && kill -0 "$IDLE_PID" 2>/dev/null; then return; fi
    local on_ac=false t_dim=90 t_lock=120 t_dpms=240 t_susp=360

    # Generic AC check
    if grep -q 1 /sys/class/power_supply/*/online 2>/dev/null; then on_ac=true; fi

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
}

# --- Core Logic ---
check_and_act() {
    # 1. Sentry (Auto-Suspend on Lock) - ABSOLUTE PRIORITY
    if pgrep -x "swaylock" >/dev/null; then
        local cur uptime
        # Pure Bash zero-fork uptime read
        read -r uptime _ </proc/uptime
        cur=${uptime%%.*}

        [[ -z "$LOCKED_AT" ]] && LOCKED_AT=$cur

        # If the manager is paused via lock-ns.sh, hold the lock but DO NOT suspend.
        if [[ "$PAUSED" == "true" ]]; then
            stop_idle
            track_state "LOCKED" "No-Suspend"
            return
        fi

        # Normal Auto-Lock Suspend
        if ((cur - LOCKED_AT >= 60)); then
            log "SENTRY" "Locked for >60s, suspending system."
            systemctl suspend
            LOCKED_AT=""
            return
        fi
        stop_idle
        track_state "LOCKED" "Sentry"
        return
    else
        LOCKED_AT=""
    fi

    # 2. Manual Pause
    if [[ "$PAUSED" == "true" ]]; then
        stop_idle
        track_state "PAUSED" "Manual Toggle"
        return
    fi

    # 3. Power Source
    local p_src="BATTERY"
    if grep -q 1 /sys/class/power_supply/*/online 2>/dev/null; then p_src="AC"; fi
    [[ "$CURRENT_POWER_SRC" != "$p_src" ]] && {
        CURRENT_POWER_SRC="$p_src"
        stop_idle
    }

    # 4. CLI Processes
    if [[ -f "$IDLE_PROCS_FILE" ]]; then
        local pats
        pats=$(grep -vE '^#|^$' "$IDLE_PROCS_FILE" | tr '\n' '|' | sed 's/|$//' || true)
        if [[ -n "$pats" ]] && pgrep -i "^($pats)$" >/dev/null; then
            local pid match
            # Optimized to avoid head and tail subshells
            pid=$(pgrep -i -o "^($pats)$")
            match=$(ps -p "$pid" -o comm=)
            stop_idle
            track_state "HOLD" "Process: $match"
            return
        fi
    fi

    # 5. Sway Windows (Native Inhibitors)
    local sway_inhib
    sway_inhib=$(swaymsg -t get_tree | jq -r '.. | select(.inhibit_idle? == true) | (if .idle_inhibitors.user != "none" then "User: " else "App: " end) + (.app_id // .window_properties.class // "Win")' | head -n 1)
    if [[ -n "$sway_inhib" ]]; then
        stop_idle
        track_state "HOLD" "$sway_inhib"
        return
    fi

    # 6. Media / Audio
    if playerctl -a status 2>/dev/null | grep -q "Playing"; then
        stop_idle
        track_state "HOLD" "Media Playback"
        return
    fi
    if pactl list sinks | grep -q "State: RUNNING"; then
        stop_idle
        track_state "HOLD" "Audio Stream"
        return
    fi

    # 7. Default
    start_idle
    track_state "ON" "Active ($CURRENT_POWER_SRC)"
}

# --- Orchestration ---
cleanup() {
    log "INFO" "Shutdown initiated"
    stop_idle
    pkill -x wayland-pipewire-idle-inhibit 2>/dev/null || true

    local pids
    pids=$(jobs -p)
    if [[ -n "$pids" ]]; then
        # Prune the direct children of the subshells to prevent zombies
        for pid in $pids; do
            pkill -P "$pid" 2>/dev/null || true
        done

        # Then kill the subshells themselves
        # shellcheck disable=SC2086
        kill $pids 2>/dev/null || true
    fi
    rm -f "$PID_FILE" "$LOCK_FILE" "$STATE_FILE"
    exit 0
}

trap 'set_pause "true"' SIGUSR1
trap 'set_pause "false"' SIGUSR2
trap 'toggle_pause' SIGRTMIN+1
trap "NEEDS_CHECK=true" SIGALRM
trap cleanup EXIT INT TERM

# Fire and forget the pipewire inhibitor
pkill -x wayland-pipewire-idle-inhibit 2>/dev/null || true
wayland-pipewire-idle-inhibit &

# Event Monitors
(
    trap "" SIGALRM
    swaymsg -t subscribe '["window", "workspace"]' --monitor | while read -r _; do
        sleep 0.15
        kill -SIGALRM "$$" 2>/dev/null
    done
) &
(
    trap "" SIGALRM
    until playerctl status --follow 2>/dev/null | while read -r _; do kill -SIGALRM "$$" 2>/dev/null; done; do sleep 5; done
) &
(
    trap "" SIGALRM
    until pactl subscribe 2>/dev/null | grep --line-buffered "sink" | while read -r _; do kill -SIGALRM "$$" 2>/dev/null; done; do sleep 5; done
) &

# --- Main Event Loop ---
log "INFO" "Idle Manager v3.6 (God-Tier) Started"
notify-send -t 2000 -h string:x-canonical-private-synchronous:idlemgr " Idle Manager: Started"

# Initial check
check_and_act

while true; do
    if [[ "$NEEDS_CHECK" == "true" ]]; then
        NEEDS_CHECK=false
        check_and_act
        continue
    fi

    sleep 10 &
    SLEEP_PID=$!
    wait "$SLEEP_PID" 2>/dev/null || true

    # Instantly kill the background sleep if `wait` was interrupted by a trap signal
    kill "$SLEEP_PID" 2>/dev/null || true

    NEEDS_CHECK=true
done
