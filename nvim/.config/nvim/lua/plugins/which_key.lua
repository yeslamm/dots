return {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
        preset = 'classic',
        delay = 0,
        icons = { mappings = false },
        win = { border = 'none' },
        spec = {
            { '<leader>g', group = 'Git', mode = { 'n', 'v' } },
            { '<leader>s', group = 'Search' },
            { '<leader>t', group = 'Tabs' },
            { '<leader>D', group = 'Debug' },
            { '<leader>v', group = 'Vault' },
            { '<leader>x', group = 'Trouble' },

            { '<leader>q', desc = 'Quit Buffer' },
            { '<leader>Q', desc = 'Quit All' },
        },
    },
}
