return {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '1.*', -- Ensures you get the stable V1 release
    opts = {
        keymap = { preset = 'super-tab' },
        appearance = { nerd_font_variant = 'mono' },
        completion = { documentation = { auto_show = false } },
        sources = {
            default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
            providers = {
                lazydev = {
                    name = 'LazyDev',
                    module = 'lazydev.integrations.blink',
                    -- Make lazydev completions top priority (score_offset = 100)
                    score_offset = 100,
                },
            },
        },

        cmdline = {
            enabled = true,
            keymap = { preset = 'super-tab' }, -- Gives you standard cmdline keymaps (like <Tab> to cycle)
            sources = function()
                local type = vim.fn.getcmdtype()
                -- Search forward and backward
                if type == '/' or type == '?' then
                    return { 'buffer' }
                end
                -- Commands
                if type == ':' then
                    return { 'cmdline', 'path' }
                end
                return {}
            end,
            completion = {
                menu = { auto_show = true }, -- Automatically show the menu when typing
            },
        },

        fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
}
