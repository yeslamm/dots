return {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '1.*',
    opts = {
        keymap = {
            preset = 'default',
        },

        appearance = {
            use_nvim_cmp_as_default = true,
            nerd_font_variant = 'mono',
        },

        signature = {
            enabled = true,
            window = { border = 'single' },
        },

        completion = {
            menu = {
                border = 'single',
                draw = {
                    columns = {
                        { 'kind_icon' },
                        { 'label', 'label_description', gap = 1 },
                        { 'kind' },
                    },
                },
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 500,
                window = { border = 'single' },
            },
            ghost_text = {
                enabled = true,
            },
            list = {
                selection = { preselect = false, auto_insert = false },
            },
        },

        sources = {
            default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
            providers = {
                lazydev = {
                    name = 'LazyDev',
                    module = 'lazydev.integrations.blink',
                    score_offset = 100,
                    fallbacks = { 'lsp' },
                },
                buffer = {
                    min_keyword_length = 3,
                    max_items = 4,
                },
            },
        },
    },
    opts_extend = { 'sources.default' },
}
