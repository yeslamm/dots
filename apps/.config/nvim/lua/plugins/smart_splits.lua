local ss = require 'smart-splits'

local in_tmux = vim.env.TMUX ~= nil and vim.env.TMUX_PANE ~= nil

---@diagnostic disable-next-line: missing-fields
require('smart-splits').setup {
    multiplexer_integration = in_tmux and 'tmux' or false,
    log_level = 'error',
}

vim.keymap.set('n', '<C-h>', ss.move_cursor_left, { desc = 'Move to left split/pane' })
vim.keymap.set('n', '<C-j>', ss.move_cursor_down, { desc = 'Move to bottom split/pane' })
vim.keymap.set('n', '<C-k>', ss.move_cursor_up, { desc = 'Move to top split/pane' })
vim.keymap.set('n', '<C-l>', ss.move_cursor_right, { desc = 'Move to right split/pane' })

vim.keymap.set('n', '<C-A-h>', ss.resize_left, { desc = 'Resize window left' })
vim.keymap.set('n', '<C-A-j>', ss.resize_down, { desc = 'Resize window down' })
vim.keymap.set('n', '<C-A-k>', ss.resize_up, { desc = 'Resize window up' })
vim.keymap.set('n', '<C-A-l>', ss.resize_right, { desc = 'Resize window right' })
