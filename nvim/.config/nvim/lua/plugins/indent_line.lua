return {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
        indent = {
            -- char = '╎',
            -- char = '▏',
            char = '│',
        },
        scope = { enabled = false },
        -- scope = {
        --     show_start = true,
        --     show_end = false,
        --     show_exact_scope = true,
        -- },
        exclude = {
            filetypes = {
                'help',
                'startify',
                'dashboard',
                'packer',
                'neogitstatus',
                'NvimTree',
                'Trouble',
            },
        },
    },
}
