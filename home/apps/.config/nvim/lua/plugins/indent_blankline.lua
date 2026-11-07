require('ibl').setup {
    indent = { char = '▏' },
    scope = { enabled = false },
    exclude = {
        filetypes = { 'help', 'mason', 'notify', 'oil', 'markdown', 'quarto', 'rmd' },
    },
}
