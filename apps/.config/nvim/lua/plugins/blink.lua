require('blink.cmp').setup {
    keymap = {
        preset = 'default',
    },

    appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
    },

    signature = {
        enabled = true,
        window = {
            border = 'single',
            show_documentation = true,
        },
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
                components = {
                    kind_icon = {
                        text = function(ctx)
                            local icon = ctx.kind_icon
                            if ctx.item.source_name == 'LSP' then
                                local color_item = require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                                if color_item and color_item.abbr ~= '' then
                                    icon = color_item.abbr
                                end
                            end
                            return icon .. ctx.icon_gap
                        end,
                        highlight = function(ctx)
                            local highlight = 'BlinkCmpKind' .. ctx.kind
                            if ctx.item.source_name == 'LSP' then
                                local color_item = require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                                if color_item and color_item.abbr_hl_group then
                                    highlight = color_item.abbr_hl_group
                                end
                            end
                            return highlight
                        end,
                    },
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
}
