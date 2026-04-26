return {
    'vague-theme/vague.nvim',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other plugins
    config = function()
        require('vague').setup {
            -- optional configuration here
        }
        vim.cmd 'colorscheme vague'
        -- Make all floating windows (including fzf-lua, which-key, and LSP hovers) transparent
        vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
        vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none' })
    end,
}
