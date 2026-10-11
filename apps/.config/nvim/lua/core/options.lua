local opt = vim.opt

opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.confirm = true
opt.mouse = 'a'

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = 'yes'
opt.laststatus = 3
opt.showmode = false
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.pumheight = 10

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.breakindent = true
opt.wrap = false
opt.linebreak = true
opt.virtualedit = 'block'

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = 'split'

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

opt.diffopt:append { 'foldcolumn:0' }
opt.fillchars:append { diff = '╱' }
opt.shortmess:append 'c'

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
