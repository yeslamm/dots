return { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
        {
            'L3MON4D3/LuaSnip',
            build = (function()
                -- Build Step is needed for regex support in snippets.
                -- This step is not supported in many windows environments.
                -- Remove the below condition to re-enable on windows.
                if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
                    return
                end
                return 'make install_jsregexp'
            end)(),
            dependencies = {
                -- `friendly-snippets` contains a variety of premade snippets.
                --    See the README about individual language/framework/plugin snippets:
                --    https://github.com/rafamadriz/friendly-snippets
                {
                    'rafamadriz/friendly-snippets',
                    config = function() end,
                },
            },
        },
        'saadparwaiz1/cmp_luasnip',

        -- Adds other completion capabilities.
        --  nvim-cmp does not ship with all sources by default. They are split
        --  into multiple repos for maintenance purposes.
        'hrsh7th/cmp-cmdline',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'onsails/lspkind.nvim',
    },
    config = function()
        -- See `:help cmp`
        local cmp = require 'cmp'
        local luasnip = require 'luasnip'
        luasnip.config.setup {}

        require('luasnip.loaders.from_vscode').lazy_load()

        cmp.setup {
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            experimental = {
                ghost_text = true,
            },
            window = {
                completion = cmp.config.window.bordered {
                    border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
                    winhighlight = 'Normal:Normal,FloatBorder:White',
                },
                documentation = cmp.config.window.bordered {
                    border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
                    winhighlight = 'Normal:Normal,FloatBorder:White',
                },
            },

            mapping = cmp.mapping.preset.insert {
                -- Modern Navigation
                ['<C-n>'] = cmp.mapping.select_next_item(),
                ['<C-p>'] = cmp.mapping.select_prev_item(),
                ['<C-j>'] = cmp.mapping.select_next_item(),
                ['<C-k>'] = cmp.mapping.select_prev_item(),

                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),

                -- Accept with Tab or C-y
                ['<Tab>'] = cmp.mapping.confirm { select = true },
                ['<C-y>'] = cmp.mapping.confirm { select = true },
                ['<C-Space>'] = cmp.mapping.complete {},

                -- Kill Shift-Tab (does nothing)
                ['<S-Tab>'] = cmp.mapping(function() end, { 'i', 's' }),

                -- Snippet Jumping
                ['<C-l>'] = cmp.mapping(function()
                    if luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    end
                end, { 'i', 's' }),
                ['<C-h>'] = cmp.mapping(function()
                    if luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                    end
                end, { 'i', 's' }),
            },
            sources = {
                { name = 'luasnip' },
                {
                    name = 'lazydev',
                    -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
                    group_index = 0,
                },
                { name = 'nvim_lsp' },
                { name = 'buffer' },
                { name = 'path' },
            },
            -- You can specify the fields to display in the completion menu.
            --   `fields` can be a table of strings, e.g., { "abbr", "kind", "menu" }.
            --   See `:help cmp.core.ConfigSchema.completion.fields` for more details.
            --   `format` can be used to customize the display of each item.
            --   For example, you can add icons to `kind` or `menu`.
            formatting = {
                format = require('lspkind').cmp_format {
                    mode = 'symbol_text', -- Show symbol and text
                    maxwidth = 50, -- Limit popup width
                    ellipsis_char = '...', -- Truncate long entries
                    menu = {
                        nvim_lsp = '[LSP]',
                        luasnip = '[Snippet]',
                        buffer = '[Buffer]',
                        path = '[Path]',
                    },
                },
            },
        }
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline {
                ['<C-j>'] = { c = cmp.mapping.select_next_item() },
                ['<C-k>'] = { c = cmp.mapping.select_prev_item() },
                ['<Tab>'] = { c = cmp.mapping.confirm { select = true } },
                ['<S-Tab>'] = { c = function() end }, -- Kill Shift-Tab in cmdline
            },
            sources = cmp.config.sources {
                { name = 'path' },
                { name = 'cmdline' },
            },
        })

        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline {
                ['<C-j>'] = { c = cmp.mapping.select_next_item() },
                ['<C-k>'] = { c = cmp.mapping.select_prev_item() },
                ['<Tab>'] = { c = cmp.mapping.confirm { select = true } },
                ['<S-Tab>'] = { c = function() end }, -- Kill Shift-Tab in search
            },
            sources = {
                { name = 'buffer' },
            },
        })
    end,
}
