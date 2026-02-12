return {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        -- Default options. Refer to the configuration section in the README for custom setup.
        -- Example: auto_open = true, auto_close = true,
    },
    cmd = 'Trouble',
    keys = {
        {
            '<leader>tt',
            '<cmd>Trouble diagnostics toggle<cr>',
            desc = 'Diagnostics',
        },
        {
            '<leader>tX',
            '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
            desc = 'Buffer Diagnostics',
        },
        {
            '<leader>tq',
            '<cmd>Trouble qflist toggle<cr>',
            desc = 'Quickfix List',
        },
        {
            '<leader>tl',
            '<cmd>Trouble loclist toggle<cr>',
            desc = 'Location List',
        },
        {
            '<leader>tr',
            '<cmd>Trouble lsp_references toggle<cr>',
            desc = 'References',
        },
        {
            '<leader>tu',
            '<cmd>Trouble lsp_type_definitions toggle<cr>',
            desc = 'Type Definitions',
        },
        {
            '<leader>ti',
            '<cmd>Trouble lsp_implementations toggle<cr>',
            desc = 'Implementations',
        },
        {
            '<leader>td',
            '<cmd>Trouble lsp_definitions toggle<cr>',
            desc = 'Definitions',
        },
    },
}
