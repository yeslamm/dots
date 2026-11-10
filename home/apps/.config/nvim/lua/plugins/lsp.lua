require('mason').setup {}
require('mason-tool-installer').setup {
    ensure_installed = {
        'stylua',
        'shellcheck',
        'shfmt',
        'prettierd',
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

require('lazydev').setup()
require('fidget').setup {}

vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    underline = true,
    float = { source = true, header = '' },
    virtual_text = false,
}

-- vim.lsp.config('*', {
--     capabilities = require('blink.cmp').get_lsp_capabilities(),
-- })

vim.lsp.config('*', {
    capabilities = vim.lsp.protocol.make_client_capabilities(),
})

local hl_group = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('custom-lsp-attach', { clear = true }),
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client then
            return
        end

        -- if client:supports_method('textDocument/completion', event.buf) then
        --     vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
        -- end

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
    end,
})

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
