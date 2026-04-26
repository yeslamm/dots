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
    keys = {
        { '<C-`>', '<cmd>ToggleTerm<CR>', desc = 'Terminal', mode = { 'n', 'i', 't' } },
    },
}
