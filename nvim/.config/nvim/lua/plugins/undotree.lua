return {
    'jiaoshijie/undotree',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
        require('undotree').setup {
            float_diff = true, -- using float window previews diff, set this `true` will disable layout option
            -- layout = 'left_bottom', -- "left_bottom", "left_left_bottom"
            position = 'right', -- "right", "bottom"
            ignore_filetype = { 'undotree', 'undotreeDiff', 'qf', 'FzfLua', 'spectre_panel', 'tsplayground', 'dashboard', 'NvimTree' },
            -- window = {
            --     winblend = 0,
            --     width = 40, -- Set this to your desired width (default is 30)
            --     height = 15,
            -- },
            keymaps = {
                ['j'] = 'move_next',
                ['k'] = 'move_prev',
                ['gj'] = 'move2parent',
                ['J'] = 'move_change_next',
                ['K'] = 'move_change_prev',
                ['<cr>'] = 'action_enter',
                ['p'] = 'enter_diffbuf',
                ['q'] = 'quit',
            },
        }
    end,
    keys = {
        { '<leader>u', "<cmd>lua require('undotree').toggle()<cr>", desc = 'Undotree', mode = 'n' },
    },
}
