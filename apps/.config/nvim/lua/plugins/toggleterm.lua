return {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {
        size = 30,
        shade_terminals = false,
        autochdir = false,
        direction = 'float',
        insert_mappings = false,
        persist_size = false,
        float_opts = {
            width = 155,
            height = 40,
            border = 'single',
        },
    },
    config = function(_, opts)
        require('toggleterm').setup(opts)

        local Terminal = require('toggleterm.terminal').Terminal

        -- CODE RUNNER FUNCTION
        local function _run_code()
            local ft = vim.bo.filetype
            local filename = vim.fn.expand '%'
            local filename_root = vim.fn.expand '%:r'
            local dir = vim.fn.expand '%:p:h'

            local commands = {
                python = 'python3 ' .. filename,
                javascript = 'node ' .. filename,
                lua = 'lua ' .. filename,
                c = 'cd ' .. dir .. ' && clang -Wall -Wextra -Werror -std=c11 ' .. filename .. ' -o ' .. filename_root .. ' -lcs50 && ./' .. filename_root,
                cpp = 'cd ' .. dir .. ' && clang++ -Wall -Wextra -Werror -std=c++17 ' .. filename .. ' -o ' .. filename_root .. ' && ./' .. filename_root,
                sh = 'bash ' .. filename,
            }

            local cmd = commands[ft]
            if cmd then
                Terminal:new({
                    cmd = cmd,
                    close_on_exit = false,
                    direction = 'float',
                }):toggle()
            else
                -- Fallback: use Code Runner plugin for other languages
                vim.cmd 'RunCode'
                -- If your Code Runner plugin exposes a Lua API, you could do:
                -- require('code_runner').run()  -- adjust to your plugin
            end
        end

        -- LAZYGIT FUNCTION
        local function _lazygit_toggle()
            local lazygit_term = Terminal:new {
                cmd = 'lazygit',
                dir = vim.fn.getcwd(),
                direction = 'float',
            }
            lazygit_term:toggle()
        end

        -- KEYMAPS
        vim.keymap.set('n', '<leader>r', _run_code, { noremap = true, silent = true, desc = 'Run_Code' })
        vim.keymap.set('n', '<leader>gg', _lazygit_toggle, { noremap = true, silent = true, desc = 'Open Lazygit (Toggleterm)' })
        vim.keymap.set({ 'n', 'i', 't' }, '<A-`>', '<cmd>ToggleTerm<CR>', { desc = 'Toggle Terminal' })
    end,
}
