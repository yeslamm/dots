local opt = vim.opt

opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.confirm = true

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.winborder = 'single'
opt.signcolumn = 'yes'
opt.laststatus = 3
opt.showmode = false
opt.pumheight = 10

opt.scrolloff = 10
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.breakindent = true
opt.wrap = false
opt.virtualedit = 'block'

opt.ignorecase = true
opt.smartcase = true
opt.foldmethod = 'indent'
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.list = true
opt.listchars = {
    tab = '>-',
    trail = '~',
    nbsp = '+',
    extends = '>',
    precedes = '<',
}

opt.completeopt = { 'menu', 'menuone', 'noinsert', 'fuzzy' }
opt.wildmode = { 'longest:full', 'full' }
opt.diffopt:append { 'foldcolumn:0' }
opt.fillchars:append { diff = '╱' }
opt.shortmess:append 'c'

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map({ 'n', 'x' }, 'j', "v:count == 0 && &wrap ? 'gj' : 'j'", { expr = true, silent = true, desc = 'Down visual line' })
map({ 'n', 'x' }, 'k', "v:count == 0 && &wrap ? 'gk' : 'k'", { expr = true, silent = true, desc = 'Up visual line' })

map({ 'n', 'v' }, '<leader>d', '"_d', { desc = 'Delete motion to void' })
map({ 'n', 'v' }, '<leader>c', '"_c', { desc = 'Change motion to void' })
map('n', 'x', '"_x', { desc = 'Delete character forward (void)' })
map('n', 'X', '"_X', { desc = 'Delete character backward (void)' })

map({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank motion to clipboard' })
map({ 'n', 'v' }, '<leader>Y', '"+y$', { desc = 'Yank line to clipboard' })
map({ 'n', 'v' }, '<leader>p', '"+p', { desc = 'Paste from clipboard' })
map({ 'n', 'v' }, '<leader>P', '"+P', { desc = 'Paste from clipboard (before)' })

map('n', 'J', 'mzJ`z', { desc = 'Join lines and preserve cursor' })

map('n', 'n', 'nzzzv', { desc = 'Next search centered' })
map('n', 'N', 'Nzzzv', { desc = 'Previous search centered' })

map('x', '<', '<gv', { desc = 'Decrease indent' })
map('x', '>', '>gv', { desc = 'Increase indent' })

map('n', '<leader>q', '<cmd>bd<CR>', { desc = 'Quit buffer' })
map('n', '<leader>tn', '<cmd>tabnew<CR>', { desc = 'New tab' })
map('n', '<leader>tx', '<cmd>tabclose<CR>', { desc = 'Close tab' })
map('n', '<leader>to', '<cmd>tabonly<CR>', { desc = 'Close other tabs' })

map('n', '<leader>x', vim.diagnostic.setqflist, { desc = 'Quickfix list' })

map('n', 'gl', function()
    vim.diagnostic.open_float { scope = 'line' }
end, { desc = 'Line diagnostics' })

map('n', '<leader>u', function()
    require('undotree').open { command = 'botright 40vnew' }
end, { desc = 'Toggle Undotree' })

map('n', '<leader>i', function()
    local filter = { bufnr = 0 }
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
end, { desc = 'Toggle LSP inlay hints' })

local notes_dir = vim.fn.expand '~/notes'

local function open_note(rel_path, heading)
    local full_path = notes_dir .. '/' .. rel_path
    vim.fn.mkdir(vim.fn.fnamemodify(full_path, ':h'), 'p')
    vim.cmd.edit(full_path)

    if vim.fn.getfsize(full_path) <= 0 then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { '# ' .. heading, '' })
        vim.cmd.write()
    end
end

map('n', '<leader>nd', function()
    open_note('dailies/' .. os.date '%Y-%m-%d' .. '.md', os.date '%a, %b %d')
end, { desc = "Today's note" })

map('n', '<leader>nb', function()
    open_note('backlog.md', 'Backlog')
end, { desc = 'Backlog note' })

map('n', '<leader>ns', function()
    vim.system({ vim.fn.expand '~/.local/bin/notes-sync' }, {}, function(out)
        vim.schedule(function()
            if out.code == 0 then
                vim.notify('Notes synced!', vim.log.levels.INFO)
            else
                vim.notify('Notes sync failed:\n' .. (out.stderr or ''), vim.log.levels.ERROR)
            end
        end)
    end)
end, { desc = 'Sync notes' })

map('n', '<leader>nf', function()
    require('fzf-lua').files { cwd = notes_dir }
end, { desc = 'Find notes' })

map('n', '<leader>ng', function()
    require('fzf-lua').live_grep { cwd = notes_dir }
end, { desc = 'Grep notes' })

local augroup = vim.api.nvim_create_augroup('UserConfig', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    group = augroup,
    callback = function()
        vim.hl.on_yank { higroup = 'IncSearch', timeout = 250 }
    end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
    group = augroup,
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if ft:find 'commit' or ft:find 'rebase' then
            return
        end

        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
            vim.cmd 'normal! g`"zz'
        end
    end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
    group = augroup,
    callback = function(args)
        if args.match:match '^%w%w+:[\\/][\\/]' then
            return
        end
        local file = vim.uv.fs_realpath(args.match) or args.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ':h'), 'p')
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    callback = function()
        vim.opt_local.formatoptions:remove { 'c', 'r', 'o' }
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = { 'help', 'qf', 'man', 'checkhealth', 'gitsigns-blame' },
    callback = function(args)
        vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = args.buf, silent = true })
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = { 'nvim-undotree', 'oil', 'qf' },
    callback = function()
        vim.opt_local.foldenable = false
    end,
})

