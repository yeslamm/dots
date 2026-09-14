local augroup = vim.api.nvim_create_augroup('UserConfig', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    group = augroup,
    desc = 'Highlight yanked text',
    callback = function()
        vim.hl.on_yank { higroup = 'IncSearch', timeout = 250 }
    end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
    group = augroup,
    desc = 'Return to last edit position',
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            vim.cmd 'normal! g`"zz'
        end
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = { 'text', 'markdown', 'markdown_inline', 'help', 'json', 'jsonc' },
    callback = function(args)
        vim.opt_local.expandtab = true
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.softtabstop = 2

        if vim.tbl_contains({ 'text', 'markdown', 'markdown_inline', 'help' }, args.match) then
            vim.opt_local.conceallevel = 2
            vim.opt_local.wrap = true
        end
    end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
    group = augroup,
    desc = "Don't automatically continue comments on newline",
    pattern = '*',
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
    pattern = {
        'help',
        'qf',
        'man',
        'lspinfo',
        'checkhealth',
        'mason',
        'notify',
        'gitsigns-blame',
    },
    callback = function()
        vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = true, silent = true })
    end,
})

vim.api.nvim_create_autocmd('PackChanged', {
    group = augroup,
    desc = 'Run post-install and update build hooks',
    callback = function(ev)
        if ev.data.spec.name == 'nvim-treesitter' and (ev.data.kind == 'install' or ev.data.kind == 'update') then
            vim.schedule(function()
                vim.cmd 'packadd nvim-treesitter'
                if vim.fn.exists ':TSUpdate' == 2 then
                    vim.cmd 'TSUpdate'
                end
            end)
        end
    end,
})
