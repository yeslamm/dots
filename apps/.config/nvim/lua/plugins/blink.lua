local function color_item(ctx)
    local colors = package.loaded['nvim-highlight-colors']
    return colors and colors.format(ctx.item.documentation, { kind = ctx.kind })
end

require('blink.cmp').setup {
    appearance = { use_nvim_cmp_as_default = true },
    signature = { enabled = true, window = { border = 'single' } },

    completion = {
        menu = {
            border = 'single',
            draw = {
                columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 }, { 'kind' } },
                components = {
                    kind_icon = {
                        text = function(ctx)
                            local c = color_item(ctx)
                            return (c and c.abbr ~= '' and c.abbr or ctx.kind_icon) .. ctx.icon_gap
                        end,
                        highlight = function(ctx)
                            local c = color_item(ctx)
                            return (c and c.abbr_hl_group) or ('BlinkCmpKind' .. ctx.kind)
                        end,
                    },
                },
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
