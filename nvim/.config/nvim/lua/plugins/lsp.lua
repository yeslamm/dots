return {
    {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } },
        },
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'saghen/blink.cmp',
            { 'williamboman/mason.nvim', opts = { ui = { border = 'single' } } },
            'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',
            'b0o/schemastore.nvim',
            { 'j-hui/fidget.nvim', opts = { notification = { window = { avoid = { 'NvimTree' } } } } },
        },
        config = function()
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('custom-lsp-attach', { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end

                    map('grn', vim.lsp.buf.rename, 'Rename')
                    map('gra', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })
                    map('grr', vim.lsp.buf.references, 'References')
                    map('gri', vim.lsp.buf.implementation, 'Implementation')
                    map('grd', vim.lsp.buf.definition, 'Definition')
                    map('grD', vim.lsp.buf.declaration, 'Declaration')
                    map('grt', vim.lsp.buf.type_definition, 'Type Definition')
                    map('gO', vim.lsp.buf.document_symbol, 'Document Symbols')
                    map('gW', vim.lsp.buf.workspace_symbol, 'Workspace Symbols')
                    map('K', function()
                        vim.lsp.buf.hover { border = 'single' }
                    end, 'Hover')

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if not client then
                        return
                    end

                    local function client_supports_method(c, method, bufnr)
                        if vim.fn.has 'nvim-0.11' == 1 then
                            return c:supports_method(method, { bufnr = bufnr })
                        else
                            return c.supports_method(method, { bufnr = bufnr })
                        end
                    end

                    if client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
                        local highlight_group = vim.api.nvim_create_augroup('custom-lsp-highlight', { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_group,
                            callback = vim.lsp.buf.document_highlight,
                        })
                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_group,
                            callback = vim.lsp.buf.clear_references,
                        })
                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('custom-lsp-detach', { clear = true }),
                            callback = function(e)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'custom-lsp-highlight', buffer = e.buf }
                            end,
                        })
                    end

                    if client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                        map('<leader>h', function()
                            local filter = { bufnr = event.buf }
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
                        end, 'Toggle Inlay Hints')
                    end
                end,
            })

            vim.diagnostic.config {
                update_in_insert = false,
                severity_sort = true,
                underline = true,
                float = { border = 'single', source = true, header = '' },
                virtual_text = {
                    spacing = 2,
                    source = false,
                    prefix = vim.g.have_nerd_font and '●' or '■',
                },
                signs = vim.g.have_nerd_font and {
                    text = {
                        [vim.diagnostic.severity.ERROR] = '● ',
                        [vim.diagnostic.severity.WARN] = '● ',
                        [vim.diagnostic.severity.INFO] = '● ',
                        [vim.diagnostic.severity.HINT] = '● ',
                    },
                } or {},
            }

            local servers = {
                marksman = {},
                texlab = {},
                clangd = {
                    cmd = { 'clangd', '--offset-encoding=utf-16' },
                },
                bashls = {},
                taplo = {},
                cssls = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            runtime = { version = 'LuaJIT' },
                            diagnostics = { globals = { 'vim' } },
                            workspace = { checkThirdParty = false },
                            format = { enable = false },
                        },
                    },
                },
                jsonls = {
                    on_new_config = function(new_config)
                        new_config.settings.json.schemas = new_config.settings.json.schemas or {}
                        vim.list_extend(new_config.settings.json.schemas, require('schemastore').json.schemas())
                    end,
                    settings = { json = { format = { enable = false }, validate = { enable = true } } },
                },
                omnisharp = {
                    cmd = { 'omnisharp' },
                    settings = {
                        FormattingOptions = { EnableEditorConfigSupport = true, OrganizeImports = true },
                        RoslynExtensionsOptions = { EnableAnalyzersSupport = true, EnableImportCompletion = true },
                    },
                },
                basedpyright = {},
                ruff = {},
            }

            local ensure_installed = vim.tbl_keys(servers)
            vim.list_extend(ensure_installed, {
                'stylua',
                'shellcheck',
                'shfmt',
                'prettier',
                'stylelint',
                'clang-format',
                'csharpier',
            })
            require('mason-tool-installer').setup { ensure_installed = ensure_installed }

            local capabilities = require('blink.cmp').get_lsp_capabilities()

            require('mason-lspconfig').setup {
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                        require('lspconfig')[server_name].setup(server)
                    end,
                    ['basedpyright'] = function()
                        require('lspconfig').basedpyright.setup {
                            capabilities = capabilities,
                            on_attach = function(client)
                                client.server_capabilities.documentFormattingProvider = false
                                client.server_capabilities.documentRangeFormattingProvider = false
                            end,
                            settings = { basedpyright = { analysis = { diagnosticMode = 'openFilesOnly' } } },
                        }
                    end,
                    ['ruff'] = function()
                        require('lspconfig').ruff.setup {
                            capabilities = capabilities,
                            on_attach = function(client)
                                client.server_capabilities.hoverProvider = false
                            end,
                        }
                    end,
                },
            }
        end,
    },
}
