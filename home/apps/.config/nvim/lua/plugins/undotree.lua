local undotree = require 'undotree'

undotree.setup {
    float_diff = true,
    position = 'right',
    ignore_filetype = { 'FzfLua' },
    window = {
        border = 'single',
    },
}

vim.keymap.set('n', '<leader>u', undotree.toggle, { desc = 'Undotree' })
