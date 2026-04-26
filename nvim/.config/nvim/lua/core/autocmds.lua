local augroup = vim.api.nvim_create_augroup('UserConfig', { clear = true })

-- Highlight yanked text (Visual feedback when you copy something)
vim.api.nvim_create_autocmd('TextYankPost', {
    group = augroup,
    callback = function()
        vim.highlight.on_yank { higroup = 'IncSearch', timeout = 250 }
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

-- Set 4‑space indents for all filetypes
vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.expandtab = true
    end,
    -- pattern = "*"
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'markdown', 'txt' },
    callback = function()
        -- writing experience
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
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

-- Stop newline continuation of comments
vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
    desc = "Don't automatically continue comments on newline",
    pattern = '*',
    callback = function()
        vim.opt_local.formatoptions:remove { 'c', 'r', 'o' }
    end,
})

-- 2. THE HIGHLIGHT CHAIN
vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    callback = function()
        -- Instead of clearing the background, forcefully link them to the main transparent window
        vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Normal' })
        vim.api.nvim_set_hl(0, 'FloatBorder', { link = 'Normal' })

        -- Chain the stubborn plugins
        vim.api.nvim_set_hl(0, 'LazyNormal', { link = 'Normal' })
        vim.api.nvim_set_hl(0, 'MasonNormal', { link = 'Normal' })
    end,
})
