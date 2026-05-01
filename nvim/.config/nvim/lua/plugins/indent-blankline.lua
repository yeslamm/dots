return {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
        indent = {
            char = '▏',
        },
        scope = { enabled = false },
        exclude = {
            filetypes = {
                'help',
                'lazy',
                'mason',
                'notify',
                'toggleterm',
                'oil',
            },
        },
    },
}
