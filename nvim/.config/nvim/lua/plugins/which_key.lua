return {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
        preset = 'helix',
        delay = 0,
        icons = {
            breadcrumb = '»',
            separator = '➜',
            group = '+',
            mappings = false,
        },
        win = {
            border = 'single',
            padding = { 1, 2 },
            title = true,
            title_pos = 'center',
        },
        layout = {
            align = 'center',
        },
        spec = {
            { '<leader>g', group = 'Git', mode = { 'n', 'v' } },
            { '<leader>s', group = 'Search' },
            { '<leader>n', group = 'Notifications' }, -- Register your new Noice group here
            { '<leader>t', group = 'Tabs' },
            { '<leader>d', group = 'Debug' },
            -- Individual Mappings
            { '<leader>f', desc = 'Quickfix list' },
            { '<leader>q', desc = 'Close Buffer' },
            { '<leader>Q', desc = 'Quit All' },
        },
    },
}
