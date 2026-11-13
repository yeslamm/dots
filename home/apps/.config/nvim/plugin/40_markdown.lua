require('render-markdown').setup {
    completions = {
        lsp = { enabled = true },
    },

    sign = { enabled = false },

    heading = {
        width = 'block',
        icons = {},
    },

    code = {
        width = 'block',
        left_pad = 2,
        right_pad = 2,
        border = 'thin',
    },

    bullet = { enabled = false },
    checkbox = { enabled = false },

    pipe_table = {
        style = 'normal',
        wrap = false,
        padding = 2,
    },

    quote = {
        repeat_linebreak = true,
    },

    latex = {
        render_modes = { 'n', 'c', 'v' },
    },
}

require('mdkite').setup {}

local map = vim.keymap.set
local opts = { silent = true }
map('n', '<leader>mt', '<cmd>MdKite toggle<CR>', vim.tbl_extend('force', opts, { desc = 'Markdown: Toggle Preview' }))
map('n', '<leader>ms', '<cmd>MdKite start<CR>', vim.tbl_extend('force', opts, { desc = 'Markdown: Start Preview' }))
map('n', '<leader>mx', '<cmd>MdKite stop<CR>', vim.tbl_extend('force', opts, { desc = 'Markdown: Stop Preview' }))
map('n', '<leader>mr', '<cmd>MdKite refresh<CR>', vim.tbl_extend('force', opts, { desc = 'Markdown: Refresh Preview' }))
