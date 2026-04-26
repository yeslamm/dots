return {
    {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            },
        },
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'saghen/blink.cmp',
            { 'mason-org/mason.nvim', opts = {} },
            'mason-org/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',
            'b0o/schemastore.nvim',
            {
                'j-hui/fidget.nvim',
                opts = {
                    notification = {
                        window = {
                            avoid = { 'NvimTree' },
                        },
                    },
                },
            },
        },
        config = function()
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end

                    -- Replace Telescope with fzf-lua
                    local fzf = require 'fzf-lua'

                    map('grn', vim.lsp.buf.rename, 'Rename')
                    map('gra', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })
                    map('grr', fzf.lsp_references, 'References')
                    map('gri', fzf.lsp_implementations, 'Implementation')
                    map('grd', fzf.lsp_definitions, 'Definition')
                    map('grD', vim.lsp.buf.declaration, 'Declaration')
                    map('grt', fzf.lsp_typedefs, 'Type Definition') -- note: different function name
                    map('gO', fzf.lsp_document_symbols, 'Document Symbols')
                    map('gW', fzf.lsp_live_workspace_symbols, 'Workspace Symbols')

                    map('K', function()
                        vim.lsp.buf.hover { border = 'single' }
                    end, 'Hover')

                    local function client_supports_method(client, method, bufnr)
                        if vim.fn.has 'nvim-0.11' == 1 then
                            return client:supports_method(method, bufnr)
                        else
                            return client.supports_method(method, { bufnr = bufnr })
                        end
                    end

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
                        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })
                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })
                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                            end,
                        })
                    end

                    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                        map('<leader>h', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, 'Inlay Hints')
                    end
                end,
            })

            vim.diagnostic.config {
                severity_sort = true,
                float = { border = 'rounded', source = 'if_many' },
                signs = vim.g.have_nerd_font and {
                    text = {
                        [vim.diagnostic.severity.ERROR] = ' ',
                        [vim.diagnostic.severity.WARN] = ' ',
                        [vim.diagnostic.severity.INFO] = ' ',
                        [vim.diagnostic.severity.HINT] = ' ',
                    },
                } or {},
                virtual_text = {
                    prefix = '',
                    spacing = 0,
                    source = false,
                },
                underline = false,
            }

            local capabilities = require('blink.cmp').get_lsp_capabilities()

            local servers = {
                marksman = {},
                texlab = {},
                clangd = {},
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
                    settings = {
                        json = {
                            format = { enable = false },
                            validate = { enable = true },
                        },
                    },
                },
                omnisharp = {
                    cmd = { 'omnisharp' },
                    settings = {
                        FormattingOptions = {
                            EnableEditorConfigSupport = true,
                            OrganizeImports = true,
                        },
                        RoslynExtensionsOptions = {
                            EnableAnalyzersSupport = true,
                            EnableImportCompletion = true,
                        },
                    },
                },
            }

            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                'stylua',
                'shellcheck',
                'shfmt',
                'prettier',
                'ruff',
                'basedpyright',
                'stylelint',
                'clang-format',
                'netcoredbg',
                'csharpier',
            })
            require('mason-tool-installer').setup { ensure_installed = ensure_installed }

            require('mason-lspconfig').setup {
                ensure_installed = {},
                automatic_installation = false,
                handlers = {
                    ['basedpyright'] = function()
                        require('lspconfig').basedpyright.setup {
                            on_attach = function(client)
                                client.server_capabilities.documentFormattingProvider = false
                                client.server_capabilities.documentRangeFormattingProvider = false
                            end,
                            settings = {
                                basedpyright = {
                                    analysis = {
                                        diagnosticMode = 'openFilesOnly',
                                    },
                                },
                            },
                        }
                    end,
                    ['ruff'] = function()
                        require('lspconfig').ruff_lsp.setup {
                            on_attach = function(client)
                                client.server_capabilities.hoverProvider = false
                            end,
                        }
                    end,

                    ['_'] = function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                        require('lspconfig')[server_name].setup(server)
                    end,
                },
            }
        end,
    },
}
