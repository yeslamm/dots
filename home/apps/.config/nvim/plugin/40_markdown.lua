require('render-markdown').setup {
    render_modes = { 'n', 'v', 'V', '\22', 'c', 't' },

    sign = { enabled = false },

    completions = {
        lsp = { enabled = true },
    },

    heading = {
        width = 'block',
        icons = { '# ', '## ', '### ', '#### ', '##### ', '###### ' },
        right_pad = 1,
    },

    code = {
        width = 'block',
        border = 'thin',
        right_pad = 2,
    },

    bullet = {
        icons = { '•' },
    },

    checkbox = {
        bullet = true,
        unchecked = { icon = '[ ]' },
        checked = { icon = '[x]' },
    },

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

local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
vim.api.nvim_set_hl(0, 'RenderMarkdownBullet', { fg = normal.fg, bg = 'NONE' })

require('mdkite').setup {}

local map = vim.keymap.set
local opts = { silent = true }
map('n', '<leader>mt', '<cmd>MdKite toggle<CR>', vim.tbl_extend('force', opts, { desc = 'Markdown: Toggle Preview' }))
map('n', '<leader>ms', '<cmd>MdKite start<CR>', vim.tbl_extend('force', opts, { desc = 'Markdown: Start Preview' }))
map('n', '<leader>mx', '<cmd>MdKite stop<CR>', vim.tbl_extend('force', opts, { desc = 'Markdown: Stop Preview' }))
map('n', '<leader>mr', '<cmd>MdKite refresh<CR>', vim.tbl_extend('force', opts, { desc = 'Markdown: Refresh Preview' }))
