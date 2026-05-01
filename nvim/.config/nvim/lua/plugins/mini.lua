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
            require('mini.indentscope').setup {
                symbol = '│',
                draw = {
                    animation = require('mini.indentscope').gen_animation.none(),
                },
            }
            vim.api.nvim_create_autocmd('FileType', {
                pattern = { 'help', 'lazy', 'mason', 'notify', 'toggleterm', 'oil' },
                callback = function()
                    vim.b.miniindentscope_disable = true
                end,
            })
        end,
    },
}
