local oil = require 'oil'

oil.setup {
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    prompt_save_on_select_new_entry = true,
    constrain_cursor = 'name',
    watch_for_changes = true,

    view_options = {
        show_hidden = true,
        sort = {
            { 'type', 'asc' },
            { 'name', 'asc' },
        },
    },

    columns = {
        'icon',
    },

    preview_win = {
        update_on_cursor_moved = true,
        preview_method = 'fast_scratch',
    },

    keymaps = {
        ['q'] = 'actions.close',
        ['<C-c>'] = false,
        ['='] = '<cmd>write<CR>',

        ['<leader>so'] = {
            function()
                require('fzf-lua').files { cwd = oil.get_current_dir() }
            end,
            mode = 'n',
            desc = 'Oil: Find files',
        },
        ['<leader>sO'] = {
            function()
                require('fzf-lua').live_grep { cwd = oil.get_current_dir() }
            end,
            mode = 'n',
            desc = 'Oil: Grep files',
        },
    },
}

vim.keymap.set('n', '<leader>o', oil.toggle_float, { silent = true, desc = 'Oil: Toggle Float' })
vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Oil: Open Parent Directory' })
