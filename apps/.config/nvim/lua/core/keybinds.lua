vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local map = vim.keymap.set

map({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank motion to system clipboard' })
map({ 'n', 'v' }, '<leader>Y', '"+y$', { desc = 'Yank line to system clipboard' })
map({ 'n', 'v' }, '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
map({ 'n', 'v' }, '<leader>P', '"+P', { desc = 'Paste from system clipboard (before)' })
map('v', 'p', '"_dP', { desc = 'Safe Paste (internal register protected)' })

map({ 'n', 'v' }, '<leader>d', '"_d', { desc = 'Delete motion to void' })
map({ 'n', 'v' }, '<leader>c', '"_c', { desc = 'Change motion to void' })
map('n', 'x', '"_x', { desc = 'Delete char under cursor (void)' })
map('n', 'X', '"_X', { desc = 'Delete char backward (void)' })

map('n', '<Esc>', function()
    vim.cmd.nohlsearch()
    return '<Esc>'
end, { expr = true, desc = 'Clear search highlights' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
map({ 'n', 'i', 's' }, '<C-s>', '<cmd>w<CR><esc>', { desc = 'Save' })
map('n', '<S-q>', '<cmd>wa | qa<CR>', { desc = 'Save all and Quit' })

map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
map('n', 'n', 'nzzzv', { desc = 'Next search centered' })
map('n', 'N', 'Nzzzv', { desc = 'Prev search centered' })
map('n', '*', '*N', { desc = 'Highlight without jump' })

map('n', 'J', 'mzJ`z', { desc = 'Join lines and keep cursor position' })
map('v', '<', '<gv', { desc = 'Decrease indent' })
map('v', '>', '>gv', { desc = 'Increase indent' })
map('n', '<leader>;', 'mmA;<Esc>`m', { desc = 'Add trailing semicolon' })
map('n', '<leader>,', 'mmA,<Esc>`m', { desc = 'Add trailing comma' })

map('n', '[d', function()
    vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Prev Diagnostic' })

map('n', ']d', function()
    vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Next Diagnostic' })

map('n', 'gl', function()
    vim.diagnostic.open_float { scope = 'line' }
end, { desc = 'Line Diagnostic' })

map('n', '<leader>x', function()
    vim.diagnostic.setqflist()
end, { desc = 'Quickfix list' })

map('n', '[b', '<cmd>bprevious<CR>', { desc = 'Prev Buffer' })
map('n', ']b', '<cmd>bnext<CR>', { desc = 'Next Buffer' })
map('n', '<leader>q', '<cmd>bd<CR>', { desc = 'Quit Buffer' })

map('n', '[t', '<cmd>tabprevious<CR>', { desc = 'Prev Tab' })
map('n', ']t', '<cmd>tabnext<CR>', { desc = 'Next Tab' })
map('n', '<leader>tn', '<cmd>tabnew<CR>', { desc = 'New Tab' })
map('n', '<leader>tx', '<cmd>tabclose<CR>', { desc = 'Close Tab' })
map('n', '<leader>to', '<cmd>tabonly<CR>', { desc = 'Only This Tab' })

map('n', '<leader>r', '<cmd>registers<CR>', { desc = 'Registers' })
map('n', '<leader>m', '<cmd>marks<CR>', { desc = 'Marks' })
