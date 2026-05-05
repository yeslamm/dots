return {
    {
        'echasnovski/mini.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        config = function()
            require('mini.ai').setup { n_lines = 500 }
            require('mini.splitjoin').setup {
                mappings = {
                    toggle = '',
                    split = '<leader>j',
                    join = '<leader>k',
                },
            }
            require('mini.move').setup {
                mappings = {
                    left = '<A-h>',
                    right = '<A-l>',
                    down = '<A-j>',
                    up = '<A-k>',
                    line_left = '<A-h>',
                    line_right = '<A-l>',
                    line_down = '<A-j>',
                    line_up = '<A-k>',
                },
            }
            require('mini.surround').setup {
                mappings = {
                    add = 'ys', -- Add surrounding in Normal and Visual modes
                    delete = 'ds', -- Delete surrounding
                    replace = 'cs', -- Replace surrounding
                    find = '', -- Disable or remap to avoid conflicts
                    find_left = '',
                    highlight = '',
                    update_n_lines = '',
                },
            }
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
