vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local map = vim.keymap.set

-- [[ 1. Basic Utilities ]]
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
map({ 'n', 'i', 's' }, '<C-s>', '<cmd>w<CR><esc>', { desc = 'Save' })
map('n', '<S-q>', '<cmd>wa | qa<CR>', { desc = 'Save all and Quit' })
map('n', 'Y', 'y$', { desc = 'Yank to end of line' })

-- [[ 2. Navigation & View ]]
-- Keep cursor centered during jumps/searches
map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
map('n', 'n', 'nzzzv', { desc = 'Next search centered' })
map('n', 'N', 'Nzzzv', { desc = 'Prev search centered' })
map('n', '*', '*N', { desc = 'Highlight without jump' }) -- Highlight word under cursor

-- -- [[ 3. Window Management ]]
-- -- Focus (Ctrl + hjkl)
-- map('n', '<C-h>', '<C-w>h', { desc = 'Move left' })
-- map('n', '<C-j>', '<C-w>j', { desc = 'Move down' })
-- map('n', '<C-k>', '<C-w>k', { desc = 'Move up' })
-- map('n', '<C-l>', '<C-w>l', { desc = 'Move right' })

-- -- Resizing (Ctrl + Alt + hjkl)
-- map('n', '<C-A-j>', '<cmd>resize -2<CR>', { desc = 'Decrease height', silent = true })
-- map('n', '<C-A-k>', '<cmd>resize +2<CR>', { desc = 'Increase height', silent = true })
-- map('n', '<C-A-h>', '<cmd>vertical resize -2<CR>', { desc = 'Decrease width', silent = true })
-- map('n', '<C-A-l>', '<cmd>vertical resize +2<CR>', { desc = 'Increase width', silent = true })

-- Joining lines (Centering behavior)
map('n', 'J', 'mzJ`z', { desc = 'Join lines and keep cursor position' })

-- [[ 4. Lists & Navigation (Manual Brackets) ]]
-- Diagnostics
map('n', '[d', function()
    vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Prev Diagnostic' })
map('n', ']d', function()
    vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Next Diagnostic' })
map('n', 'gl', vim.diagnostic.open_float, { desc = 'Line Diagnostic' })
map('n', '<leader>f', vim.diagnostic.setqflist, { desc = 'Quickfix List' })

-- Tabs
map('n', '[t', '<cmd>tabprevious<CR>', { desc = 'Prev Tab' })
map('n', ']t', '<cmd>tabnext<CR>', { desc = 'Next Tab' })
map('n', '<leader>tn', '<cmd>tabnew<CR>', { desc = 'New Tab' })
map('n', '<leader>tx', '<cmd>tabclose<CR>', { desc = 'Close Tab' })
map('n', '<leader>to', '<cmd>tabonly<CR>', { desc = 'Only This Tab' })

-- Buffers
map('n', '[b', '<cmd>bprevious<CR>', { desc = 'Prev Buffer' })
map('n', ']b', '<cmd>bnext<CR>', { desc = 'Next Buffer' })
map('n', '<leader>q', '<cmd>bd<CR>', { desc = 'Close Buffer' })

-- [[ 5. Code Ergonomics ]]
map('v', '<', '<gv', { desc = 'Decrease indent' })
map('v', '>', '>gv', { desc = 'Increase indent' })
map('v', 'p', '"_dP', { desc = 'Safe Paste' }) -- Paste without losing register content
map('n', 'x', '"_x', { desc = 'Delete char (no register)' })
map('n', 'X', '"_X', { desc = 'Delete to start of line (no register)' })

-- Quick C formatting
map('n', '<leader>;', 'mmA;<Esc>`m', { desc = 'Add trailing semicolon' })
map('n', '<leader>,', 'mmA,<Esc>`m', { desc = 'Add trailing comma' })
