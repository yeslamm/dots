return {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    opts = {},
    keys = {
        {
            '<leader>xd',
            '<cmd>Trouble diagnostics toggle<cr>',
            desc = 'Project Diagnostics',
        },
        {
            '<leader>xD',
            '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
            desc = 'Buffer Diagnostics',
        },
        {
            '<leader>xs',
            '<cmd>Trouble symbols toggle focus=false<cr>',
            desc = 'Symbols Tree',
        },
        {
            '<leader>xl',
            '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
            desc = 'LSP Locations',
        },
        {
            '<leader>xq',
            '<cmd>Trouble qflist toggle<cr>',
            desc = 'Quickfix List',
        },
    },
}
