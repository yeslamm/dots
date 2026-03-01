-- [[ setting leader keys ]]
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Basic Keymaps ]]
-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Save and Quit
vim.keymap.set('n', '<C-s>', '<cmd>w<CR>', { desc = 'Save' })
vim.keymap.set('n', '<S-q>', '<cmd>wa | qa<CR>', { desc = 'Quit All' })

-- [[ Diagnostic Keymaps ]]
vim.keymap.set('n', '<leader>f', vim.diagnostic.setqflist, { desc = 'Quickfix List' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev Diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next Diagnostic' })
vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { desc = 'Line Diagnostic' })

-- [[ Basic Navigation ]]
-- Vertical scroll and center
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Find and center
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Resize with arrows
vim.keymap.set('n', '<Up>', ':resize -2<CR>', { silent = true })
vim.keymap.set('n', '<Down>', ':resize +2<CR>', { silent = true })
vim.keymap.set('n', '<Left>', ':vertical resize -2<CR>', { silent = true })
vim.keymap.set('n', '<Right>', ':vertical resize +2<CR>', { silent = true })

-- [[ Tab Management ]]
vim.keymap.set('n', '<leader><tab>a', '<cmd>tabnew<CR>', { desc = 'Add Tab' })
vim.keymap.set('n', '<leader><tab>q', '<cmd>tabclose<CR>', { desc = 'Close Tab' })
vim.keymap.set('n', '[t', '<cmd>tabprevious<CR>', { desc = 'Prev Tab' })
vim.keymap.set('n', ']t', '<cmd>tabnext<CR>', { desc = 'Next Tab' })

-- [[ Buffer Management ]]
vim.keymap.set('n', '[b', '<cmd>bprevious<CR>', { desc = 'Prev Buffer' })
vim.keymap.set('n', ']b', '<cmd>bnext<CR>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<leader>q', '<cmd>bd<CR>', { desc = 'Close Buffer' })

-- [[ Code Manipulation ]]
-- Stay in indent mode
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Keep last yanked when pasting
vim.keymap.set('v', 'p', '"_dP')

-- Delete without copying into register
vim.keymap.set('n', 'x', '"_x')
vim.keymap.set('n', 'X', '"_X')

-- Add trailing comma/semicolon
vim.keymap.set('n', '<leader>;', 'mmA;<Esc>`m', { desc = 'Add trailing semicolon' })
vim.keymap.set('n', '<leader>,', 'mmA,<Esc>`m', { desc = 'Add trailing comma' })
