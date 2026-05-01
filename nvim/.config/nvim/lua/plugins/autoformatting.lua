return { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
        {
            '<leader>F',
            function()
                require('conform').format { async = true }
            end,
            mode = '',
            desc = 'Format buffer',
        },
    },
    opts = {
        notify_on_error = true,
        format_on_save = {
            timeout_ms = 1000, -- Increased from 500ms
            lsp_fallback = true, -- If conform doesn't know the language, ask the LSP to do it
        },
        formatters = {
            shfmt = {
                args = { '-i', '4' },
            },
        },
        formatters_by_ft = {
            lua = { 'stylua' }, -- Keep single formatter, fallback handles LSP
            c = { 'clang-format' },
            cpp = { 'clang-format' },
            json = { 'prettier' },
            jsonc = { 'prettier' },
            python = { 'ruff_organize_imports', 'ruff_format' },
            sh = { 'shfmt' },
            bash = { 'shfmt' },
            cs = { 'csharpier' },
            toml = { 'taplo' },

            -- Add these lines:
            css = { 'prettier' },
            scss = { 'prettier' },
            less = { 'prettier' },
        },
    },
}
