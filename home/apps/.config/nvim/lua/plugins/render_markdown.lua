require('render-markdown').setup {
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
}
