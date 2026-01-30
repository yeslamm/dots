#!/bin/bash
# idle-off.sh - Gracefully stop all idle processes via systemd

systemctl --user stop sway-idle.service

# FORCE CLEANUP: Remove PID file immediately for instant UI feedback.
# (Systemd ExecStopPost handles swayidle, but we ensure state files are gone for UI)
rm -f /dev/shm/idle-mgr.pid /dev/shm/idle-mgr.state

# Signal Waybar to update immediately
pkill -SIGRTMIN+8 waybar

notify-send -t 1000 "Idle processes stopped"