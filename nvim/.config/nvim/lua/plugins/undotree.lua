return {
    'jiaoshijie/undotree',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
        require('undotree').setup {
            float_diff = true, -- using float window previews diff, set this `true` will disable layout option
            -- layout = 'left_bottom', -- "left_bottom", "left_left_bottom"
            position = 'right', -- "right", "bottom"
            ignore_filetype = { 'undotree', 'undotreeDiff', 'qf', 'FzfLua', 'spectre_panel', 'tsplayground', 'dashboard', 'NvimTree' },
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
    end,
    keys = {
        { '<leader>u', "<cmd>lua require('undotree').toggle()<cr>", desc = 'Undotree', mode = 'n' },
    },
}
