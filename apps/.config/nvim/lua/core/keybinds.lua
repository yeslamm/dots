-- [[ setting leader keys ]]
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Basic Keymaps ]]
-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- For conciseness
local opts = { noremap = true, silent = true }

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- save file
vim.keymap.set('n', '<C-s>', '<cmd>w<CR>', { desc = 'Save file' })

-- Quit Neovim (save if needed, then quit all)
vim.keymap.set('n', '<C-q>', '<cmd>wa | qa<CR>', { desc = 'Quit Neovim' })

-- [[ Diagnostic Keymaps ]]
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'quickfix list' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>D', vim.diagnostic.open_float, { desc = 'Floating diagnostic' })

-- [[ Basic Navigation ]]
-- Vertical scroll and center
vim.keymap.set('n', '<C-d>', '<C-d>zz', opts)
vim.keymap.set('n', '<C-u>', '<C-u>zz', opts)

-- Find and center
vim.keymap.set('n', 'n', 'nzzzv', opts)
vim.keymap.set('n', 'N', 'Nzzzv', opts)

-- [[ Window Management ]]
-- Note: <C-h/j/k/l> mappings are now handled by the 'nvim-tmux-navigator' plugin

-- Resize with arrows (hjkl preferred for movement, arrows for resizing)
vim.keymap.set('n', '<Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<Right>', ':vertical resize +2<CR>', opts)

-- [[ Buffer Management ]]
-- Better buffer management
vim.keymap.set('n', '<S-l>', ':bnext<CR>', { noremap = true, silent = true, desc = 'Next buffer' })
vim.keymap.set('n', '<S-h>', ':bprev<CR>', { noremap = true, silent = true, desc = 'Prev buffer' })
vim.keymap.set('n', '<C-w>', ':bd<CR>', { noremap = true, silent = true, desc = 'Delete buffer' })
vim.keymap.set('n', '<C-t>', ':enew<CR>', { noremap = true, silent = true, desc = 'New buffer' })

-- [[ Code Manipulation ]]
-- Toggle line wrapping
-- vim.keymap.set('n', '<leader>lw', '<cmd>set wrap!<CR>', { desc = 'Toggle line wrap' })

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- Keep last yanked when pasting
vim.keymap.set('v', 'p', '"_dP', opts)

-- delete single character without copying into register
vim.keymap.set('n', 'x', '"_x', opts)

-- Add trailing comma/semicolon
vim.keymap.set('n', '<leader>;', 'mmA;<Esc>`m', { desc = 'Add trailing semicolon' })
vim.keymap.set('n', '<leader>,', 'mmA,<Esc>`m', { desc = 'Add trailing comma' })

-- vim.keymap.set('n', '-', ':Explore<CR>', { desc = 'Netrw' })

-- [[ Plugin specific keymaps ]]

-- Lazy
vim.keymap.set('n', '<leader>L', '<cmd>Lazy<CR>', { noremap = true, silent = true, desc = 'Open Lazy' })

-- Mason
vim.keymap.set('n', '<leader>M', '<cmd>Mason<CR>', { noremap = true, silent = true, desc = 'Open Mason' })
