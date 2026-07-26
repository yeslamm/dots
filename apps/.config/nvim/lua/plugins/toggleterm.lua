return {
    'akinsho/toggleterm.nvim',
    version = '*',
    keys = {
        { '<A-i>', '<cmd>ToggleTerm<CR>', desc = 'Terminal', mode = { 'n', 'i', 't' } },
        {
            '<leader>gl',
            function()
                local Terminal = require('toggleterm.terminal').Terminal
                local lazygit = Terminal:new {
                    cmd = 'lazygit',
                    dir = 'git_dir',
                    direction = 'float',
                    float_opts = { border = 'single' },
                    on_close = function(_)
                        vim.cmd 'startinsert!'
                    end,
                }
                lazygit:toggle()
            end,
            desc = 'Lazygit',
        },
    },
    opts = {
        start_in_insert = true,
        terminal_mappings = true,
        insert_mappings = false,
        persist_size = false,
        close_on_exit = true,
        autochdir = false,
        direction = 'float',
        shade_terminals = true,
        hide_numbers = true,
        float_opts = {
            border = 'single',
            winblend = 0,
        },
    },
    config = function(_, opts)
        require('toggleterm').setup(opts)
    end,
}
