require('nightfox').setup {
    options = {
        transparent = false,
        terminal_colors = true,
    },
    groups = {
        all = {
            WinSeparator = { fg = '#363636' },
            VertSplit = { fg = '#363636' },
            QuickFixLine = { bg = 'NONE', style = 'bold' },
        },
    },
}

vim.cmd.colorscheme 'carbonfox'
