return {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master', -- ADD THIS LINE: Forces the stable branch
    build = ':TSUpdate',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
        require('nvim-treesitter.configs').setup {
            -- 1. ADDED THESE TO STOP THE WARNINGS
            modules = {},
            sync_install = false,
            ignore_install = {},

            -- 2. YOUR EXISTING CONFIG
            ensure_installed = {
                'bash',
                'c',
                'diff',
                'html',
                'lua',
                'luadoc',
                'markdown',
                'markdown_inline',
                'python',
                'query',
                'vim',
                'vimdoc',
            },
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
        }
    end,
}
