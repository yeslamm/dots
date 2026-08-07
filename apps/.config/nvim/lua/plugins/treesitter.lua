return {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    config = function()
        require('nvim-treesitter').setup()
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
            'toml',
        }

        local ts_group = vim.api.nvim_create_augroup('NvimTreesitterConfig', { clear = true })

        local ignored_filetypes = {
            tmux = true,
        }

        vim.api.nvim_create_autocmd('FileType', {
            group = ts_group,
            callback = function(args)
                local buf = args.buf
                local ft = vim.bo[buf].filetype

                if ignored_filetypes[ft] then
                    return
                end

                local lang = vim.treesitter.language.get_lang(ft) or ft
                if not pcall(vim.treesitter.language.add, lang) then
                    return
                end

                local success = pcall(vim.treesitter.start, buf)

                if success then
                    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

                    vim.opt_local.foldmethod = 'expr'
                    vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                end
            end,
        })
    end,
}
