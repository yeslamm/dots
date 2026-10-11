-- 1. Mason & Tool Management
require('mason').setup { ui = { border = 'single' } }

require('mason-tool-installer').setup {
    ensure_installed = {
        'stylua',
        'shellcheck',
        'shfmt',
        'prettier',
        'clang-format',
        'roslyn-language-server',
        'marksman',
        'bash-language-server',
        'taplo',
        'css-lsp',
        'clangd',
        'texlab',
        'lua-language-server',
        'json-lsp',
        'basedpyright',
        'ruff',
    },
}

-- 2. Companion Plugins
require('lazydev').setup()
require('fidget').setup {}

-- 3. Diagnostics Display
vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    underline = true,
    float = { border = 'single', source = true, header = '' },
    virtual_text = { spacing = 2, prefix = '●' },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '● ',
            [vim.diagnostic.severity.WARN] = '● ',
            [vim.diagnostic.severity.INFO] = '● ',
            [vim.diagnostic.severity.HINT] = '● ',
        },
    },
}

-- 4. LSP Buffer Attach
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('custom-lsp-attach', { clear = true }),
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client then
            return
        end

        local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('K', function()
            vim.lsp.buf.hover { border = 'single' }
        end, 'Hover')

        map('grt', vim.lsp.buf.type_definition, 'Type Definition')
        map('grw', vim.lsp.buf.workspace_symbol, 'Workspace Symbols')

        -- Highlight word references on cursor hold
        if client:supports_method('textDocument/documentHighlight', event.buf) then
            local hl_group = vim.api.nvim_create_augroup('custom-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                group = hl_group,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                group = hl_group,
                callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
                buffer = event.buf,
                callback = function()
                    vim.lsp.buf.clear_references()
                end,
            })
        end

        -- Inlay hints toggle
        if client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>h', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf })
            end, 'Toggle Inlay Hints')
        end
    end,
})

-- 5. Capabilities & Global Defaults
vim.lsp.config('*', {
    capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- 6. Server Configurations
local servers = {
    marksman = {},
    bashls = {},
    taplo = {},
    cssls = {},
    texlab = {},
    lua_ls = {},
    clangd = { cmd = { 'clangd', '--offset-encoding=utf-16' } },
    jsonls = {
        on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require('schemastore').json.schemas())
        end,
    },
    basedpyright = {
        settings = { basedpyright = { analysis = { diagnosticMode = 'openFilesOnly' } } },
    },
    ruff = {
        on_attach = function(client)
            client.server_capabilities.hoverProvider = false
        end,
    },
}

for name, config in pairs(servers) do
    vim.lsp.config(name, config)
    vim.lsp.enable(name)
end
