local ts = vim.iter(vim.pack.get()):find(function(p)
    return p.spec.name == 'nvim-treesitter'
end)
if ts and ts.path then
    vim.opt.rtp:prepend(vim.fs.joinpath(ts.path, 'runtime'))
end

require('nvim-treesitter').install {
    'bash',
    'c',
    'cpp',
    'diff',
    'html',
    'ini',
    'lua',
    'luadoc',
    'markdown',
    'markdown_inline',
    'python',
    'query',
    'toml',
    'vim',
    'vimdoc',
    'yaml',
}

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('TreesitterConfig', { clear = true }),
    callback = function(args)
        local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(args.buf))
        if stat and stat.size > 100 * 1024 then
            return
        end

        if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})
