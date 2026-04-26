return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    -- Notice we removed `branch = 'master'` so it pulls the new `main` rewrite
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
        -- 1. Initialize the new Treesitter architecture
        require('nvim-treesitter').setup {}

        -- 2. Tell it which language parsers to download
        -- (This function runs asynchronously in the background)
        require('nvim-treesitter').install {
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
        }

        -- 3. Tell Neovim to turn on its native Treesitter engine for every file you open
        vim.api.nvim_create_autocmd('FileType', {
            pattern = '*',
            callback = function()
                -- We wrap this in a 'pcall' (protected call) so it silently ignores
                -- files that don't have a parser installed yet, instead of throwing an error.
                pcall(vim.treesitter.start)
            end,
        })
    end,
}
