local loaded = false

local function init_dap()
    if loaded then
        return
    end

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

    loaded = true
end

vim.keymap.set('n', '<leader>Db', function()
    init_dap()
    require('dap').toggle_breakpoint()
end, { desc = 'Toggle Breakpoint', silent = true })

vim.keymap.set('n', '<leader>Dc', function()
    init_dap()
    require('dap').continue()
end, { desc = 'Start/Continue', silent = true })

vim.keymap.set('n', '<leader>Dx', function()
    init_dap()
    require('dap').terminate()
end, { desc = 'Terminate', silent = true })

vim.keymap.set('n', '<leader>Dr', function()
    init_dap()
    require('dap').repl.toggle(nil, 'botright 50vsplit')
end, { desc = 'Toggle REPL', silent = true })

vim.keymap.set('n', '<F10>', function()
    init_dap()
    require('dap').step_over()
end, { desc = 'Step Over', silent = true })

vim.keymap.set('n', '<F11>', function()
    init_dap()
    require('dap').step_into()
end, { desc = 'Step Into', silent = true })

vim.keymap.set('n', '<F12>', function()
    init_dap()
    require('dap').step_out()
end, { desc = 'Step Out', silent = true })
