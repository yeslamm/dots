return {
    'mfussenegger/nvim-dap',
    dependencies = {
        'rcarriga/nvim-dap-ui',
        'nvim-neotest/nvim-nio',
        'williamboman/mason.nvim',
        'jay-babu/mason-nvim-dap.nvim',
        'theHamsta/nvim-dap-virtual-text',
    },
    config = function()
        local dap = require 'dap'
        local dapui = require 'dapui'

        dapui.setup()
        require('nvim-dap-virtual-text').setup()

        -- 1. Colors
        vim.api.nvim_set_hl(0, 'DapBreakpoint', { ctermbg = 0, fg = '#993939' })
        vim.api.nvim_set_hl(0, 'DapLogPoint', { ctermbg = 0, fg = '#61afef' })
        vim.api.nvim_set_hl(0, 'DapStopped', { ctermbg = 0, fg = '#98c379' })

        -- 2. Signs
        vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
        vim.fn.sign_define('DapBreakpointCondition', { text = 'jg', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
        vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DapLogPoint', linehl = '', numhl = '' })
        vim.fn.sign_define('DapStopped', { text = '', texthl = 'DapStopped', linehl = '', numhl = '' })
        vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DapBreakpoint', linehl = '', numhl = '' })

        -- 3. Mason
        require('mason-nvim-dap').setup {
            automatic_installation = true,
            handlers = {},
            ensure_installed = { 'debugpy' },
        }

        -- 4. Native GDB
        dap.adapters.gdb = {
            type = 'executable',
            command = 'gdb',
            args = { '--interpreter=dap', '--eval-command', 'set print pretty on' },
        }

        dap.configurations.c = {
            {
                name = 'Launch',
                type = 'gdb',
                request = 'launch',
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.expand '%:p:r', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopAtBeginningOfMainSubprogram = false,
                console = 'integratedTerminal', -- Essential for CS50 input
            },
        }

        dap.configurations.python = {
            {
                type = 'python',
                request = 'launch',
                name = 'Launch file',
                program = '${file}', -- This runs the current open file
                pythonPath = function()
                    -- Debug with the python from the current virtual environment (if active)
                    -- or fallback to system python
                    local venv_path = os.getenv 'VIRTUAL_ENV'
                    if venv_path then
                        return venv_path .. '/bin/python'
                    end
                    return '/usr/bin/python3' -- Adjust if your python is elsewhere
                end,
                console = 'integratedTerminal', -- The magic fix for input()
            },
        }

        dap.configurations.cpp = dap.configurations.c
        dap.configurations.rust = dap.configurations.c

        -- 5. Auto-Open UI
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        -- 6. Custom Keybindings (F5 - F8)

        -- F5: Start / Continue
        vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })

        -- F6: Step Over
        vim.keymap.set('n', '<F6>', dap.step_over, { desc = 'Debug: Step Over' })

        -- F7: Step Into
        vim.keymap.set('n', '<F7>', dap.step_into, { desc = 'Debug: Step Into' })

        -- F8: Step Out
        vim.keymap.set('n', '<F8>', dap.step_out, { desc = 'Debug: Step Out' })

        -- F9: Toggle Breakpoint (Standard)
        vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })

        -- Shift + F5: Terminate
        vim.keymap.set('n', '<S-F5>', dap.terminate, { desc = 'Debug: Stop' })

        -- Manual UI Toggle
        vim.keymap.set('n', '<F10>', dapui.toggle, { desc = 'Debug: Toggle UI' })
    end,
}
