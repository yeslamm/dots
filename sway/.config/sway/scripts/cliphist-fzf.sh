#!/usr/bin/env bash

DB_PATH="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/cliphist.db"
CH_CMD="cliphist -db-path $DB_PATH"

case "$1" in
preview)
    row="$2"
    if echo "$row" | grep -vqP '^\d+\t\[\[ binary data .* \]\]'; then
        echo "$row" | $CH_CMD decode
    else
        echo "$row" | $CH_CMD decode | chafa -f sixel -s "${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}"
    fi
    ;;

*)
    id="$($CH_CMD -preview-width 1000 list | fzf \
        --delimiter '\t' \
        --with-nth 2.. \
        --preview-window=right:55%,wrap \
        --bind "ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up" \
        --preview "$(realpath "$0") preview {}")"

    test -z "$id" && exit

    $CH_CMD decode <<<"$id" | wl-copy
    ;;

esac
