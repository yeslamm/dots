vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'markdown', 'md' },
    once = true,
    callback = function()
        require('render-markdown').setup {
            completions = {
                lsp = { enabled = true },
            },
            heading = {
                width = 'block',
            },
            code = {
                width = 'block',
                left_pad = 2,
                right_pad = 2,
                border = 'thick',
            },
            anti_conceal = {
                enabled = true,
            },
        }
    end,
})
