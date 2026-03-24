return {
    'zenbones-theme/zenbones.nvim',
    -- lush.nvim is highly recommended to unlock all features and rich colors
    dependencies = { 'rktjmp/lush.nvim' },
    lazy = false, -- Ensure it loads immediately on startup
    priority = 1000, -- Load before other plugins to prevent UI flashing
    config = function()
        -- 1. Set your background color preference
        -- vim.o.background = 'dark'

        -- 2. Optional configuration: Customize the theme BEFORE applying it
        vim.g.zenbones_darken_comments = 45 -- Makes comments fade into the background more
        vim.g.zenbones_solid_line_nr = true -- Gives line numbers a slightly solid background
        vim.g.zenbones_italic_comments = true -- Enables italicized comments

        -- 3. Apply the colorscheme
        vim.cmd.colorscheme 'zenbones'
    end,
}
