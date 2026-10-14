local augroup = vim.api.nvim_create_augroup('UserConfig', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    group = augroup,
    callback = function()
        vim.hl.on_yank { higroup = 'IncSearch', timeout = 250 }
    end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
    group = augroup,
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if ft:find 'commit' or ft:find 'rebase' then
            return
        end

        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
            vim.cmd 'normal! g`"zz'
        end
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = { 'json', 'jsonc', 'markdown', 'tex', 'text' },
    callback = function(args)
        vim.opt_local.expandtab = true
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2

        if args.match == 'markdown' or args.match == 'tex' or args.match == 'text' then
            vim.opt_local.wrap = true
        end
        if args.match == 'markdown' then
            vim.opt_local.conceallevel = 2
        end
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    callback = function()
        vim.opt_local.formatoptions:remove { 'c', 'r', 'o' }
    end,
})

vim.api.nvim_create_autocmd('VimResized', {
    group = augroup,
    command = 'wincmd =',
})

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
    group = augroup,
    callback = function()
        if vim.api.nvim_win_get_config(0).relative == '' then
            vim.opt_local.cursorline = true
        end
    end,
})

vim.api.nvim_create_autocmd('WinLeave', {
    group = augroup,
    callback = function()
        vim.opt_local.cursorline = false
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = { 'help', 'qf', 'man', 'lspinfo', 'checkhealth', 'mason', 'notify', 'gitsigns-blame' },
    callback = function(args)
        vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = args.buf, silent = true })
    end,
})
