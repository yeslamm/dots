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
                handlers = {}, -- This line automatically wires up the adapters for the tools below
                ensure_installed = { 'debugpy', 'codelldb', 'coreclr' },
            }

            -- 3. C, C++, and Rust Configuration (Using codelldb)
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
            dap.configurations.rust = dap.configurations.c

            -- 4. Python Configuration (Smart VENV detection)
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

            -- 5. C# Configuration
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

            -- 6. Essential Keybindings
            vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Start/Continue' })
            vim.keymap.set('n', '<S-F5>', dap.terminate, { desc = 'Stop' })
            vim.keymap.set('n', '<F6>', dap.step_over, { desc = 'Step Over' })
            vim.keymap.set('n', '<F7>', dap.step_into, { desc = 'Step Into' })
            vim.keymap.set('n', '<F8>', dap.step_out, { desc = 'Step Out' })
            vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, { desc = 'Toggle Breakpoint' })
        end,
    },

    -- 2. Virtual Text Plugin
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

    -- 3. Debug UI Plugin
    {
        'rcarriga/nvim-dap-ui',
        dependencies = {
            'mfussenegger/nvim-dap',
            'nvim-neotest/nvim-nio',
        },
        config = function()
            local dapui = require 'dapui'

            dapui.setup()

            -- Manual UI Toggle
            vim.keymap.set('n', '<F10>', dapui.toggle, { desc = 'Toggle UI' })
        end,
    },
}
