-- This file configures the Language Server Protocol (LSP) ecosystem.
--
-- LSP is a protocol that allows editors to communicate with language-specific servers
-- to provide features like autocompletion, go-to-definition, diagnostics, and more.
--
-- The setup involves several plugins that work together:
--   - nvim-lspconfig: The main plugin for configuring LSP servers.
--   - mason.nvim: A package manager to install LSP servers, formatters, and linters.
--   - mason-lspconfig.nvim: A bridge between mason and nvim-lspconfig to make them work together seamlessly.
--   - mason-tool-installer.nvim: An extension to automatically install a list of specified tools with Mason.
--   - fidget.nvim: Provides a UI to show LSP status updates (e.g., "rust-analyzer is loading...").
--   - lazydev.nvim: Special LSP configuration for developing Neovim plugins in Lua.
return {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
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
            -- Mason is the package manager for LSPs, formatters, etc.
            { 'mason-org/mason.nvim', opts = {} },
            -- mason-lspconfig is the bridge between Mason and nvim-lspconfig
            'mason-org/mason-lspconfig.nvim',
            -- mason-tool-installer automatically installs tools from a list
            'WhoIsSethDaniel/mason-tool-installer.nvim',
            -- schemastore provides schemas for the JSON language server
            'b0o/schemastore.nvim',
            -- Fidget provides a nice UI for LSP progress
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
            -- This function runs when an LSP server attaches to a buffer.
            -- It's the ideal place to set buffer-local keymaps and options.
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)
                    -- A helper function to create buffer-local keymaps
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end

                    -- The `gr` prefix stands for "Go To -> LSP"
                    local builtin = require 'telescope.builtin'
                    map('grn', vim.lsp.buf.rename, 'Rename')
                    map('gra', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })
                    map('grr', builtin.lsp_references, 'References')
                    map('gri', builtin.lsp_implementations, 'Implementation')
                    map('grd', builtin.lsp_definitions, 'Definition')
                    map('grD', vim.lsp.buf.declaration, 'Declaration')
                    map('grt', builtin.lsp_type_definitions, 'Type Definition')

                    -- Fuzzy find symbols in the current document or workspace
                    map('gO', builtin.lsp_document_symbols, 'Document Symbols')
                    map('gW', builtin.lsp_dynamic_workspace_symbols, 'Workspace Symbols')

                    map('K', function()
                        vim.lsp.buf.hover { border = 'rounded' }
                    end, 'Hover')

                    -- Helper function to check if a client supports a given method
                    local function client_supports_method(client, method, bufnr)
                        if vim.fn.has 'nvim-0.11' == 1 then
                            return client:supports_method(method, bufnr)
                        else
                            return client.supports_method(method, { bufnr = bufnr })
                        end
                    end

                    -- Highlight references of the word under the cursor on CursorHold
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

                    -- Toggle inlay hints if the server supports them
                    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, 'Inlay Hints')
                    end
                end,
            })

            -- Configure how diagnostics (errors, warnings, etc.) are displayed.
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

            -- Set capabilities for nvim-cmp
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- Define the list of LSP servers to be configured
            local servers = {
                marksman = {},
                texlab = {}, -- Your LaTeX code LSP (if you plan to write .tex files)
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
                            format = { enable = false }, -- stylua handles formatting
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

            -- This list tells mason-tool-installer which tools to ensure are installed.
            -- It includes LSP servers, formatters, and linters.
            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                'stylua', -- Formatter
                'shellcheck', -- Linter
                'shfmt', -- Formatter
                'prettier', -- Formatter
                'ruff', -- Formatter/Linter (Python)
                'basedpyright', -- LSP (Python)
                'stylelint',
                'clang-format',
                'netcoredbg', -- C# Debugger
                'csharpier', -- C# Formatter (Optional but recommended)
            })
            require('mason-tool-installer').setup { ensure_installed = ensure_installed }

            -- This block configures nvim-lspconfig to use the tools installed by Mason.
            require('mason-lspconfig').setup {
                ensure_installed = {}, -- This is set to empty because mason-tool-installer handles installation
                automatic_installation = false,
                -- Handlers allow for custom per-server configuration
                handlers = {
                    -- Custom handler for basedpyright (Python)
                    ['basedpyright'] = function()
                        require('lspconfig').basedpyright.setup {
                            on_attach = function(client, bufnr)
                                -- Disable basedpyright's formatting to delegate it to a dedicated formatter like Ruff
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
                    -- Custom handler for ruff_lsp (Python)
                    ['ruff'] = function()
                        require('lspconfig').ruff_lsp.setup {
                            on_attach = function(client, bufnr)
                                -- Disable ruff's hover provider to use basedpyright's richer hover info
                                client.server_capabilities.hoverProvider = false
                            end,
                        }
                    end,

                    -- Fallback handler for all other servers to apply default settings
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
