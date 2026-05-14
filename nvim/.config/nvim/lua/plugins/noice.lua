return {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
        lsp = {
            enabled = true, -- This replaces Fidget[cite: 1]
            signature = { enabled = false },
            view = 'mini', -- A tiny, non-intrusive notification in the corner[cite: 1]
            override = {
                ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                ['vim.lsp.util.stylize_markdown'] = true,
                ['cmp.entry.get_documentation'] = true,
            },
        },
        views = {
            cmdline_popup = {
                border = { style = 'single', padding = { 0, 1 } },
            },
            cmdline_input = {
                border = { style = 'single' },
            },
            popupmenu = {
                relative = 'editor',
                border = { style = 'single', padding = { 0, 1 } },
                win_options = {
                    winhighlight = { Normal = 'NormalFloat', FloatBorder = 'FloatBorder' },
                },
            },
            hover = {
                border = { style = 'single' },
            },
            confirm = {
                border = { style = 'single' },
            },
        },
        presets = {
            bottom_search = true,
            command_palette = true,
            long_message_to_split = true,
            inc_rename = false,
            lsp_doc_border = true,
        },
    },
    dependencies = {
        'MunifTanjim/nui.nvim',
        {
            'rcarriga/nvim-notify',
            opts = {
                render = 'wrapped-compact',
                stages = 'static',
                timeout = 2500,
                background_colour = '#000000',
                fps = 1,
                on_open = function(win)
                    vim.api.nvim_win_set_config(win, { border = 'single' })
                end,
            },
            config = function(_, opts)
                require('notify').setup(opts)
                vim.notify = require 'notify'
            end,
        },
    },
    keys = {
        {
            '<S-Enter>',
            function()
                require('noice').redirect(vim.fn.getcmdline())
            end,
            mode = 'c',
            desc = 'Redirect Cmdline',
        },
        {
            '<leader>nl',
            function()
                require('noice').cmd 'last'
            end,
            desc = 'Noice Last Message',
        },
        {
            '<leader>nh',
            function()
                require('noice').cmd 'history'
            end,
            desc = 'Noice History',
        },
        {
            '<leader>na',
            function()
                require('noice').cmd 'all'
            end,
            desc = 'Noice All',
        },
        {
            '<leader>nd',
            function()
                require('noice').cmd 'dismiss'
            end,
            desc = 'Dismiss All Notifications',
        },
        {
            '<c-f>',
            function()
                if not require('noice.lsp').scroll(4) then
                    return '<c-f>'
                end
            end,
            silent = true,
            expr = true,
            desc = 'Scroll Forward',
            mode = { 'i', 'n', 's' },
        },
        {
            '<c-b>',
            function()
                if not require('noice.lsp').scroll(-4) then
                    return '<c-b>'
                end
            end,
            silent = true,
            expr = true,
            desc = 'Scroll Backward',
            mode = { 'i', 'n', 's' },
        },
    },
}