vim.api.nvim_create_autocmd('VimResized', {
    group = augroup,
    command = 'wincmd =',
})

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
    group = augroup,
    callback = function()
        if vim.api.nvim_win_get_config(0).relative == '' then
            vim.opt_local.cursorline = true
        end
    end,
})

vim.api.nvim_create_autocmd('WinLeave', {
    group = augroup,
    callback = function()
        vim.opt_local.cursorline = false
    end,
})

vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == 'nvim-treesitter' and (kind == 'install' or kind == 'update') then
            if not ev.data.active then
                vim.cmd.packadd 'nvim-treesitter'
            end
            vim.cmd 'TSUpdate'
        end
    end,
})

vim.pack.add {
    'https://github.com/EdenEast/nightfox.nvim',
    'https://github.com/nvim-mini/mini.nvim',

    'https://github.com/mason-org/mason.nvim',
    'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/seblyng/roslyn.nvim',
    { src = 'https://github.com/mrcjkb/rustaceanvim', version = vim.version.range '^9' },
    'https://github.com/b0o/schemastore.nvim',
    'https://github.com/j-hui/fidget.nvim',
    'https://github.com/folke/lazydev.nvim',

    { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.x' },
    'https://github.com/rafamadriz/friendly-snippets',
    'https://github.com/stevearc/conform.nvim',
    'https://github.com/mfussenegger/nvim-lint',

    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',
    'https://github.com/selimacerbas/mdkite.nvim',
    'https://github.com/selimacerbas/kitehost.nvim',

    'https://github.com/ibhagwan/fzf-lua',
    'https://github.com/stevearc/oil.nvim',
    'https://github.com/folke/which-key.nvim',
    'https://github.com/mrjones2014/smart-splits.nvim',
    'https://github.com/smart-splits-nvim/backend-tmux',

    'https://github.com/lewis6991/gitsigns.nvim',

    'https://github.com/mfussenegger/nvim-dap',
    'https://github.com/theHamsta/nvim-dap-virtual-text',
    'https://github.com/jay-babu/mason-nvim-dap.nvim',
}

vim.cmd 'packadd nvim.undotree'

vim.api.nvim_create_user_command('PackUpdate', function(o)
    vim.pack.update(nil, { force = o.bang })
end, { bang = true })

vim.api.nvim_create_user_command('PackClean', function()
    for _, p in ipairs(vim.pack.get()) do
        if not p.active then
            vim.pack.del { p.spec.name }
        end
    end
end, {})
