#!/bin/bash
# replay.sh - "Elite Replay Buffer Edition"
# Standardized paths, robust PID management, and hardened logic.

set -euo pipefail

# --- Configuration ---
REPLAY_DURATION=60
VIDEO_DIR="$HOME/Videos/Replays"
RECORD_DIR="$HOME/Videos/Recordings"
WINDOW="screen"
FPS=60
CONTAINER="mp4"
AUDIO_DEVICE="default_output"

# Standardized Paths
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
PID_FILE="$RUNTIME_DIR/gsr-replay.pid"
REC_PID_FILE="$RUNTIME_DIR/gsr-record.pid"

mkdir -p "$VIDEO_DIR" "$RECORD_DIR"

log_notify() {
    local title="$1" msg="$2" tag="${3:-replay}"
    notify-send "$title" "$msg" -t 2000 -h "string:x-canonical-private-synchronous:$tag"
}

is_alive() {
    local pf="$1"
    [[ -f "$pf" ]] && kill -0 "$(cat "$pf")" 2>/dev/null
}

case "${1:-}" in
    start)
        if is_alive "$PID_FILE"; then
            log_notify "Replay" "Buffer is already running."
            exit 0
        fi

        gpu-screen-recorder \
            -w "$WINDOW" -f "$FPS" -a "$AUDIO_DEVICE" \
            -r "$REPLAY_DURATION" -c "$CONTAINER" -o "$VIDEO_DIR" &
        
        echo $! > "$PID_FILE"
        log_notify "Replay" "Buffer started. Ready to save."
        ;;

    record)
        if is_alive "$REC_PID_FILE"; then
            local pid=$(cat "$REC_PID_FILE")
            kill -SIGINT "$pid" 2>/dev/null
            rm -f "$REC_PID_FILE"
            log_notify "Recording" "Stopped and saved to $RECORD_DIR" "record"
        else
            local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
            local filename="$RECORD_DIR/recording_$timestamp.$CONTAINER"
            gpu-screen-recorder \
                -w "$WINDOW" -f "$FPS" -a "$AUDIO_DEVICE" \
                -c "$CONTAINER" -o "$filename" &
            echo $! > "$REC_PID_FILE"
            log_notify "Recording" "Started recording..." "record"
        fi
        ;;

    toggle)
        if is_alive "$PID_FILE"; then
            "$0" stop
        else
            rm -f "$PID_FILE"
            "$0" start
        fi
        ;;

    save)
        if is_alive "$PID_FILE"; then
            kill -SIGUSR1 "$(cat "$PID_FILE")"
            log_notify "Replay" "Saved last ${REPLAY_DURATION}s!"
        else
            log_notify "Replay Error" "Replay buffer is NOT running."
            rm -f "$PID_FILE"
        fi
        ;;

    stop)
        if is_alive "$PID_FILE"; then
            kill -SIGINT "$(cat "$PID_FILE")" 2>/dev/null
            rm -f "$PID_FILE"
            log_notify "Replay" "Buffer stopped."
        else
            pkill -SIGINT -f "gpu-screen-recorder.*-r $REPLAY_DURATION" || true
            log_notify "Replay" "Not running."
        fi
        ;;

    *)
        echo "Usage: $0 start|save|stop|record|toggle"; exit 1
        ;;
esac
