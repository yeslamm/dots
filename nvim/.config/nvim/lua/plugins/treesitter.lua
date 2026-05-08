return {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
        -- 1. Setup the base plugin
        require('nvim-treesitter').setup()

        -- 2. Install parsers (This replaces ensure_installed & auto_install)
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

        -- 3. Native Highlighting (This replaces highlight = { enable = true })
        vim.api.nvim_create_autocmd('FileType', {
            pattern = '*',
            callback = function(args)
                -- We use pcall to prevent errors if you open a filetype without a parser
                pcall(vim.treesitter.start, args.buf)
            end,
        })

        -- 4. Native Indentation (This replaces indent = { enable = true })
        vim.api.nvim_create_autocmd('FileType', {
            pattern = '*',
            callback = function()
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
