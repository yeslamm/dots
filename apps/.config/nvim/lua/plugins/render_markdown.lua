return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    ft = { 'markdown', 'quarto', 'rmd', 'Avante' },
    opts = {
        completions = {
            lsp = { enabled = true },
        },
        heading = {
            width = 'block',
        },
        code = {
            width = 'block',
            left_pad = 2,
            right_pad = 2,
            border = 'thick',
        },
        anti_conceal = {
            enabled = true,
        },
    },
}
