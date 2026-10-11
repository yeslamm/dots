local oil = require 'oil'

oil.setup {
    prompt_save_on_select_new_entry = false,
    delete_to_trash = true,
    float = {
        padding = 2,
        max_width = 80,
        max_height = 40,
        border = 'single',
    },
    view_options = {
        show_hidden = true,
    },
    keymaps = {
        ['q'] = 'actions.close',
        ['<C-c>'] = false,
        ['='] = '<cmd>write<CR>',
    },
}

vim.keymap.set('n', '<C-o>', oil.toggle_float, { silent = true, desc = 'Toggle Oil Float' })
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
