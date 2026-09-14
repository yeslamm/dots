local pack_root = vim.fn.stdpath 'data' .. '/site/pack/core/opt/nvim-treesitter/runtime'
if vim.uv.fs_stat(pack_root) then
    vim.opt.rtp:prepend(pack_root)
end

require('nvim-treesitter').setup()

local parsers = {
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

vim.api.nvim_create_user_command('TSInstallCore', function()
    require('nvim-treesitter').install(parsers)
end, { desc = 'Install all core Tree-sitter parsers' })

local ts_group = vim.api.nvim_create_augroup('NvimTreesitterConfig', { clear = true })
local ignored_filetypes = { tmux = true }
local max_filesize = 100 * 1024

vim.api.nvim_create_autocmd('FileType', {
    group = ts_group,
    callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype

        if ignored_filetypes[ft] or ft == '' then
            return
        end

        local ok_stat, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok_stat and stats and stats.size > max_filesize then
            return
        end

        local lang = vim.treesitter.language.get_lang(ft) or ft

        local ok = pcall(vim.treesitter.start, buf, lang)
        if ok then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            vim.wo[0][0].foldmethod = 'expr'
            vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        end
    end,
})
