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
            { '<leader>x', group = '[X] Trouble' },
            { '<leader>g', group = '[G]it', mode = { 'n', 'v' } },
            { '<leader>gt', group = '[T]oggles' },
            { '<leader>t', group = '[T]ools' },
            { '<leader>d', group = '[D]ebug' },
            { '<leader>b', group = '[B]uffer' },
            { '<leader>Q', desc = 'Quit Neovim' },
            { '<leader>L', desc = 'Lazy' },
            { '<leader>M', desc = 'Mason' },
            { '<leader>f', desc = 'Quickfix list' },
            { '<leader>q', desc = 'Close Buffer' },
            { '<leader>e', desc = 'Explorer' },
        },
    },
}
