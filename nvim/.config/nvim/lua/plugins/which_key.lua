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
            border = 'rounded',
            padding = { 1, 2 },
            title = true,
            title_pos = 'center',
        },
        layout = {
            align = 'center',
        },
        spec = {
            { '<leader>b', group = 'Buffers' },
            { '<leader>c', group = 'Code' },
            { '<leader>d', group = 'Debug' },
            { '<leader>f', group = 'Quickfix list' },
            { '<leader>g', group = 'Git', mode = { 'n', 'v' } },
            { '<leader>gt', group = 'Toggles' },
            { '<leader>s', group = 'Search' },
            { '<leader>x', group = 'Trouble' },
            { '<leader>t', group = 'Tools' },
            { '<leader>w', group = 'Workspace' },
            { '<leader><tab>', group = 'Tabs' },
            -- Individual Mappings
            { '<leader>e', desc = 'Explorer' },
            { '<leader>n', desc = 'Toggle Auto-save' },
            { '<leader>q', desc = 'Close Buffer' },
            { '<leader>Q', desc = 'Quit All' },
        },
    },
}
