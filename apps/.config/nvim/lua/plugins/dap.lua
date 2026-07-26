return {
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'williamboman/mason.nvim',
            'jay-babu/mason-nvim-dap.nvim',
        },
        config = function()
            local dap = require 'dap'

            vim.api.nvim_set_hl(0, 'DapBreakpoint', { ctermbg = 0, fg = '#993939' })
            vim.api.nvim_set_hl(0, 'DapLogPoint', { ctermbg = 0, fg = '#61afef' })
            vim.api.nvim_set_hl(0, 'DapStopped', { ctermbg = 0, fg = '#98c379' })

            vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
            vim.fn.sign_define('DapBreakpointCondition', { text = 'jg', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
            vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DapLogPoint', linehl = '', numhl = '' })
            vim.fn.sign_define('DapStopped', { text = '', texthl = 'DapStopped', linehl = '', numhl = '' })
            vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DapBreakpoint', linehl = '', numhl = '' })

            require('mason-nvim-dap').setup {
                automatic_installation = true,
                handlers = {},
                ensure_installed = { 'debugpy', 'codelldb', 'coreclr' },
            }

            dap.configurations.c = {
                {
                    name = 'Launch C/C++ executable',
                    type = 'codelldb',
                    request = 'launch',
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    console = 'integratedTerminal',
                },
            }
            dap.configurations.cpp = dap.configurations.c

            dap.configurations.python = {
                {
                    type = 'python',
                    request = 'launch',
                    name = 'Launch file',
                    program = '${file}',
                    pythonPath = function()
                        local venv_path = os.getenv 'VIRTUAL_ENV'
                        if venv_path then
                            return venv_path .. '/bin/python'
                        end
                        return '/usr/bin/python3'
                    end,
                    console = 'integratedTerminal',
                },
            }

            dap.configurations.cs = {
                {
                    type = 'coreclr',
                    name = 'Launch C# project',
                    request = 'launch',
                    program = function()
                        return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                },
            }

            vim.keymap.set('n', '<leader>Db', dap.toggle_breakpoint, { desc = 'Toggle Breakpoint', silent = true })
            vim.keymap.set('n', '<leader>Dc', dap.continue, { desc = 'Start/Continue', silent = true })
            vim.keymap.set('n', '<leader>Dx', dap.terminate, { desc = 'Terminate', silent = true })
            vim.keymap.set('n', '<leader>Dr', function()
                require('dap').repl.toggle(nil, 'botright 50vsplit')
            end, { desc = 'Toggle REPL', silent = true })

            vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Step Over', silent = true })
            vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Step Into', silent = true })
            vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Step Out', silent = true })
        end,
    },

    {
        'thehamsta/nvim-dap-virtual-text',
        dependencies = {
            'mfussenegger/nvim-dap',
            'nvim-treesitter/nvim-treesitter',
        },
        config = function()
            require('nvim-dap-virtual-text').setup {
                enabled = true,
                enabled_commands = true,
                highlight_changed_variables = true,
                highlight_new_as_changed = false,
                show_stop_reason = true,
                commented = false,
                only_first_definition = true,
                all_references = false,
            }
        end,
    },
}
