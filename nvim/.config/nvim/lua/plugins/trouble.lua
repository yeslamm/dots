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
            '<leader>td',
            '<cmd>Trouble diagnostics toggle<cr>',
            desc = 'Diagnostics (Trouble)',
        },
        {
            '<leader>tD',
            '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
            desc = 'Buffer Diagnostics (Trouble)',
        },
        {
            '<leader>tq',
            '<cmd>Trouble qflist toggle<cr>',
            desc = 'Quickfix List (Trouble)',
        },
        {
            '<leader>tl',
            '<cmd>Trouble loclist toggle<cr>',
            desc = 'Location List (Trouble)',
        },
        {
            '<leader>tr',
            '<cmd>Trouble lsp_references toggle<cr>',
            desc = 'LSP References (Trouble)',
        },
        {
            '<leader>tM', -- M for Meanings/Types
            '<cmd>Trouble lsp_type_definitions toggle<cr>',
            desc = 'LSP Type Definitions (Trouble)',
        },
        {
            '<leader>tI', -- I for Implementations
            '<cmd>Trouble lsp_implementations toggle<cr>',
            desc = 'LSP Implementations (Trouble)',
        },
        {
            '<leader>tR', -- R for Definitions/Declarations
            '<cmd>Trouble lsp_definitions toggle<cr>',
            desc = 'LSP Definitions (Trouble)',
        },
    },
}
