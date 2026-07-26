return {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    config = function()
        local ss = require 'smart-splits'

        ---@diagnostic disable-next-line: missing-fields
        ss.setup {
            multiplexer_integration = 'tmux',
        }

        vim.keymap.set('n', '<C-h>', ss.move_cursor_left, { desc = 'Move to left split/pane' })
        vim.keymap.set('n', '<C-j>', ss.move_cursor_down, { desc = 'Move to bottom split/pane' })
        vim.keymap.set('n', '<C-k>', ss.move_cursor_up, { desc = 'Move to top split/pane' })
        vim.keymap.set('n', '<C-l>', ss.move_cursor_right, { desc = 'Move to right split/pane' })

        vim.keymap.set('n', '<C-A-h>', ss.resize_left, { desc = 'Resize window left' })
        vim.keymap.set('n', '<C-A-j>', ss.resize_down, { desc = 'Resize window down' })
        vim.keymap.set('n', '<C-A-k>', ss.resize_up, { desc = 'Resize window up' })
        vim.keymap.set('n', '<C-A-l>', ss.resize_right, { desc = 'Resize window right' })
    end,
}
