return {
    'navarasu/onedark.nvim',
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        -- 1. Setup the colorscheme (must be done first)
        require('onedark').setup {
            style = 'warmer', -- Default theme style
            transparent = false, -- Show/hide background
        }

        -- 2. Apply the colorscheme (using the canonical vim command)
        vim.cmd.colorscheme 'onedark'

        -- 3. Custom Highlights/Transparency
        vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'none' })
        vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = 'none' })
        vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none' })
        vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
        vim.api.nvim_set_hl(0, 'FzfLuaNormal', { bg = 'none' })
        vim.api.nvim_set_hl(0, 'FzfLuaBorder', { bg = 'none' })
        vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'none' }) -- Popup menus
    end,
}
