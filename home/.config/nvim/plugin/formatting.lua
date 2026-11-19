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
        json = { 'prettierd' },
        jsonc = { 'prettierd' },
        python = { 'ruff_organize_imports', 'ruff_format' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        toml = { 'taplo' },
        tex = { 'tex-fmt' },
        css = { 'prettierd' },
        scss = { 'prettierd' },
        less = { 'prettierd' },
    },
}

vim.keymap.set({ 'n', 'v' }, '<leader>F', function()
    conform.format { async = true, lsp_format = 'fallback' }
end, { desc = 'Format buffer' })

local lint = require 'lint'

lint.linters_by_ft = {
    sh = { 'shellcheck' },
    bash = { 'shellcheck' },
}

local lint_augroup = vim.api.nvim_create_augroup('LintingConfig', { clear = true })
vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost' }, {
    group = lint_augroup,
    callback = function(args)
        if vim.bo[args.buf].modifiable then
            lint.try_lint()
        end
    end,
})
