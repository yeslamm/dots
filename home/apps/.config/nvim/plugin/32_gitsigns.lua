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

    current_line_blame = true,

    on_attach = function(bufnr)
        local gs = require 'gitsigns'

        local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = 'Git: ' .. desc })
        end

        map('n', ']c', function()
            if vim.wo.diff then
                vim.cmd.normal { ']c', bang = true }
            else
                gs.nav_hunk 'next'
            end
        end, 'Next Hunk')

        map('n', '[c', function()
            if vim.wo.diff then
                vim.cmd.normal { '[c', bang = true }
            else
                gs.nav_hunk 'prev'
            end
        end, 'Prev Hunk')

        map('n', '<leader>gs', gs.stage_hunk, 'Stage/Unstage Hunk')
        map('n', '<leader>gr', gs.reset_hunk, 'Reset Hunk')
        map('v', '<leader>gs', function()
            gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, 'Stage/Unstage Hunk')
        map('v', '<leader>gr', function()
            gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, 'Reset Hunk')

        map('n', '<leader>gS', gs.stage_buffer, 'Stage Buffer')
        map('n', '<leader>gu', gs.reset_buffer_index, 'Unstage Buffer')
        map('n', '<leader>gR', gs.reset_buffer, 'Reset Buffer')

        map('n', '<leader>gp', gs.preview_hunk, 'Preview Hunk')
        map('n', '<leader>gi', gs.preview_hunk_inline, 'Preview Hunk Inline')
        map('n', '<leader>gb', function()
            gs.blame_line { full = true }
        end, 'Blame Line')
        map('n', '<leader>gB', gs.toggle_current_line_blame, 'Toggle Blame')
        map('n', '<leader>gw', gs.toggle_word_diff, 'Toggle Word Diff')
        map('n', '<leader>gd', gs.diffthis, 'Diff Index')
        map('n', '<leader>gD', function()
            gs.diffthis '~'
        end, 'Diff Last Commit')

        map({ 'o', 'x' }, 'ih', gs.select_hunk, 'Select Hunk')
    end,
}
