vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local map = vim.keymap.set

map({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank motion to clipboard' })
map({ 'n', 'v' }, '<leader>Y', '"+y$', { desc = 'Yank line to clipboard' })
map({ 'n', 'v' }, '<leader>p', '"+p', { desc = 'Paste from clipboard' })
map({ 'n', 'v' }, '<leader>P', '"+P', { desc = 'Paste from clipboard (before)' })
map('v', 'p', '"_dP', { desc = 'Safe paste (preserve register)' })

map({ 'n', 'v' }, '<leader>d', '"_d', { desc = 'Delete motion to void' })
map({ 'n', 'v' }, '<leader>c', '"_c', { desc = 'Change motion to void' })
map('n', 'x', '"_x', { desc = 'Delete character forward (void)' })
map('n', 'X', '"_X', { desc = 'Delete character backward (void)' })

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map({ 'n', 'x' }, 'j', "v:count == 0 && &wrap ? 'gj' : 'j'", { expr = true, silent = true, desc = 'Down visual line' })
map({ 'n', 'x' }, 'k', "v:count == 0 && &wrap ? 'gk' : 'k'", { expr = true, silent = true, desc = 'Up visual line' })
map('n', 'J', 'mzJ`z', { desc = 'Join lines and preserve cursor' })

map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
map('n', 'n', 'nzzzv', { desc = 'Next search centered' })
map('n', 'N', 'Nzzzv', { desc = 'Previous search centered' })
map('n', '*', '*N', { desc = 'Highlight word under cursor without jumping' })

map('v', '<', '<gv', { desc = 'Decrease indent' })
map('v', '>', '>gv', { desc = 'Increase indent' })

map('n', 'gl', function()
    vim.diagnostic.open_float { scope = 'line' }
end, { desc = 'Line diagnostics' })
map('n', '<leader>x', vim.diagnostic.setqflist, { desc = 'Quickfix list' })

map('n', '[t', '<cmd>tabprevious<CR>', { desc = 'Previous tab' })
map('n', ']t', '<cmd>tabnext<CR>', { desc = 'Next tab' })
map('n', '<leader>q', '<cmd>bd<CR>', { desc = 'Quit buffer' })
map('n', '<leader>tn', '<cmd>tabnew<CR>', { desc = 'New tab' })
map('n', '<leader>tx', '<cmd>tabclose<CR>', { desc = 'Close tab' })
map('n', '<leader>to', '<cmd>tabonly<CR>', { desc = 'Close other tabs' })

map('n', '<leader>u', function()
    require('undotree').open { command = 'botright 40vnew' }
end, { desc = 'Toggle Undotree' })

map('n', '<leader>i', function()
    local filter = { bufnr = 0 }
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
end, { desc = 'Toggle LSP inlay hints' })

local notes_dir = vim.fn.expand '~/notes'

map('n', '<leader>nd', function()
    local dailies_dir = notes_dir .. '/dailies'
    local today_file = dailies_dir .. '/' .. os.date '%Y-%m-%d' .. '.md'
    vim.fn.mkdir(dailies_dir, 'p')
    vim.cmd.edit(today_file)

    if vim.fn.getfsize(today_file) <= 0 then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            '# Daily Log: ' .. os.date '%Y-%m-%d (%A)',
            '',
        })
        vim.cmd 'write'
    end
end, { desc = "Today's note" })

map('n', '<leader>nb', function()
    local backlog_file = notes_dir .. '/backlog.md'
    vim.fn.mkdir(notes_dir, 'p')
    vim.cmd.edit(backlog_file)

    if vim.fn.getfsize(backlog_file) <= 0 then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            '# Backlog',
            '',
        })
        vim.cmd 'write'
    end
end, { desc = 'Backlog note' })

map('n', '<leader>nf', function()
    require('fzf-lua').files { cwd = notes_dir }
end, { desc = 'Find notes' })

map('n', '<leader>ng', function()
    require('fzf-lua').live_grep { cwd = notes_dir }
end, { desc = 'Grep notes' })
