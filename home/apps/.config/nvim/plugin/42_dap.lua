local dap_loaded = false

local function get_dap()
    local dap = require 'dap'
    if dap_loaded then
        return dap
    end
    dap_loaded = true

    vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#993939' })
    vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' })
    vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379' })

    local signs = {
        DapBreakpoint = { text = '', texthl = 'DapBreakpoint' },
        DapBreakpointCondition = { text = '', texthl = 'DapBreakpoint' },
        DapBreakpointRejected = { text = '', texthl = 'DapBreakpoint' },
        DapLogPoint = { text = '', texthl = 'DapLogPoint' },
        DapStopped = { text = '', texthl = 'DapStopped' },
    }
    for name, sign_opts in pairs(signs) do
        vim.fn.sign_define(name, sign_opts)
    end

    require('mason-nvim-dap').setup {
        automatic_installation = true,
        ensure_installed = { 'debugpy', 'codelldb', 'coreclr' },
        handlers = {},
    }
    require('nvim-dap-virtual-text').setup {}

    local file_prompt = function(prompt, default)
        return function()
            local path = vim.fn.input {
                prompt = prompt,
                default = vim.fn.getcwd() .. default,
                completion = 'file',
            }
            return (path and path ~= '') and path or dap.ABORT
        end
    end

    dap.configurations.c = {
        {
            name = 'Launch C/C++ executable',
            type = 'codelldb',
            request = 'launch',
            program = file_prompt('Path to executable: ', '/'),
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
                return vim.env.VIRTUAL_ENV and (vim.env.VIRTUAL_ENV .. '/bin/python') or '/usr/bin/python3'
            end,
            console = 'integratedTerminal',
        },
    }

    dap.configurations.cs = {
        {
            type = 'coreclr',
            name = 'Launch C# project',
            request = 'launch',
            program = file_prompt('Path to dll: ', '/bin/Debug/'),
            cwd = '${workspaceFolder}',
        },
    }

    vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'DAP: Step Over', silent = true })
    vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'DAP: Step Into', silent = true })
    vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'DAP: Step Out', silent = true })

    return dap
end

local function map(keys, fn, desc)
    vim.keymap.set('n', keys, fn, { desc = 'DAP: ' .. desc, silent = true })
end

map('<leader>Db', function()
    get_dap().toggle_breakpoint()
end, 'Toggle Breakpoint')
map('<leader>Dc', function()
    get_dap().continue()
end, 'Start/Continue')
map('<leader>Dx', function()
    get_dap().terminate()
end, 'Terminate')
map('<leader>Dr', function()
    get_dap().repl.toggle(nil, 'botright 50vsplit')
end, 'Toggle REPL')
