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
        'tex-fmt',
        'lua-language-server',
        'json-lsp',
        'basedpyright',
        'ruff',
    },
}

-- 2. Companion Plugins & Diagnostics
require('lazydev').setup()
require('fidget').setup {}

vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    underline = true,
    float = { border = 'single', source = true, header = '' },
    virtual_text = { spacing = 2, prefix = '●' },
    signs = { text = { '● ', '● ', '● ', '● ' } },
}

vim.lsp.config('*', {
    capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- 3. LSP Buffer Attach (Keymaps & Highlights)
local hl_group = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('custom-lsp-attach', { clear = true }),
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client then
            return
        end

        vim.keymap.set('n', 'K', function()
            vim.lsp.buf.hover { border = 'single' }
        end, { buffer = event.buf, desc = 'LSP: Hover' })

        vim.keymap.set('n', 'grt', vim.lsp.buf.type_definition, { buffer = event.buf, desc = 'LSP: Type Definition' })
        vim.keymap.set('n', 'grw', vim.lsp.buf.workspace_symbol, { buffer = event.buf, desc = 'LSP: Workspace Symbols' })

        if client:supports_method('textDocument/documentHighlight', event.buf) then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                group = hl_group,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'LspDetach' }, {
                buffer = event.buf,
                group = hl_group,
                callback = vim.lsp.buf.clear_references,
            })
        end

        if client:supports_method('textDocument/inlayHint', event.buf) then
            vim.keymap.set('n', '<leader>h', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf })
            end, { buffer = event.buf, desc = 'LSP: Toggle Inlay Hints' })
        end
    end,
})

-- 4. Server Configurations
vim.lsp.config('clangd', { cmd = { 'clangd', '--offset-encoding=utf-16' } })
vim.lsp.config('basedpyright', { settings = { basedpyright = { analysis = { diagnosticMode = 'openFilesOnly' } } } })
vim.lsp.config('ruff', {
    on_attach = function(client)
        client.server_capabilities.hoverProvider = false
    end,
})
vim.lsp.config('jsonls', {
    settings = { json = { schemas = require('schemastore').json.schemas(), validate = { enable = true } } },
})

vim.lsp.enable {
    'marksman',
    'bashls',
    'taplo',
    'cssls',
    'texlab',
    'lua_ls',
    'clangd',
    'jsonls',
    'basedpyright',
    'ruff',
}
