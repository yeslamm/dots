-- [[ Setting options ]]
-- See `:help vim.o` for all options
-- See `:help lua-guide-options`

-- General options
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.mouse = 'a' -- Enable mouse support
vim.opt.clipboard = 'unnamedplus' -- Sync clipboard with system clipboard
vim.opt.wrap = true -- Do not wrap lines
vim.opt.undofile = true -- Enable persistent undo
vim.opt.ignorecase = true -- Ignore case in search
vim.opt.smartcase = true -- Override ignorecase if pattern contains uppercase
vim.opt.updatetime = 300 -- Faster completion and diagnostic display
vim.opt.timeoutlen = 300 -- Time to wait for a mapped sequence
vim.opt.splitright = true -- Vertical splits to the right
vim.opt.splitbelow = true -- Horizontal splits below
vim.opt.inccommand = 'split' -- Preview incremental substitute
vim.opt.cursorline = true -- Highlight current line
vim.opt.confirm = true -- Confirm unsaved changes
vim.opt.smoothscroll = true -- Smooth scrolling for wrapped lines
vim.o.laststatus = 2 -- Per-window statusline
vim.o.winborder = 'rounded' -- Rounded borders for windows

-- Folding settings for nvim-ufo
vim.opt.foldcolumn = '0'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

-- UI options
vim.opt.signcolumn = 'yes' -- Always show sign column
vim.opt.showmode = false -- Mode already in statusline
vim.opt.scrolloff = 10 -- Lines of context around cursor
vim.opt.sidescrolloff = 8 -- Columns of context around cursor
vim.opt.hlsearch = true -- Keep search highlights
vim.opt.termguicolors = true -- Enable 24-bit RGB colors
vim.opt.showtabline = 2 -- Always show tabline
vim.opt.pumheight = 10 -- Height of popup menu
vim.opt.conceallevel = 2 -- Hide markup for better readability

-- Indentation options
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.tabstop = 4 -- Number of spaces a <Tab> counts for
vim.opt.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent
-- vim.opt.softtabstop = 4 -- Number of spaces that a <Tab> counts for
vim.o.autoindent = true -- Copy indent from current line to new line (already true)
vim.o.smartindent = true -- Smart autoindent based on code structure (user requested)
vim.o.breakindent = true -- Preserve indent in wrapped lines (redundant setting removed)
vim.o.linebreak = true -- Break lines at word boundaries

-- Other settings
vim.g.loaded_netrw = 1 -- Disable netrw (handled by file explorer plugins like nvimtree/oil)
vim.g.loaded_netrwPlugin = 1 -- Disable netrw plugin

vim.opt.diffopt:append { 'vertical', 'foldcolumn:0', 'context:3' } -- Custom diff options
vim.opt.fillchars:append { diff = '╱' } -- Custom diff fill char
vim.opt.shortmess:append 'c' -- Don't give |ins-completion-menu| messages
vim.opt.iskeyword:append '-' -- Hyphenated words recognized by searches
vim.opt.formatoptions:remove { 'c', 'r', 'o' } -- Don't insert comment leader automatically
