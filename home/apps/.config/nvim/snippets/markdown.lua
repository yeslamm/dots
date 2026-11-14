local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    s({ trig = 'mk', name = 'Inline math' }, {
        t '$',
        i(1),
        t '$',
    }),
    s({ trig = 'dm', name = 'Display math' }, {
        t { '$$', '' },
        i(1),
        t { '', '$$' },
    }),
    s({ trig = 'bf', name = 'Bold' }, {
        t '**',
        i(1),
        t '**',
    }),
    s({ trig = 'it', name = 'Italic' }, {
        t '*',
        i(1),
        t '*',
    }),
    s({ trig = 'st', name = 'Strikethrough' }, {
        t '~~',
        i(1),
        t '~~',
    }),
}
