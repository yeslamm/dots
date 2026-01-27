#!/bin/bash

# --- 1. Get Focused Window Details ---
# We remove specific type checks to ensure we catch floating/xwayland windows
FOCUS_JSON=$(swaymsg -t get_tree | jq '.. | select(.focused? == true)')

if [ -z "$FOCUS_JSON" ]; then
    notify-send "Kill Focused" "Error: Sway reports no window is focused." -u low
    exit 1
fi

# --- 2. Strategy A: Native Wayland PID ---
# Best case scenario: Sway knows the PID directly.
PID=$(echo "$FOCUS_JSON" | jq -r '.pid // empty')

# --- 3. Strategy B: XWayland PID (via xprop) ---
# If PID is null, it's likely an XWayland app. Use the X11 Window ID to ask Xorg.
if [ -z "$PID" ]; then
    XID=$(echo "$FOCUS_JSON" | jq -r '.window // empty')

    # Check if we have an XID and if xprop is installed
    if [ -n "$XID" ] && [ "$XID" != "null" ] && command -v xprop &>/dev/null; then
        PID=$(xprop -id "$XID" _NET_WM_PID 2>/dev/null | awk '{print $3}')
    fi
fi

# --- 4. Strategy C: Smart Class Search (The Nuclear Option) ---
# If we STILL have no PID, guess the process based on the window class name.
if [ -z "$PID" ]; then
    # Get the class or app_id (e.g., "com-abdownloadmanager-desktop-AppKt")
    CLASS=$(echo "$FOCUS_JSON" | jq -r '.window_properties.class // .app_id // empty')

    if [ -n "$CLASS" ]; then
        # Replace dots/dashes with spaces to split into words
        CLEAN_CLASS=$(echo "$CLASS" | tr '-.' ' ')

        for word in $CLEAN_CLASS; do
            # 1. Skip generic system words to prevent accidents
            if [[ "$word" =~ ^(com|org|net|io|desktop|app|application|client|wrapper|java|kotlin|kt)$ ]]; then continue; fi
            # 2. Skip short words
            if [ ${#word} -lt 4 ]; then continue; fi

            # 3. Find newest process matching word, restricted to CURRENT USER
            # grep -v "^$$" ensures we don't kill this script itself
            FOUND_PID=$(pgrep -u "$USER" -n -f "$word" | grep -v "^$$$")

            if [ -n "$FOUND_PID" ]; then
                PID=$FOUND_PID
                notify-send "Kill Focused" "Target acquired via class name: '$word' ($PID)" -u low
                break
            fi
        done
    fi
fi

# --- 5. Execution Logic ---

# If absolutely no PID was found, use Sway's internal kill command
if [ -z "$PID" ]; then
    notify-send "Kill Focused" "No PID found. Sending Sway kill signal." -u low
    swaymsg kill
    exit 0
fi

# Step 1: The Polite Knock (SIGTERM)
kill -15 "$PID"

# Step 2: The Countdown (Wait 1 second)
for _ in {1..10}; do
    if ! kill -0 "$PID" 2>/dev/null; then
        # Process is gone, exit successfully
        exit 0
    fi
    sleep 0.1
done

# Step 3: The Double Tap (SIGKILL)
kill -9 "$PID"
notify-send -t 2000 "Kill Focused" "Process $PID frozen. Force killed." -u critical
