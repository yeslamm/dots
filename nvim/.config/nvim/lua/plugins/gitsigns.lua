return {
    'lewis6991/gitsigns.nvim',
    opts = {
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
        on_attach = function(bufnr)
            local gitsigns = require 'gitsigns'

            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation
            map('n', ']c', function()
                if vim.wo.diff then
                    vim.cmd.normal { ']c', bang = true }
                else
                    gitsigns.nav_hunk 'next'
                end
            end, { desc = 'Next [C]hange' })

            map('n', '[c', function()
                if vim.wo.diff then
                    vim.cmd.normal { '[c', bang = true }
                else
                    gitsigns.nav_hunk 'prev'
                end
            end, { desc = 'Prev [C]hange' })

            -- Actions
            map('n', '<leader>gs', gitsigns.stage_hunk, { desc = 'Stage Hunk' })
            map('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'Reset Hunk' })
            map('v', '<leader>gs', function()
                gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
            end, { desc = 'Stage Hunk' })
            map('v', '<leader>gr', function()
                gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
            end, { desc = 'Reset Hunk' })

            map('n', '<leader>gS', gitsigns.stage_buffer, { desc = 'Stage Buffer' })
            map('n', '<leader>gR', gitsigns.reset_buffer, { desc = 'Reset Buffer' })
            map('n', '<leader>gu', gitsigns.undo_stage_hunk, { desc = 'Undo Stage Hunk' })
            map('n', '<leader>gp', gitsigns.preview_hunk, { desc = 'Preview Hunk' })
            map('n', '<leader>gb', gitsigns.blame_line, { desc = 'Blame Line' })
            map('n', '<leader>gd', gitsigns.diffthis, { desc = 'Diff Against Index' })
            map('n', '<leader>gD', function()
                gitsigns.diffthis '~'
            end, { desc = 'Diff Against Last Commit' })

            -- Toggles
            map('n', '<leader>gtb', gitsigns.toggle_current_line_blame, { desc = 'Toggle Blame Line' })
            map('n', '<leader>gtd', gitsigns.toggle_deleted, { desc = 'Toggle Deleted' })
            map('n', '<leader>gtw', gitsigns.toggle_word_diff, { desc = 'Toggle Word Diff' })
        end,
    },
}
