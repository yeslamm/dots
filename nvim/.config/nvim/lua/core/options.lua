-- [[ Setting options ]]
-- See `:help vim.o` for all options
-- See `:help lua-guide-options`

-- General options
vim.o.number = true -- Show line numbers
vim.o.relativenumber = true -- Show relative line numbers
vim.o.mouse = 'a' -- Enable mouse support
vim.o.clipboard = 'unnamedplus' -- Sync clipboard with system clipboard
vim.o.wrap = false -- Do not wrap lines
vim.o.undofile = true -- Enable persistent undo (creates undo files)
vim.o.ignorecase = true -- Ignore case in search patterns
vim.o.smartcase = true -- Override ignorecase if pattern contains uppercase characters
vim.o.updatetime = 300 -- Time in ms to wait for CursorHold event
vim.o.timeoutlen = 300 -- Time in ms to wait for a mapped sequence to complete
vim.o.splitright = true -- Split windows to the right of the current one
vim.o.splitbelow = true -- Split windows below the current one
vim.o.inccommand = 'split' -- Show effects of :substitute and :global commands in a split window
vim.o.cursorline = true -- Highlight the current line
vim.o.confirm = true -- Ask for confirmation when closing unsaved buffers

-- UI options
vim.o.signcolumn = 'yes' -- Always show the sign column
vim.o.showmode = false -- Do not show current mode in command line
vim.o.ruler = false -- Do not show cursor position in status line
vim.o.scrolloff = 4 -- Minimal number of screen lines to keep above/below cursor
vim.o.sidescrolloff = 8 -- Minimal number of screen columns either side of cursor if wrap is `false`
vim.o.hlsearch = false -- Highlight all matches for last search
vim.o.termguicolors = true -- Enable 24-bit RGB colors
vim.o.showtabline = 2 -- Always show tabs (required for bufferline)
vim.o.pumheight = 10 -- Pop up menu height
vim.o.conceallevel = 0 -- So that `` is visible in markdown files

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
