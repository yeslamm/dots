#!/usr/bin/env bash
# ~/dots/sway/.config/sway/scripts/init-audio.sh

set -euo pipefail

wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.30 || true

wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 0.40 || true

amixer -c 1 set "Internal Mic Boost" 0 || true
