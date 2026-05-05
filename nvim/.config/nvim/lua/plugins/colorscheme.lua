return {
    {
        'vague-theme/vague.nvim',
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other plugins
        config = function()
            require('vague').setup {
                -- optional configuration here
            }
            vim.cmd 'colorscheme vague'
            vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
            vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none' })
        end,
    },
    {
        'rebelot/kanagawa.nvim',
        lazy = false,
        config = function()
            require('kanagawa').setup {
                compile = false, -- enable compiling the colorscheme
                undercurl = true, -- enable undercurls
                commentStyle = { italic = true },
                functionStyle = {},
                keywordStyle = { italic = true },
                statementStyle = { bold = true },
                typeStyle = {},
                transparent = false, -- do not set background color
                dimInactive = false, -- dim inactive window `:h hl-NormalNC`
                terminalColors = true, -- define vim.g.terminal_color_{0,17}
                colors = { -- add/modify theme and palette colors
                    palette = {},
                    theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
                },
                overrides = function() -- add/modify highlights
                    return {}
                end,
                theme = 'dragon', -- Load "wave" theme
                background = { -- map the value of 'background' option to a theme
                    dark = 'dragon', -- try "dragon" !
                    light = 'lotus',
                },
            }
            -- vim.cmd 'colorscheme kanagawa'
        end,
    },
    {
        'rose-pine/neovim',
        name = 'rose-pine',
    },
}
