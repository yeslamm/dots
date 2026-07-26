return {
    'EdenEast/nightfox.nvim',
    lazy = false,
    priority = 1000,
    config = function()
        require('nightfox').setup {
            options = {
                transparent = false,
                terminal_colors = true,
            },
            groups = {
                all = {
                    WinSeparator = { fg = '#363636' },
                    VertSplit = { fg = '#363636' },
                },
            },
        }
        vim.cmd 'colorscheme carbonfox'
    end,
}
