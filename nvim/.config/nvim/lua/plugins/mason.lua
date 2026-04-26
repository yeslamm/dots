return {
    {
        'williamboman/mason.nvim',
        opts = {
            ui = {
                border = 'single',
            },
        },
    },

    {
        'zapling/mason-conform.nvim',
        -- It's often a good idea to explicitly state dependencies
        dependencies = { 'williamboman/mason.nvim' },
        config = function()
            require('mason-conform').setup {}
        end,
    },
}
