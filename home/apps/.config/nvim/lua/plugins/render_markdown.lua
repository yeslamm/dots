require('render-markdown').setup {
    completions = {
        lsp = { enabled = true },
    },

    sign = { enabled = false },

    heading = {
        width = 'block',
        icons = {},
    },

    code = {
        width = 'block',
        left_pad = 2,
        right_pad = 2,
        border = 'thin',
    },

    bullet = { enabled = false },
    checkbox = { enabled = false },

    pipe_table = {
        style = 'normal',
        wrap = false,
        padding = 2,
    },

    quote = {
        repeat_linebreak = true,
    },

    latex = {
        render_modes = { 'n', 'c', 'v' },
    },
}
