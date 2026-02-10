return {
    'rmagatti/auto-session',
    lazy = false,
    dependencies = {
        'ibhagwan/fzf-lua',
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
        vim.keymap.set('n', '<leader>wr', '<cmd>AutoSession restore<cr>', { desc = 'Restore session for cwd' })
        vim.keymap.set('n', '<leader>ws', '<cmd>AutoSession save<cr>', { desc = 'Save session' })
        vim.keymap.set('n', '<leader>wa', '<cmd>AutoSession search<cr>', { desc = 'Search sessions' })
    end,
}
