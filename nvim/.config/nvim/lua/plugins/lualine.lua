return {
    {
        'nvim-lualine/lualine.nvim',
        event = 'VeryLazy',
        config = function()
            local hide_in_width = function()
                return vim.fn.winwidth(0) > 100
            end

            -- 1. Native Macro Recording Logic
            local function macro_recording()
                local reg = vim.fn.reg_recording()
                if reg == '' then
                    return ''
                end
                return 'Recording @' .. reg
            end

            -- 2. Simplified LSP Names
            local function lsp_clients()
                local clients = vim.lsp.get_clients { bufnr = 0 }
                if #clients == 0 then
                    return ''
                end
                local names = {}
                for _, client in pairs(clients) do
                    table.insert(names, client.name)
                end
                -- Only show full list if there's room, otherwise just the first
                local client_str = table.concat(names, '|')
                if #client_str > 20 and not hide_in_width() then
                    return ' ' .. clients[1].name
                end
                return ' ' .. client_str
            end

            local diagnostics = {
                'diagnostics',
                sources = { 'nvim_diagnostic' },
                sections = { 'error', 'warn', 'info', 'hint' },
                symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
                colored = true,
                update_in_insert = true,
                always_visible = false,
                cond = hide_in_width,
            }

            local diff = {
                'diff',
                colored = true,
                symbols = { added = ' ', modified = ' ', removed = ' ' }, -- changes diff symbols
                cond = hide_in_width,
            }

            require('lualine').setup {
                options = {
                    icons_enabled = true,
                    theme = 'auto',
                    section_separators = { left = '', right = '' },
                    component_separators = { left = '', right = '' },
                    always_divide_middle = true,
                    globalstatus = true,
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch' },
                    lualine_c = { { 'filename', path = 3 } },
                    lualine_x = {

                        -- Native Macro Component
                        {
                            macro_recording,
                            color = { fg = '#ff9e64', gui = 'bold' },
                        },
                        -- Native Search Count (Standard Lualine component)
                        {
                            'searchcount',
                            maxcount = 999,
                            timeout = 500,
                        },

                        diagnostics,
                        diff,
                        lsp_clients,
                        { 'filetype', cond = hide_in_width },
                    },
                    lualine_y = { 'location' },
                    lualine_z = { 'progress' },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { { 'filename', path = 1 } },
                    lualine_x = { { 'location', padding = 0 } },
                    lualine_y = {},
                    lualine_z = {},
                },
                tabline = {},
            }
        end,
    },
}
