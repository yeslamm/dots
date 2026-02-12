return {
    'rmagatti/auto-session',
    lazy = false,
    dependencies = {
        'nvim-telescope/telescope.nvim',
    },
    config = function()
        require('auto-session').setup {
            auto_restore_enabled = false,
            auto_session_suppress_dirs = { '~/', '~/Downloads', '/' },
            session_lens = {
                load_on_setup = true,
                theme_conf = { border = true },
                previewer = false,
            },
        }

        -- Keymaps
        vim.keymap.set('n', '<leader>wr', '<cmd>AutoSession restore<cr>', { desc = 'Restore Session' })
        vim.keymap.set('n', '<leader>ws', '<cmd>AutoSession save<cr>', { desc = 'Save Session' })
        vim.keymap.set('n', '<leader>wa', '<cmd>AutoSession search<cr>', { desc = 'Search Sessions' })
    end,
}
