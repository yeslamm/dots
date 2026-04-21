#!/bin/bash
# sentry.sh - Infinite Auto-Suspend AFTER Wakeup

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# 1. Is Lock-NS active? Stand down.
[[ -f "$RUNTIME_DIR/lock-ns-active" ]] && exit 0

# 2. Is the screen actually locked? If not, abort entirely.
pgrep -x "swaylock" >/dev/null || exit 0

# 3. The 60-second Grace Period Loop
for ((i = 1; i <= 30; i++)); do
    # If the user unlocks the PC, swaylock dies. Abort Sentry.
    pgrep -x "swaylock" >/dev/null || exit 0
    sleep 2
done

# 4. If we survived 60 seconds and it's STILL locked, suspend!
if pgrep -x "swaylock" >/dev/null; then
    systemctl suspend

    # BASH MAGIC: The script freezes on the line above while asleep.
    # The exact millisecond the laptop wakes up, it moves to this line.
    # 'exec "$0"' tells the script to completely restart itself from the top!
    exec "$0"
fi
