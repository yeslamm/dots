#!/bin/bash
# ocr.sh - "Elite OCR Edition"
# Select area, pre-process for accuracy, and extract text.

set -euo pipefail

# 1. Dependency Check
for cmd in grim slurp tesseract wl-copy magick; do
    if ! command -v "$cmd" &>/dev/null; then
        notify-send "OCR Error" "Missing dependency: $cmd" -u critical
        exit 1
    fi
done

# 2. Cleanup on Exit
TEMP_IMG=$(mktemp "${XDG_RUNTIME_DIR:-/tmp}/ocr_XXXX.png")
trap 'rm -f "$TEMP_IMG"' EXIT

# 3. Select Area & Capture
GEOM=$(slurp -d 2>/dev/null) || exit 0

# Capture and pre-process (Sharpen + Grayscale + Contrast) for better OCR
grim -g "$GEOM" - | magick - \
    -colorspace gray \
    -sharpen 0x3 \
    -contrast-stretch 5%x5% \
    -scale 400% \
    "$TEMP_IMG"

# 4. Notify Processing
notify-send "OCR" "Extracting text..." -t 800 -h string:x-canonical-private-synchronous:ocr

# 5. Extract & Clean Text
# -l eng+ara for English + Arabic support
TEXT=$(tesseract "$TEMP_IMG" stdout -l eng+ara 2>/dev/null || echo "")

# Clean: Remove form feeds, strip trailing/leading space, remove empty lines
# Using perl or more robust sed for multi-line cleanup if needed, but keeping it bash-friendly.
CLEAN_TEXT=$(echo "$TEXT" | tr -d '\f' | sed '/^[[:space:]]*$/d; s/^[[:space:]]*//; s/[[:space:]]*$//' | paste -sd " " - || true)

if [[ -z "$CLEAN_TEXT" ]]; then
    notify-send "OCR" "No text detected." -u low -t 2000 -h string:x-canonical-private-synchronous:ocr
    exit 0
fi

# 6. Finalize
echo -n "$CLEAN_TEXT" | wl-copy
notify-send "OCR" "Text copied to clipboard!" \
    -t 2000 \
    -h string:x-canonical-private-synchronous:ocr
