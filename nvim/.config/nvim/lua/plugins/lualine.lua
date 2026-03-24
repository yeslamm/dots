return {
    -- { 'archibate/lualine-time' },
    {
        'nvim-lualine/lualine.nvim',
        config = function()
            local mode = {
                'mode',
                fmt = function(str)
                    return '' .. str .. ''
                    -- return ' ' .. str
                    -- return ' ' .. str:sub(1, 1) -- displays only the first character of the mode
                end,
            }

            local hide_in_width = function()
                return vim.fn.winwidth(0) > 100
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

            local function lsp_clients()
                local bufnr = vim.api.nvim_get_current_buf()
                local clients = vim.lsp.get_clients { bufnr = bufnr }
                if next(clients) == nil then
                    return ''
                end
                local names = {}
                for _, client in pairs(clients) do
                    table.insert(names, client.name)
                end
                return ' ' .. table.concat(names, '|')
            end

            require('lualine').setup {
                options = {
                    icons_enabled = true,
                    -- theme = 'onedark',
                    -- theme = 'zenbones',
                    theme = 'vague',
                    section_separators = { left = '', right = '' },
                    component_separators = { left = '', right = '' },
                    disabled_filetypes = {
                        statusline = {
                            'NvimTree',
                            'undotree',
                            'dashboard',
                            'ministarter',
                            'toggleterm',
                            'terminal',
                            'TelescopePrompt',
                        },
                    },
                    always_divide_middle = true,
                    globalstatus = false,
                },
                sections = {
                    lualine_a = { mode },
                    lualine_b = { 'branch' },
                    lualine_c = { { 'filename', path = 3 } },
                    lualine_x = {
                        {
                            'recording',
                            fmt = function()
                                local reg = vim.fn.reg_recording()
                                return reg ~= '' and ('@%s'):format(reg) or ''
                            end,
                            cond = function()
                                return vim.fn.reg_recording() ~= ''
                            end,
                            color = { fg = '#ff9e64' }, -- Adjust color to match your theme, e.g., orange
                        },

                        diagnostics,
                        diff,
                        { 'encoding', cond = hide_in_width },
                        lsp_clients,
                        -- filetype_icon,
                        { 'filetype', cond = hide_in_width },
                        -- function()
                        --   return os.date '%I:%M %p' -- 12-hour format with AM/PM
                        -- end,
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
                extensions = { 'fugitive' },
            }
            vim.api.nvim_set_hl(0, 'Lualine_c', { bg = 'none' })
            vim.api.nvim_set_hl(0, 'Lualine_a', { bg = 'none' })
            vim.api.nvim_set_hl(0, 'Lualine_b', { bg = 'none' })
            vim.api.nvim_set_hl(0, 'Lualine_x', { bg = 'none' })
            vim.api.nvim_set_hl(0, 'Lualine_y', { bg = 'none' })
            vim.api.nvim_set_hl(0, 'Lualine_z', { bg = 'none' })
        end,
    },
}
