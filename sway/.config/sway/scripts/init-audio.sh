#!/bin/sh
# ~/dots/sway/.config/sway/scripts/init-audio.sh

set -e

wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.30 2>/dev/null || true
wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 0.40 2>/dev/null || true
amixer -c Generic_1 set "Internal Mic Boost" 0 2>/dev/null || true
