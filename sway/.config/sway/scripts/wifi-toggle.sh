#!/bin/bash
STATE=$(nmcli -t -f WIFI radio)
if [ "$STATE" = "enabled" ]; then
    nmcli radio wifi off
    notify-send -t 1500 -h string:x-canonical-private-synchronous:wifi "WiFi Disabled"
else
    nmcli radio wifi on
    notify-send -t 1500 -h string:x-canonical-private-synchronous:wifi "WiFi Enabled"
fi
