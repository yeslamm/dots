local oil = require 'oil'

oil.setup {
    default_file_explorer = true,
    prompt_save_on_select_new_entry = false,
    delete_to_trash = true,
    float = {
        padding = 2,
        max_width = 80,
        max_height = 40,
        border = 'single',
        win_options = {
            winblend = 0,
        },
    },
    view_options = {
        show_hidden = true,
        is_hidden_file = function(name, _)
            return vim.startswith(name, '.')
        end,
        is_always_hidden = function(_, _)
            return false
        end,
    },
    keymaps = {
        ['q'] = 'actions.close',
        ['<C-c>'] = false,
        ['='] = function()
            vim.cmd 'write'
        end,
    },
}

vim.keymap.set('n', '<C-o>', oil.toggle_float, { noremap = true, silent = true, desc = 'Toggle Oil Float' })
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
