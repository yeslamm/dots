#!/bin/bash

# Define processes that should NEVER show up in the kill menu
PROTECTED="sway|waybar|pipewire|wireplumber|dbus|systemd|fuzzel|bash|ssh|polkit"

# 1. Get user processes (quoted "$USER" to fix SC2086)
# 2. Filter OUT protected processes using awk (fixes SC2009)
# 3. Sort and remove duplicates
# 4. Pipe to Fuzzel
SELECTED_APP=$(ps -u "$USER" -o comm= | awk -v pat="^(${PROTECTED})$" '$0 !~ pat' | sort -u | fuzzel --dmenu --prompt="KILL: ")

if [ -n "$SELECTED_APP" ]; then
    # Use SIGTERM (-15) to allow graceful exit (saving state, closing files)
    pkill -15 -x "$SELECTED_APP"
    notify-send -t 2000 "Process Termination Sent" "Requesting exit for: $SELECTED_APP"
fi
