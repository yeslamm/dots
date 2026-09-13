local conform = require 'conform'

conform.setup {
    notify_on_error = true,
    format_on_save = {
        timeout_ms = 500,
        lsp_format = 'fallback',
    },
    formatters = {
        shfmt = {
            args = { '-i', '4' },
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
        cs = { 'csharpier' },
        toml = { 'taplo' },
        css = { 'prettier' },
        scss = { 'prettier' },
        less = { 'prettier' },
    },
}

vim.keymap.set({ 'n', 'v' }, '<leader>F', function()
    conform.format { async = true }
end, { desc = 'Format buffer' })
