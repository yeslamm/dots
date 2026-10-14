vim.g.rustaceanvim = {
    server = {
        on_attach = function()
            vim.keymap.set('n', '<leader>ra', function()
                vim.cmd.RustLsp 'codeAction'
            end, { desc = 'Rust Code Action', buffer = 0 })

            vim.keymap.set('n', '<leader>rr', function()
                vim.cmd.RustLsp 'renderDiagnostic'
            end, { desc = 'Render Full Rust Error', buffer = 0 })
        end,
        default_settings = {
            ['rust-analyzer'] = {
                checkOnSave = true,
                check = {
                    command = 'clippy',
                },
                inlayHints = {
                    bindingModeHints = { enable = true },
                    parameterHints = { enable = true },
                    typeHints = { enable = true },
                },
            },
        },
    },
}
