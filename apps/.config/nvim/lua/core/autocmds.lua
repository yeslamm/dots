local augroup = vim.api.nvim_create_augroup('UserConfig', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    group = augroup,
    callback = function()
        vim.hl.on_yank { higroup = 'IncSearch', timeout = 250 }
    end,
})

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
    pattern = { 'text', 'markdown', 'markdown_inline', 'help' },
    callback = function()
        vim.opt_local.conceallevel = 2
        vim.opt_local.wrap = true
        vim.opt_local.expandtab = true
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.softtabstop = 2
    end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
    desc = "Don't automatically continue comments on newline",
    pattern = '*',
    callback = function()
        vim.opt_local.formatoptions:remove { 'c', 'r', 'o' }
    end,
})

vim.api.nvim_create_autocmd('VimResized', {
    command = 'wincmd =',
})

local cursorline_group = vim.api.nvim_create_augroup('active_cursorline', { clear = true })

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
    group = cursorline_group,
    callback = function()
        vim.opt_local.cursorline = true
    end,
})

vim.api.nvim_create_autocmd({ 'WinLeave' }, {
    group = cursorline_group,
    callback = function()
        vim.opt_local.cursorline = false
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'msg',
    callback = function(args)
        vim.schedule(function()
            local win = vim.fn.bufwinid(args.buf)
            if win and win > -1 then
                vim.api.nvim_win_set_config(win, {
                    relative = 'editor',
                    anchor = 'NE',
                    row = 1,
                    col = vim.o.columns - 1,
                    focusable = false,
                    border = 'single',
                    style = 'minimal',
                })

                vim.wo[win].winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder'
            end
        end)
    end,
})

local diag_group = vim.api.nvim_create_augroup('HideDiagnostics', { clear = true })

vim.api.nvim_create_autocmd('ModeChanged', {
    group = diag_group,
    callback = function(args)
        local mode = vim.api.nvim_get_mode().mode

        if mode:sub(1, 1) == 'i' or mode:sub(1, 1) == 's' or mode:sub(1, 1) == '\x13' then
            vim.diagnostic.enable(false, { bufnr = args.buf })
        else
            vim.diagnostic.enable(true, { bufnr = args.buf })
        end
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = {
        'help',
        'qf',
        'man',
        'lspinfo',
        'checkhealth',
        'lazy',
        'mason',
        'notify',
        'trouble',
        'gitsigns-blame',
    },
    callback = function()
        vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = true, silent = true })
    end,
})
