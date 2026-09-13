local pack_root = vim.fn.stdpath 'data' .. '/site/pack/core/opt/nvim-treesitter/runtime'
if vim.uv.fs_stat(pack_root) then
    vim.opt.rtp:prepend(pack_root)
end

require('nvim-treesitter').setup()
require('nvim-treesitter').install {
    'bash',
    'c',
    'diff',
    'html',
    'lua',
    'luadoc',
    'markdown',
    'markdown_inline',
    'python',
    'query',
    'vim',
    'vimdoc',
    'toml',
}

local ts_group = vim.api.nvim_create_augroup('NvimTreesitterConfig', { clear = true })

local ignored_filetypes = {
    tmux = true,
}

vim.api.nvim_create_autocmd('FileType', {
    group = ts_group,
    callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype

        if ignored_filetypes[ft] or ft == '' then
            return
        end

        local lang = vim.treesitter.language.get_lang(ft) or ft

        local has_parser = pcall(vim.treesitter.get_parser, buf, lang)
        if not has_parser then
            return
        end

        local ok = pcall(vim.treesitter.start, buf, lang)
        if ok then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            vim.opt_local.foldmethod = 'expr'
            vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        end
    end,
})
