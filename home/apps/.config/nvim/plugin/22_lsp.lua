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

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, blink = pcall(require, 'blink.cmp')
if ok then
    capabilities = blink.get_lsp_capabilities(capabilities)
end

vim.lsp.config('*', {
    capabilities = capabilities,
})

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('custom-lsp-attach', { clear = true }),
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client then
            return
        end

        if client:supports_method('textDocument/documentHighlight', event.buf) then
            local hl_group = vim.api.nvim_create_augroup('lsp-highlight-' .. event.buf, { clear = true })

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
                group = hl_group,
                callback = function()
                    vim.lsp.buf.clear_references()
                    pcall(vim.api.nvim_del_augroup_by_id, hl_group)
                end,
            })
        end
    end,
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
