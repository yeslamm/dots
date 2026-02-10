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
            '<leader>xx',
            '<cmd>Trouble diagnostics toggle<cr>',
            desc = 'Diagnostics (Trouble)',
        },
        {
            '<leader>xX',
            '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
            desc = 'Buffer Diagnostics (Trouble)',
        },
        {
            '<leader>xq',
            '<cmd>Trouble qflist toggle<cr>',
            desc = 'Quickfix List (Trouble)',
        },
        {
            '<leader>xl',
            '<cmd>Trouble loclist toggle<cr>',
            desc = 'Location List (Trouble)',
        },
        {
            '<leader>xr',
            '<cmd>Trouble lsp_references toggle<cr>',
            desc = 'LSP References (Trouble)',
        },
        {
            '<leader>xt',
            '<cmd>Trouble lsp_type_definitions toggle<cr>',
            desc = 'LSP Type Definitions (Trouble)',
        },
        {
            '<leader>xi',
            '<cmd>Trouble lsp_implementations toggle<cr>',
            desc = 'LSP Implementations (Trouble)',
        },
        {
            '<leader>xd',
            '<cmd>Trouble lsp_definitions toggle<cr>',
            desc = 'LSP Definitions (Trouble)',
        },
    },
}
