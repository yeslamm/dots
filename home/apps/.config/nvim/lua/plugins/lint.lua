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
