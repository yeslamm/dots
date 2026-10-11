require('diffview').setup()

vim.keymap.set('n', '<leader>gv', '<cmd>DiffviewOpen<CR>', { desc = 'Diffview' })
