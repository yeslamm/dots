require('which-key').setup {
    preset = 'helix',
    delay = 600,
    show_help = false,
    show_keys = false,
    icons = { mappings = false },
    win = {
        border = 'single',
        no_overlap = false,
    },
    plugins = {
        marks = false,
        registers = false,
    },
    keys = {
        scroll_up = '<c-p>',
        scroll_down = '<c-n>',
    },
    spec = {
        { 'gr', group = 'LSP' },
        { '<leader>g', group = 'Git', mode = { 'n', 'v' } },
        { '<leader>s', group = 'Search' },
        { '<leader>t', group = 'Tabs' },
        { '<leader>D', group = 'Debug' },
        { '<leader>l', group = 'LaTeX' },
        { '<leader>n', group = 'Notes' },
        { '<leader>m', group = 'Mdkite' },
    },
}
