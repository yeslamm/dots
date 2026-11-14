---@diagnostic disable: missing-fields
local smart_splits = require 'smart-splits'

smart_splits.setup {
    mux = {
        backend = 'smart-splits-backend-tmux',
        warn_if_unusable = false,
    },
    log = { level = 'error' },
}

vim.keymap.set('n', '<C-A-h>', smart_splits.resize_left, { desc = 'Resize split left' })
vim.keymap.set('n', '<C-A-j>', smart_splits.resize_down, { desc = 'Resize split down' })
vim.keymap.set('n', '<C-A-k>', smart_splits.resize_up, { desc = 'Resize split up' })
vim.keymap.set('n', '<C-A-l>', smart_splits.resize_right, { desc = 'Resize split right' })

vim.keymap.set('n', '<C-h>', smart_splits.move_cursor_left, { desc = 'Move to left split' })
vim.keymap.set('n', '<C-j>', smart_splits.move_cursor_down, { desc = 'Move to below split' })
vim.keymap.set('n', '<C-k>', smart_splits.move_cursor_up, { desc = 'Move to above split' })
vim.keymap.set('n', '<C-l>', smart_splits.move_cursor_right, { desc = 'Move to right split' })

vim.keymap.set('n', '<A-H>', smart_splits.swap_buf_left, { desc = 'Swap buffer left' })
vim.keymap.set('n', '<A-J>', smart_splits.swap_buf_down, { desc = 'Swap buffer down' })
vim.keymap.set('n', '<A-K>', smart_splits.swap_buf_up, { desc = 'Swap buffer up' })
vim.keymap.set('n', '<A-L>', smart_splits.swap_buf_right, { desc = 'Swap buffer right' })
