return {
    {
        'williamboman/mason.nvim',
        opts = {
            ui = {
                border = 'single',
                backdrop = 100,
            },
        },
    },

    {
        'zapling/mason-conform.nvim',
        dependencies = { 'williamboman/mason.nvim' },
        config = function()
            require('mason-conform').setup {}
        end,
    },
}
