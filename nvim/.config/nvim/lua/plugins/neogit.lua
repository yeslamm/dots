return {
    'NeogitOrg/neogit',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'sindrets/diffview.nvim',
    },
    opts = {},
    keys = {
        { '<leader>tn', '<cmd>Neogit<CR>', desc = 'Open [T]ools [N]eogit' },
    },
}

