#!/usr/bin/env bash

case "$1" in
preview)
    row="$2"
    if echo "$row" | grep -vqP '^\d+\t\[\[ binary data .* \]\]'; then
        echo "$row" | cliphist decode
    else
        echo "$row" | cliphist decode | chafa -f sixel -s "${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}"
    fi
    ;;

*)
    id="$(cliphist -preview-width 1000 list | fzf \
        --delimiter '\t' \
        --with-nth 2.. \
        --preview-window=down:50%,wrap \
        --bind "ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up" \
        --preview "$(realpath "$0") preview {}")"

    test -z "$id" && exit

    cliphist decode <<<"$id" | wl-copy
    ;;

esac
