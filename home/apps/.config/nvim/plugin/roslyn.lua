require('roslyn').setup {
    broad_search = true,
    config = {
        settings = {
            ['csharp|code_lens'] = {
                dotnet_enable_references_code_lens = true,
            },
        },
    },
}
