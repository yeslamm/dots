return {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
        require('dashboard').setup {
            theme = 'doom',
            config = {
                header = {
                    [[                                                 ]],
                    [[                                                 ]],
                    [[                                                 ]],
                    [[                               __                ]],
                    [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
                    [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
                    [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
                    [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
                    [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
                    [[                                                 ]],
                    [[                                                 ]],
                    [[                                                 ]],
                    [[                                                 ]],
                },
                vertical_center = true,

                center = {
                    {
                        icon = '  ',
                        icon_hl = 'Include',
                        desc = 'Find File                       ',
                        desc_hl = 'String',
                        key = 'f',
                        key_hl = 'Keyword',
                        action = 'Telescope find_files',
                        key_format = '[%s]',
                    },
                    {
                        icon = '  ',
                        icon_hl = 'Include',
                        desc = 'Find Text                       ',
                        desc_hl = 'String',
                        key = 'g',
                        key_hl = 'Keyword',
                        action = 'Telescope live_grep',
                        key_format = '[%s]',
                    },
                    {
                        icon = '  ',
                        icon_hl = 'Include',
                        desc = 'New File                        ',
                        desc_hl = 'String',
                        key = 'n',
                        key_hl = 'Keyword',
                        action = function()
                            vim.ui.input({ prompt = 'New file name: ' }, function(input)
                                if input ~= nil and input ~= '' then
                                    vim.cmd('e ' .. input)
                                end
                            end)
                        end,
                        key_format = '[%s]',
                    },
                    {
                        icon = '  ',
                        icon_hl = 'Include',
                        desc = 'Recent Files                    ',
                        desc_hl = 'String',
                        key = 'r',
                        key_hl = 'Keyword',
                        action = 'Telescope oldfiles',
                        key_format = '[%s]',
                    },
                    -- {
                    --     icon = '  ',
                    --     icon_hl = 'Include',
                    --     desc = 'Dotfiles                   ',
                    --     desc_hl = 'String',
                    --     key = 'd',
                    --     key_hl = 'Keyword',
                    --     action = 'edit ~/.config/nvim/lua/',
                    --     key_format = '[%s]',
                    -- },
                    {
                        icon = '  ',
                        icon_hl = 'Include',
                        desc = 'Dotfiles                   ',
                        desc_hl = 'String',
                        key = 'd',
                        key_hl = 'Keyword',
                        action = 'Telescope find_files cwd=~/.config/nvim/',
                        key_format = '[%s]',
                    },

                    {
                        icon = '  ',
                        icon_hl = 'Include',
                        desc = 'Quit                            ',
                        desc_hl = 'String',
                        key = 'q',
                        key_hl = 'Keyword',
                        action = 'qa',
                        key_format = '[%s]',
                    },
                },
            },
        }
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } },
}
