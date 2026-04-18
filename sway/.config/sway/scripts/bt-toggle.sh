#!/bin/bash

# Check the current state
if rfkill list bluetooth | grep -q "Soft blocked: yes"; then
    # Fire the notification instantly, THEN change the state
    notify-send -t 1500 -h string:x-canonical-private-synchronous:bluetooth "Bluetooth Enabled"
    rfkill unblock bluetooth
else
    # Fire the notification instantly, THEN change the state
    notify-send -t 1500 -h string:x-canonical-private-synchronous:bluetooth "Bluetooth Disabled"
    rfkill block bluetooth
fi
