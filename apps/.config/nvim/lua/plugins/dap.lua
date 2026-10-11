local dap = require 'dap'

vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#993939' })
vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' })
vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379' })

local signs = {
    DapBreakpoint = { text = '', texthl = 'DapBreakpoint' },
    DapBreakpointCondition = { text = '', texthl = 'DapBreakpoint' },
    DapLogPoint = { text = '', texthl = 'DapLogPoint' },
    DapStopped = { text = '', texthl = 'DapStopped' },
    DapBreakpointRejected = { text = '', texthl = 'DapBreakpoint' },
}
for name, sign in pairs(signs) do
    vim.fn.sign_define(name, sign)
end

require('mason-nvim-dap').setup {
    automatic_installation = true,
    ensure_installed = { 'debugpy', 'codelldb', 'coreclr' },
}

require('nvim-dap-virtual-text').setup {}

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
            local venv = os.getenv 'VIRTUAL_ENV'
            return venv and (venv .. '/bin/python') or '/usr/bin/python3'
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

local map = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { desc = 'DAP: ' .. desc, silent = true })
end

map('<leader>Db', dap.toggle_breakpoint, 'Toggle Breakpoint')
map('<leader>Dc', dap.continue, 'Start/Continue')
map('<leader>Dx', dap.terminate, 'Terminate')
map('<leader>Dr', function()
    dap.repl.toggle(nil, 'botright 50vsplit')
end, 'Toggle REPL')

map('<F10>', dap.step_over, 'Step Over')
map('<F11>', dap.step_into, 'Step Into')
map('<F12>', dap.step_out, 'Step Out')
