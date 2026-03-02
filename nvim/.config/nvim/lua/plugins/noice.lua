return {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
        routes = {
            {
                filter = {
                    event = 'cmdline',
                    kind = 'search',
                },
                opts = { skip = true },
            },
        },
        lsp = {
            signature = {
                enabled = true,
                auto_open = {
                    enabled = true,
                    trigger = true,
                    luasnip = true,
                    throttle = 50,
                },
            },
            hover = {
                enabled = true,
                silent = true,
            },
            override = {
                ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                ['vim.lsp.util.stylize_markdown'] = true,
                ['cmp.entry.get_documentation'] = true,
            },
        },
        messages = {
            enabled = true,
        },
        cmdline = {
            enabled = true,
        },
        presets = {
            bottom_search = false,
            command_palette = true,
            long_message_to_split = false,
            inc_rename = false,
            lsp_doc_border = true,
        },
        -- Ensure Noice uses nvim-notify for notifications
        views = {
            notify = {
                backend = 'notify',
                fallback = 'mini',
            },
        },
    },
    dependencies = {
        'MunifTanjim/nui.nvim',
        {
            'rcarriga/nvim-notify',
            opts = {
                render = 'wrapped-compact',
                stages = 'static', -- this is the key for no animation
                timeout = 2500,
                background_colour = '#000000',
                fps = 1, -- lowering fps for static stages can sometimes help stability
            },
            config = function(_, opts)
                require('notify').setup(opts)
                vim.notify = require 'notify' -- explicitly override the global notify function
            end,
        },
    },
}
