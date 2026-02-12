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
            { '<leader>s', group = '[S]earch' },
            { '<leader>w', group = '[W]orkspace' },
            { '<leader>t', group = '[T]rouble' },
            { '<leader>g', group = '[G]it', mode = { 'n', 'v' } },
            { '<leader>gt', group = '[T]oggles' },
            { '<leader>T', group = '{T}ools' },
            { '<leader>d', group = '[D]ebug' },
            { '<leader>b', group = '[B]uffer' },
            { '<leader>Q', desc = 'Quit All' },
            { '<leader>f', desc = 'Quickfix List' },
            { '<leader>q', desc = 'Close Buffer' },
            { '<leader>e', desc = 'Explorer' },
        },
    },
}
