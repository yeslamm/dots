#!/bin/bash
# fuzzel-kill.sh - "Elite Grouped Task Manager" v2.5 (No Confirmation)
# Groups child processes, normalizes CPU, and prioritizes Memory view.

set -euo pipefail

# 1. Get total core count for normalization
CORES=$(nproc)

# Define processes that should NEVER show up in the kill menu
PROTECTED="sway|waybar|pipewire|wireplumber|dbus|systemd|fuzzel|bash|ssh|polkit|idle-mgr.sh|grep|ps|awk|sort"

# 2. Generate Grouped Process List
# Memory is now shown before CPU. Sorted by Memory usage (Field 6)
PROCESS_LIST=$(ps -u "$USER" -o pcpu,pmem,comm --no-headers | awk -v pat="^(${PROTECTED})$" -v cores="$CORES" \
    '$3 !~ pat { 
        cpu[$3]+=$1; 
        mem[$3]+=$2; 
        count[$3]++ 
    } 
    END { 
        for (name in cpu) 
            printf "%-20s | %2d procs | %5.1f%% MEM | %5.1f%% CPU\n", name, count[name], mem[name], cpu[name]/cores 
    }' | sort -hr -k 6)

# 3. Select Application
SELECTED=$(echo "$PROCESS_LIST" | fuzzel --dmenu --prompt="KILL: " -w 58 -l 15)

if [[ -n "$SELECTED" ]]; then
    # Robust extraction of name and count
    APP_NAME=$(echo "$SELECTED" | cut -d'|' -f1 | xargs)
    COUNT=$(echo "$SELECTED" | cut -d'|' -f2 | awk '{print $1}')

    # 4. Immediate Action (No Confirmation)
    # Try SIGTERM first for a clean exit
    pkill -15 -x "$APP_NAME" 2>/dev/null || true
    notify-send -t 2000 -h string:x-canonical-private-synchronous:kill "Termination signal sent to $APP_NAME ($COUNT processes)"
fi
