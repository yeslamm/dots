#!/bin/sh
# ~/dots/sway/.config/sway/scripts/media.sh

playerctl play-pause && sleep 0.08

STATUS=$(playerctl status 2>/dev/null) || exit 0

METADATA=$(playerctl metadata --format "{{markup_escape(artist)}} - {{markup_escape(title)}}" 2>/dev/null)

if [ -z "$METADATA" ]; then
    METADATA="Unknown Track"
fi

TITLE="Paused"
[ "$STATUS" = "Playing" ] && TITLE="Now Playing"

notify-send "$TITLE" "$METADATA" -t 1500 -h string:x-canonical-private-synchronous:media
