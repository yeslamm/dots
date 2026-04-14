" Tell Vim to accept blocks for 'for_window'
syntax region swayForWindowBlock start=/for_window\s*{/ end=/}/ transparent contains=ALL

" Suppress generic error highlighting for unknown bracket commands
highlight link swayConfigError NONE
highlight link i3ConfigError NONE
highlight link Error NONE

" Force comments to render properly inside ALL blocks
syntax match swayCustomComment /^\s*#.*$/ containedin=ALL display
highlight link swayCustomComment Comment
