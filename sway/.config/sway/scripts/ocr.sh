#!/bin/bash
# ocr.sh - Select area, extract text, copy to clipboard.
# Dependencies: grim, slurp, tesseract, wl-copy, notify-send

# 1. Check Deps
for cmd in grim slurp tesseract wl-copy; do
    if ! command -v $cmd &> /dev/null; then
        notify-send "OCR Error" "Missing dependency: $cmd" -u critical
        exit 1
    fi
done

TEMP_IMG=$(mktemp /tmp/ocr_XXXX.png)

# 2. Select Area & Capture
# -d prevents taking a screenshot if selection is cancelled (slurp returns empty)
GEOM=$(slurp -d)
if [ -z "$GEOM" ]; then
    exit 0
fi

grim -g "$GEOM" "$TEMP_IMG"

# 3. Notify "Processing..." (It can take 1-2s)
notify-send "OCR" "Extracting text..." -t 1000 -h string:x-canonical-private-synchronous:ocr

# 4. Extract Text
# -l eng+ara (English + Arabic since you have ara layout)
# 2>/dev/null suppresses tesseract version info
TEXT=$(tesseract "$TEMP_IMG" stdout -l eng+ara 2>/dev/null)
rm "$TEMP_IMG"

# 5. Handle Result
# tr -d '\f' removes form feed characters tesseract outputs
CLEAN_TEXT=$(echo "$TEXT" | tr -d '\f' | sed '/^$/d')

if [ -z "$CLEAN_TEXT" ]; then
    notify-send "OCR" "No text detected." -u low -t 2000 -h string:x-canonical-private-synchronous:ocr
    exit 1
fi

# 6. Copy & Success Notification
echo -n "$CLEAN_TEXT" | wl-copy
notify-send "OCR" "Text copied to clipboard!" \
    -t 2000 \
    -h string:x-canonical-private-synchronous:ocr
