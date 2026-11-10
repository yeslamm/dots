require('mdkite').setup {}

local map = vim.keymap.set
local opts = { silent = true }
map('n', '<leader>mt', '<cmd>MdKite toggle<CR>', vim.tbl_extend('force', opts, { desc = 'Markdown: Toggle Preview' }))
map('n', '<leader>ms', '<cmd>MdKite start<CR>', vim.tbl_extend('force', opts, { desc = 'Markdown: Start Preview' }))
map('n', '<leader>mx', '<cmd>MdKite stop<CR>', vim.tbl_extend('force', opts, { desc = 'Markdown: Stop Preview' }))
map('n', '<leader>mr', '<cmd>MdKite refresh<CR>', vim.tbl_extend('force', opts, { desc = 'Markdown: Refresh Preview' }))
