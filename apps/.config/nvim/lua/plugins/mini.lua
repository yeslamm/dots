require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons()

require('mini.ai').setup { n_lines = 500 }

require('mini.splitjoin').setup {
    mappings = {
        toggle = '',
        split = '<leader>j',
        join = '<leader>k',
    },
}

require('mini.surround').setup {
    -- Default mappings:
    -- sa = add surround (e.g., saiw" to surround word with quotes)
    -- sd = delete surround (e.g., sd" to delete surrounding quotes)
    -- sr = replace surround (e.g., sr"' to replace quotes with single quotes)
    -- sf / sF = find next/previous surrounding
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

require('mini.indentscope').setup {
    symbol = '│',
    draw = {
        animation = require('mini.indentscope').gen_animation.none(),
    },
}

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'help', 'lazy', 'mason', 'notify', 'toggleterm', 'oil', 'markdown', 'quarto', 'rmd' },
    callback = function()
        vim.b.miniindentscope_disable = true
    end,
})
