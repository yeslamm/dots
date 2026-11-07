require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons()

require('mini.ai').setup { n_lines = 500 }
require('mini.surround').setup()
require('mini.move').setup()

require('mini.splitjoin').setup {
    mappings = {
        toggle = '',
        split = '<leader>j',
        join = '<leader>k',
    },
}

require('mini.indentscope').setup {
    symbol = '│',
    draw = {
        animation = require('mini.indentscope').gen_animation.none(),
    },
}

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'help', 'mason', 'notify', 'oil', 'markdown', 'quarto', 'rmd' },
    callback = function()
        vim.b.miniindentscope_disable = true
    end,
})
