local is_configured = false

vim.keymap.set('n', '<leader>u', function()
    local undotree = require 'undotree'

    if not is_configured then
        undotree.setup {
            float_diff = true,
            position = 'right',
            ignore_filetype = {
                'undotree',
                'undotreeDiff',
                'qf',
                'FzfLua',
                'spectre_panel',
                'tsplayground',
                'dashboard',
                'NvimTree',
            },
            window = {
                border = 'single',
            },
            keymaps = {
                ['move_next'] = 'j',
                ['move_prev'] = 'k',
                ['move2parent'] = 'gj',
                ['move_change_next'] = 'J',
                ['move_change_prev'] = 'K',
                ['action_enter'] = '<cr>',
                ['enter_diffbuf'] = 'p',
                ['quit'] = 'q',
            },
        }
        is_configured = true
    end

    undotree.toggle()
end, { desc = 'Undotree' })
