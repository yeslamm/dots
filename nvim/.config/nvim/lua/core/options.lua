local opt = vim.opt

-- [[ 1. General Behavior ]]
vim.g.have_nerd_font = true
opt.mouse = 'a' -- Enable mouse in all modes
opt.undofile = true -- Persistent undo history
opt.updatetime = 250 -- Faster response (mapped to LSP/Gitsigns)
opt.timeoutlen = 300 -- Time to wait for mapped sequence
opt.confirm = true -- Confirm unsaved changes
opt.clipboard = 'unnamedplus' -- Use system clipboard
opt.completeopt = 'menu,menuone,noselect'

-- [[ 2. UI & Aesthetics ]]
opt.cmdheight = 0

vim.o.laststatus = 3 -- Global statusline
-- opt.globalstatus = true
opt.termguicolors = true -- 24-bit RGB colors
opt.number = true -- Show line numbers
opt.relativenumber = true -- Relative numbers for jumping
opt.signcolumn = 'yes' -- Always show sign column
opt.cursorline = true -- Highlight current line
opt.scrolloff = 10 -- Keep context above/below cursor
opt.sidescrolloff = 8 -- Horizontal context
opt.showmode = false -- Hide default -- INSERT -- (Statusline does this)
opt.showcmd = true -- Show macro recording/partial commands
opt.winblend = 0 -- Absolute transparency
opt.pumblend = 0 -- Popup menu transparency
opt.pumheight = 10 -- Max items in completion menu
vim.opt.splitright = true
vim.opt.splitbelow = true
opt.showtabline = 1 -- Hide the top tabline (we use buffers/FZF)
vim.opt.list = true -- 1. Enable invisible characters

vim.opt.listchars = { -- 2. Define what characters to show
    tab = '>-', -- Renders a tab as '>---' (the classic vi tab style)
    trail = '~', -- Puts a tilde on accidental spaces at the end of a line
    nbsp = '+', -- Highlights non-breaking spaces with a plus sign
    extends = '>', -- Tells you when text runs off the right edge
    precedes = '<', -- Tells you when text runs off the left edge
}

-- [[ 3. Tabs & Indentation (CS50 Standard) ]]
opt.tabstop = 4 -- 1 tab = 4 spaces
opt.shiftwidth = 4 -- Indent size
opt.expandtab = true -- Use spaces instead of tabs
opt.softtabstop = 4 -- will delete all 4 spaces at once
opt.smartindent = true -- Intelligent indentation
opt.breakindent = true -- Wrapped lines keep indentation

-- [[ 4. Text Formatting ]]
opt.wrap = false
opt.linebreak = true -- Wrap at words, not characters
opt.conceallevel = 0 -- Hide MD/JSON markup
opt.virtualedit = 'block' -- Allow cursor to move past end of line in block mode

-- [[ 5. Search Logic ]]
opt.ignorecase = true -- Case-insensitive search...
opt.smartcase = true -- ...until you use a capital letter
opt.incsearch = true -- Preview matches while typing
opt.hlsearch = true -- Keep highlights after search
opt.inccommand = 'split' -- Preview search/replace in a split window

-- [[ 6. Performance & Cleanup ]]
vim.g.loaded_netrw = 1 -- Disable netrw (using Oil.nvim)
vim.g.loaded_netrwPlugin = 1
opt.shortmess:append 'c' -- Reduce completion messages

-- Custom Diff filling
opt.diffopt:append { 'vertical', 'foldcolumn:0', 'context:3' }
opt.fillchars:append { diff = '╱' }
