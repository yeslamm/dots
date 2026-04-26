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
            mappings = false, -- Disable icons for mappings
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
            { '<leader>gt', group = 'Toggles' },
            { '<leader>s', group = 'Search' },
            { '<leader><tab>', group = 'Tabs' },
            -- Individual Mappings
            { '<leader>f', desc = 'Quickfix list' },
            { '<leader>q', desc = 'Close Buffer' },
            { '<leader>Q', desc = 'Quit All' },
        },
    },
}
