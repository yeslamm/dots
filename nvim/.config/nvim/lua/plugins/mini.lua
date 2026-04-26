return {
    {
        'echasnovski/mini.nvim',
        config = function()
            require('mini.ai').setup { n_lines = 500 }
            require('mini.splitjoin').setup {
                mappings = {
                    toggle = '',
                    split = '<leader>j',
                    join = '<leader>k',
                },
            }
            require('mini.surround').setup()
            require('mini.pairs').setup()
        end,
    },
}
