require('ibl').setup {
    indent = {
        char = '▏',
    },
    scope = { enabled = true },
    exclude = {
        filetypes = {
            'help',
            'lazy',
            'mason',
            'notify',
            'toggleterm',
            'oil',
            'markdown',
            'quarto',
            'rmd',
        },
    },
}
