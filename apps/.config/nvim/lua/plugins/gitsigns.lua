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
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 1000,
        ignore_whitespace = false,
    },

    on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        map('n', ']c', function()
            if vim.wo.diff then
                vim.cmd.normal { ']c', bang = true }
            else
                gitsigns.nav_hunk 'next'
            end
        end, { desc = 'Next Change' })

        map('n', '[c', function()
            if vim.wo.diff then
                vim.cmd.normal { '[c', bang = true }
            else
                gitsigns.nav_hunk 'prev'
            end
        end, { desc = 'Prev Change' })

        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select Git hunk' })

        map('n', '<leader>gs', gitsigns.stage_hunk, { desc = 'Stage/Unstage Hunk' })
        map('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'Reset Hunk' })

        map('v', '<leader>gs', function()
            gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Stage Hunk' })

        map('v', '<leader>gr', function()
            gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Reset Hunk' })

        map('n', '<leader>gS', gitsigns.stage_buffer, { desc = 'Stage Buffer' })
        map('n', '<leader>gR', gitsigns.reset_buffer, { desc = 'Reset Buffer' })
        map('n', '<leader>gp', gitsigns.preview_hunk, { desc = 'Preview Hunk' })
        map('n', '<leader>gb', gitsigns.blame_line, { desc = 'Blame Line' })
        map('n', '<leader>gB', gitsigns.toggle_current_line_blame, { desc = 'Toggle Blame' })
        map('n', '<leader>gw', gitsigns.toggle_word_diff, { desc = 'Toggle Word Diff' })
        map('n', '<leader>gd', gitsigns.diffthis, { desc = 'Diff Index' })

        map('n', '<leader>gD', function()
            gitsigns.diffthis '~'
        end, { desc = 'Diff Last Commit' })
    end,
}
