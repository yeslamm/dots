local opt = vim.opt

vim.g.have_nerd_font = true
opt.mouse = 'a'
opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.confirm = true
opt.completeopt = 'menu,menuone,noselect'

vim.o.laststatus = 3
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = 'yes'
opt.cursorline = true
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.showmode = false
opt.showcmd = true
opt.winblend = 0
opt.pumblend = 0
opt.pumheight = 10
opt.splitright = true
opt.splitbelow = true
opt.showtabline = 1
opt.list = true
opt.foldlevel = 99
opt.foldlevelstart = 99

opt.listchars = {
    tab = '>-',
    trail = '~',
    nbsp = '+',
    extends = '>',
    precedes = '<',
}

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.softtabstop = 4
opt.smartindent = true
opt.breakindent = true

opt.wrap = false
opt.linebreak = true
opt.conceallevel = 0
opt.virtualedit = 'block'

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.inccommand = 'split'

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
opt.shortmess:append 'c'

opt.diffopt:append { 'vertical', 'foldcolumn:0', 'context:3' }
opt.fillchars:append { diff = '╱' }
