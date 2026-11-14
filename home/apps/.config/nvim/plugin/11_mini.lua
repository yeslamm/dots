local MiniIcons = require 'mini.icons'
MiniIcons.setup()
MiniIcons.mock_nvim_web_devicons()

require('mini.statusline').setup()

require('mini.indentscope').setup {
    symbol = '│',
    draw = {
        delay = 0,
        animation = require('mini.indentscope').gen_animation.none(),
    },
    options = {
        try_as_border = true,
    },
}

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'help', 'mason', 'markdown', 'oil', 'quarto', 'rmd' },
    callback = function()
        vim.b.miniindentscope_disable = true
    end,
})

require('mini.pairs').setup()

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
