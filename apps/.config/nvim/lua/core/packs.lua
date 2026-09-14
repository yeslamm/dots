vim.pack.add {
    -- Foundations & UI
    'https://github.com/EdenEast/nightfox.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/echasnovski/mini.nvim',
    'https://github.com/nvim-lualine/lualine.nvim',
    'https://github.com/lukas-reineke/indent-blankline.nvim',
    'https://github.com/brenoprata10/nvim-highlight-colors',

    -- LSP & Tool Management
    'https://github.com/williamboman/mason.nvim',
    'https://github.com/williamboman/mason-lspconfig.nvim',
    'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/b0o/schemastore.nvim',
    'https://github.com/j-hui/fidget.nvim',
    'https://github.com/folke/lazydev.nvim',

    -- Completion & Formatting / Linting
    { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.x' },
    'https://github.com/rafamadriz/friendly-snippets',
    'https://github.com/stevearc/conform.nvim',
    'https://github.com/mfussenegger/nvim-lint',

    -- Syntax & Tree-sitter
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',

    -- Navigation & Editing
    'https://github.com/ibhagwan/fzf-lua',
    'https://github.com/stevearc/oil.nvim',
    'https://github.com/mrjones2014/smart-splits.nvim',
    'https://github.com/windwp/nvim-autopairs',
    'https://github.com/folke/todo-comments.nvim',
    'https://github.com/folke/which-key.nvim',

    -- Git & History
    'https://github.com/lewis6991/gitsigns.nvim',
    'https://github.com/sindrets/diffview.nvim',
    'https://github.com/jiaoshijie/undotree',

    -- Debugging (DAP)
    'https://github.com/mfussenegger/nvim-dap',
    'https://github.com/theHamsta/nvim-dap-virtual-text',
    'https://github.com/jay-babu/mason-nvim-dap.nvim',
}

vim.api.nvim_create_user_command('PackUpdate', function(opts)
    vim.pack.update(opts.fargs[1] and { opts.fargs[1] } or nil, { force = opts.bang })
end, { bang = true, nargs = '?', desc = 'Update vim.pack plugins' })

vim.api.nvim_create_user_command('PackClean', function()
    local inactive = vim.iter(vim.pack.get())
        :filter(function(x)
            return not x.active
        end)
        :map(function(x)
            return x.spec.name
        end)
        :totable()

    if #inactive > 0 then
        vim.pack.del(inactive)
        vim.notify('Removed unmanaged plugins: ' .. table.concat(inactive, ', '), vim.log.levels.INFO)
    else
        vim.notify('No unmanaged plugins to remove', vim.log.levels.INFO)
    end
end, { desc = 'Purge unmanaged plugins from disk' })
