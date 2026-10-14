local conform = require 'conform'

conform.setup {
    format_on_save = {
        timeout_ms = 500,
        lsp_format = 'fallback',
    },
    formatters = {
        shfmt = {
            prepend_args = { '-i', '4' },
        },
        ['tex-fmt'] = {
            prepend_args = { '--nowrap' },
        },
    },
    formatters_by_ft = {
        lua = { 'stylua' },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        json = { 'prettier' },
        jsonc = { 'prettier' },
        python = { 'ruff_organize_imports', 'ruff_format' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        toml = { 'taplo' },
        tex = { 'tex-fmt' },
        css = { 'prettier' },
        scss = { 'prettier' },
        less = { 'prettier' },
    },
}

vim.keymap.set({ 'n', 'v' }, '<leader>F', function()
    conform.format { async = true, lsp_format = 'fallback' }
end, { desc = 'Format buffer' })
