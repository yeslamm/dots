local ts_pkg = vim.iter(vim.pack.get()):find(function(p)
    return p.spec.name == 'nvim-treesitter'
end)

if ts_pkg and ts_pkg.path then
    local runtime = vim.fs.joinpath(ts_pkg.path, 'runtime')
    if vim.uv.fs_stat(runtime) then
        vim.opt.rtp:prepend(runtime)
    end
end

require('nvim-treesitter').setup()

local parsers = {
    'bash',
    'c',
    'diff',
    'html',
    'ini',
    'latex',
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

vim.api.nvim_create_user_command('TSInstallCore', function()
    require('nvim-treesitter').install(parsers)
end, { desc = 'Install all core Tree-sitter parsers' })

local ts_group = vim.api.nvim_create_augroup('NvimTreesitterConfig', { clear = true })
local ignored_filetypes = { tmux = true }
local max_filesize = 100 * 1024

vim.api.nvim_create_autocmd('FileType', {
    group = ts_group,
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if ignored_filetypes[ft] or not ft or ft == '' then
            return
        end

        local filepath = vim.api.nvim_buf_get_name(args.buf)
        local ok_stat, stats = pcall(vim.uv.fs_stat, filepath)
        if ok_stat and stats and stats.size > max_filesize then
            return
        end

        local lang = vim.treesitter.language.get_lang(ft) or ft
        if pcall(vim.treesitter.start, args.buf, lang) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})
