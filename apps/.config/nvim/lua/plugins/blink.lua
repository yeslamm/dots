require('blink.cmp').setup {
    appearance = { use_nvim_cmp_as_default = true },
    signature = { enabled = true, window = { border = 'single' } },

    completion = {
        menu = {
            draw = {
                columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 }, { 'kind' } },
            },
        },
        documentation = { auto_show = true, window = { border = 'single' } },
        ghost_text = { enabled = true },
        list = { selection = { preselect = false, auto_insert = false } },
    },

    sources = {
        default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
            lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
            buffer = { min_keyword_length = 3, max_items = 4 },
        },
    },
}
