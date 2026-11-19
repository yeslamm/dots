local ls = require 'luasnip'
local fmt = require('luasnip.extras.fmt').fmt

return {
    ls.snippet(
        'cp',
        fmt(
            [[
                #include <bits/stdc++.h>
                using namespace std;

                int main() {
                    ios::sync_with_stdio(false);
                    cin.tie(nullptr);

                    @$
                    return 0;
                }
            ]],
            {
                ls.insert_node(0),
            },
            { delimiters = '@$' }
        )
    ),
}
