return {
    'Wansmer/treesj',
    -- dependencies are defined inside the plugin's table
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
    },
    -- config function where you setup the plugin and its keymaps
    config = function()
        -- call the setup function for treesj
        require('treesj').setup {
            use_default_keymaps = false,
        }

        -- set keymaps for the plugin
        vim.keymap.set('n', '<leader>j', '<cmd>TSJSplit<cr>', { desc = 'Split Node' })
        vim.keymap.set('n', '<leader>k', '<cmd>TSJJoin<cr>', { desc = 'Join Node' })
    end,
}
