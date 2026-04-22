#!/bin/bash
# sentry.sh - Infinite Auto-Suspend AFTER Wakeup

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# 1. Is Lock-NS active? Stand down.
[[ -f "$RUNTIME_DIR/IDLE_INHIBIT" ]] && exit 0

# 2. Is the screen actually locked? If not, abort entirely.
pgrep -x "swaylock" >/dev/null || exit 0

# 3. PRE-SUSPEND ASSASSINATION (The v2.2 Trick)
# Nuke the idle engine BEFORE sleep. No ghost timers will survive in RAM.
killall swayidle 2>/dev/null

# 4. Suspend the system!
systemctl suspend

# ==========================================
# --- BASH MAGIC: SYSTEM WAKES UP HERE ---
# ==========================================

# 5. Turn the display panel back on
swaymsg "output * power on"

# 6. INSTANT BRIGHTNESS RESTORE
# The screen is now at 100% brightness while you stare at the lock screen
brightnessctl -q -r

# 7. The Grace Period Loop (60 seconds)
# Swayidle is already dead, so you have a perfectly peaceful window to unlock.
for ((i = 1; i <= 120; i++)); do
    if ! pgrep -x "swaylock" >/dev/null; then
        # The exact millisecond you unlock, restart the idle engine
        ~/.config/sway/scripts/start_idle.sh &
        exit 0
    fi
    sleep 0.5
done

# 8. If 60 seconds passed and you STILL haven't unlocked it, restart Sentry to suspend again
exec "$0"
