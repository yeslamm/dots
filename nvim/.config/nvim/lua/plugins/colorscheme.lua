return {
    {
        'EdenEast/nightfox.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            require('nightfox').setup {
                options = {
                    transparent = false, -- Disable setting background
                    terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
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
                terminalColors = true, -- define vim.g.terminal_color_{0,17}
                theme = 'dragon', -- Load "wave" theme
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
