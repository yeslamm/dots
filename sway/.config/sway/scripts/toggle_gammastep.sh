#!/bin/bash
if pgrep gammastep >/dev/null; then
  pkill gammastep
else
  gammastep -l 31.11167:30.94583
fi
