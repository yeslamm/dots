#!/bin/bash
# idle-off.sh - Gracefully stop all idle processes

# Send TERM signal to the manager, allowing it to clean up.
pkill -f "idle-mgr.sh"

# FORCE CLEANUP: Remove PID file immediately for instant UI feedback.
rm -f /dev/shm/idle-mgr.pid /dev/shm/idle-mgr.state

# Also send TERM signal to the swayidle process itself.
pkill -x swayidle

# The manager's cleanup should handle its PID file, but we run this
# as a fallback in case only swayidle was running without the manager.
rm -f /dev/shm/swayidle.pid

# Signal Waybar to update immediately
pkill -SIGRTMIN+8 waybar

notify-send -t 1000 "Idle processes stopped"