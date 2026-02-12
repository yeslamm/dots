return {
    'NeogitOrg/neogit',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'sindrets/diffview.nvim',
    },
    opts = {},
    keys = {
        { '<leader>Tn', '<cmd>Neogit<CR>', desc = 'Neogit' },
    },
}
