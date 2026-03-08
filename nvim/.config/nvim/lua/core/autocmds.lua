-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = '*',
    callback = function()
        vim.opt_local.formatoptions:remove { 'r', 'o' }
    end,
})

-- Set conceallevel for specific filetypes
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'markdown', 'markdown_inline' },
    callback = function()
        vim.opt_local.conceallevel = 2
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'json',
    callback = function()
        vim.opt_local.conceallevel = 0
    end,
})

-- Restore cursor to file position in previous editing session
vim.api.nvim_create_autocmd('BufReadPost', {
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            vim.cmd 'normal! g`"zz'
        end
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'markdown', 'txt' },
    callback = function(opts)
        -- writing experience
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
    end,
})
