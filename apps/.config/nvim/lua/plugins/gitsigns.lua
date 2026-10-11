require('gitsigns').setup {
    signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '?' },
    },
    signs_staged = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
    },

    preview_config = {
        border = 'single',
    },

    current_line_blame = true,

    on_attach = function(bufnr)
        local gs = require 'gitsigns'

        local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = 'Git: ' .. desc })
        end

        map('n', ']c', function()
            gs.nav_hunk 'next'
        end, 'Next Hunk')
        map('n', '[c', function()
            gs.nav_hunk 'prev'
        end, 'Prev Hunk')

        map({ 'n', 'v' }, '<leader>gs', ':Gitsigns stage_hunk<CR>', 'Stage Hunk')
        map({ 'n', 'v' }, '<leader>gr', ':Gitsigns reset_hunk<CR>', 'Reset Hunk')

        map('n', '<leader>gS', gs.stage_buffer, 'Stage Buffer')
        map('n', '<leader>gR', gs.reset_buffer, 'Reset Buffer')
        map('n', '<leader>gp', gs.preview_hunk, 'Preview Hunk')
        map('n', '<leader>gb', gs.blame_line, 'Blame Line')
        map('n', '<leader>gB', gs.toggle_current_line_blame, 'Toggle Blame')
        map('n', '<leader>gw', gs.toggle_word_diff, 'Toggle Word Diff')
        map('n', '<leader>gd', gs.diffthis, 'Diff Index')
        map('n', '<leader>gD', function()
            gs.diffthis '~'
        end, 'Diff Last Commit')

        map({ 'o', 'x' }, 'ih', gs.select_hunk, 'Select Hunk')
    end,
}
