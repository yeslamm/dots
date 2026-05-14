local augroup = vim.api.nvim_create_augroup('UserConfig', { clear = true })

-- Highlight yanked text (Visual feedback when you copy something)
vim.api.nvim_create_autocmd('TextYankPost', {
    group = augroup,
    callback = function()
        vim.hl.on_yank { higroup = 'IncSearch', timeout = 250 }
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

-- Set conceallevel AND wrap for specific filetypes
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'markdown', 'markdown_inline', 'help' },
    callback = function()
        vim.opt_local.conceallevel = 2
        vim.opt_local.wrap = true
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

-- auto resize splits when the terminal's window is resized
vim.api.nvim_create_autocmd('VimResized', {
    command = 'wincmd =',
})

-- Create a single group for both autocommands so they don't step on each other
local cursorline_group = vim.api.nvim_create_augroup('active_cursorline', { clear = true })

-- Turn cursorline ON when entering a window or buffer
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
    group = cursorline_group,
    callback = function()
        vim.opt_local.cursorline = true
    end,
})

-- Turn cursorline OFF when leaving a window
vim.api.nvim_create_autocmd({ 'WinLeave' }, {
    group = cursorline_group,
    callback = function()
        vim.opt_local.cursorline = false
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'msg',
    callback = function(args)
        -- Wait a tiny bit for the window to actually exist
        vim.schedule(function()
            local win = vim.fn.bufwinid(args.buf)
            if win and win > -1 then
                vim.api.nvim_win_set_config(win, {
                    relative = 'editor',
                    anchor = 'NE', -- Top-right corner of the float
                    row = 1, -- 1 line down from the top
                    col = vim.o.columns - 1, -- Hug the right edge
                    focusable = false,
                    border = 'single',
                    style = 'minimal', -- Removes extra UI elements
                })

                -- Optional: Force a specific color for the notification window
                vim.wo[win].winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder'
            end
        end)
    end,
})

-- Hide diagnostics completely in Insert AND Select (snippet) modes
local diag_group = vim.api.nvim_create_augroup('HideDiagnostics', { clear = true })

vim.api.nvim_create_autocmd('ModeChanged', {
    group = diag_group,
    callback = function(args)
        local mode = vim.api.nvim_get_mode().mode

        -- 'i' is Insert mode, 's' is Select mode, '\x13' is Block-Select mode
        if mode:sub(1, 1) == 'i' or mode:sub(1, 1) == 's' or mode:sub(1, 1) == '\x13' then
            vim.diagnostic.enable(false, { bufnr = args.buf })
        else
            vim.diagnostic.enable(true, { bufnr = args.buf })
        end
    end,
})
