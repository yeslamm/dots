#!/bin/bash
# ==============================================================================
# REPLAY.SH - INSTANT REPLAY (SHADOWPLAY) FOR LINUX
# ==============================================================================
# Purpose: Manages a GPU-accelerated replay buffer using gpu-screen-recorder.
#
# Configured Keybindings in Sway:
#   - Ctrl + Super + R        : SAVE last 60 seconds of video
#   - Ctrl + Super + Shift + R : TOGGLE (Start/Stop) the replay buffer
#
# Usage:
#   ./replay.sh start   - Start the recording buffer (uses ~300MB RAM)
#   ./replay.sh stop    - Stop the buffer and free RAM
#   ./replay.sh toggle  - Smart switch between start and stop
#   ./replay.sh save    - Save the current buffer to ~/Videos/Replays
#   ./replay.sh record  - Toggle standard recording (Start/Stop)
# ==============================================================================

# --- Config ---
REPLAY_DURATION=60  # Seconds to save
VIDEO_DIR="$HOME/Videos/Replays"
RECORD_DIR="$HOME/Videos/Recordings"
WINDOW="screen"     # Record full screen
FPS=60
CONTAINER="mp4"
AUDIO_DEVICE="default_output" # Records system sound. Use "default_input" for mic.

# PID Files
PID_FILE="/dev/shm/gsr-replay.pid"
REC_PID_FILE="/dev/shm/gsr-record.pid"

mkdir -p "$VIDEO_DIR" "$RECORD_DIR"

case "$1" in
"start")
    if pgrep -f "gpu-screen-recorder.*-r $REPLAY_DURATION" >/dev/null; then
        notify-send "Replay" "Replay buffer is already running." -u low
        exit 0
    fi

    # Start recording to RAM (Replay Mode)
    gpu-screen-recorder \
        -w "$WINDOW" \
        -f "$FPS" \
        -a "$AUDIO_DEVICE" \
        -r "$REPLAY_DURATION" \
        -c "$CONTAINER" \
        -o "$VIDEO_DIR" &
    
    GSR_PID=$!
    echo $GSR_PID > "$PID_FILE"
    
    # Ensure PID file is removed if the process dies immediately
    (
        sleep 1
        if ! kill -0 $GSR_PID 2>/dev/null; then
            rm -f "$PID_FILE"
        fi
    ) &

    notify-send "Replay" "Buffer started. Ready to save." -t 2000 -h string:x-canonical-private-synchronous:replay
    ;;

"record")
    if [ -f "$REC_PID_FILE" ]; then
        PID=$(cat "$REC_PID_FILE")
        kill -SIGINT "$PID" 2>/dev/null
        rm -f "$REC_PID_FILE"
        notify-send "Recording" "Stopped and saved to $RECORD_DIR" -t 3000 -h string:x-canonical-private-synchronous:record
    else
        TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
        FILENAME="$RECORD_DIR/recording_$TIMESTAMP.$CONTAINER"
        gpu-screen-recorder \
            -w "$WINDOW" \
            -f "$FPS" \
            -a "$AUDIO_DEVICE" \
            -c "$CONTAINER" \
            -o "$FILENAME" &
        echo $! > "$REC_PID_FILE"
        notify-send "Recording" "Started recording..." -t 2000 -h string:x-canonical-private-synchronous:record
    fi
    ;;

"toggle")
    # Strict toggle based on PID file existence
    if [ -f "$PID_FILE" ]; then
        # Check if the process inside is actually alive
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
             $0 stop
        else
             # Stale PID file? Clean it and start fresh.
             rm -f "$PID_FILE"
             $0 start
        fi
    else
        $0 start
    fi
    ;;

"save")
    # Send Signal SIGUSR1 to gpu-screen-recorder to save the buffer
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            kill -SIGUSR1 "$PID"
            notify-send "Replay" "Saved last ${REPLAY_DURATION}s!" \
                -t 2000 \
                -h string:x-canonical-private-synchronous:replay
        else
            notify-send "Replay Error" "Process died unexpectedly." -u critical
            rm -f "$PID_FILE"
        fi
    else
        # Fallback: Try pkill without -x if PID file missing
        if pkill -SIGUSR1 -f "gpu-screen-recorder"; then
             notify-send "Replay" "Saved (Fallback Method)!" -t 2000
        else
             notify-send "Replay Error" "Replay buffer is NOT running." -u critical
        fi
    fi
    ;;

"stop")
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        kill -SIGINT "$PID" 2>/dev/null
        rm -f "$PID_FILE"
        notify-send "Replay" "Buffer stopped." -t 2000
    elif pkill -SIGINT -f "gpu-screen-recorder"; then
        notify-send "Replay" "Buffer stopped (Fallback)." -t 2000
    else
        notify-send "Replay" "Not running." -u low
    fi
    ;;

*)
    echo "Usage: $0 start|save|stop"
    exit 1
    ;;
esac
