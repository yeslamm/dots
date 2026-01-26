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
                enabled = false,
                auto_open = {
                    enabled = true,
                    trigger = true,
                    luasnip = true,
                    throttle = 50,
                },
            },
            hover = {
                enabled = true,
                silent = false,
            },
            override = {
                -- Enable these if you want noice.nvim to handle markdown rendering in LSP and cmp documentation
                ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                ['vim.lsp.util.stylize_markdown'] = true,
                ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp,
            },
        },
        messages = {
            -- disable or tune confirmation prompts
            enabled = true, -- disables most message spam, can reduce interrupts
        },
        cmdline = {
            enabled = true,
        },
        presets = {
            bottom_search = false, -- Puts / and ? at the bottom like classic cmdline
            command_palette = true, -- Puts : cmdline and popupmenu together
            long_message_to_split = false, -- Long messages go to a separate split
            inc_rename = false, -- Disable input dialog for inc-rename.nvim
            lsp_doc_border = true, -- Enabled to help with flicker
        },
    },
    dependencies = {
        'MunifTanjim/nui.nvim',
        {
            'rcarriga/nvim-notify',
            opts = {
                render = 'wrapped-compact',
                -- stages = 'fade',
                -- stages = 'fade_in_slide_out',
                -- stages = 'slide',
                stages = 'static',
                timeout = 2500,
                background_colour = '#000000',
            },
        },
    },
}
