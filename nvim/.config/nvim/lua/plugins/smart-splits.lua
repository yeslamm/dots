return {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    config = function()
        local ss = require 'smart-splits'
        ss.setup {
            ignored_filetypes = { 'nofile', 'quickfix', 'qf', 'prompt' },
            ignored_buftypes = { 'nofile' },
            default_amount = 3,
        }

        -- Moving between splits/panes
        vim.keymap.set('n', '<C-h>', ss.move_cursor_left, { desc = 'Move Left' })
        vim.keymap.set('n', '<C-j>', ss.move_cursor_down, { desc = 'Move Down' })
        vim.keymap.set('n', '<C-k>', ss.move_cursor_up, { desc = 'Move Up' })
        vim.keymap.set('n', '<C-l>', ss.move_cursor_right, { desc = 'Move Right' })

        -- Resizing splits/panes
        vim.keymap.set('n', '<A-h>', ss.resize_left, { desc = 'Resize Left' })
        vim.keymap.set('n', '<A-j>', ss.resize_down, { desc = 'Resize Down' })
        vim.keymap.set('n', '<A-k>', ss.resize_up, { desc = 'Resize Up' })
        vim.keymap.set('n', '<A-l>', ss.resize_right, { desc = 'Resize Right' })
    end,
}
