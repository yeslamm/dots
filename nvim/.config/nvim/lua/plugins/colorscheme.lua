return {
    {
        'EdenEast/nightfox.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            require('nightfox').setup {
                options = {
                    transparent = false,
                    terminal_colors = true,
                },
            }
            vim.cmd 'colorscheme carbonfox'
        end,
    },
    {
        'vague-theme/vague.nvim',
        lazy = true,
        config = function()
            require('vague').setup {
                transparent = false,
            }
            -- vim.cmd 'colorscheme vague'
        end,
    },
    {
        'rebelot/kanagawa.nvim',
        lazy = true,
        config = function()
            require('kanagawa').setup {
                transparent = false,
                terminalColors = true,
                theme = 'dragon',
            }
            -- vim.cmd 'colorscheme kanagawa'
        end,
    },
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        lazy = true,
    },
}
