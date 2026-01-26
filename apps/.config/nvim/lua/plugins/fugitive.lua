return {
    'tpope/vim-fugitive',
    config = function()
        vim.keymap.set('n', '<leader>gf', '<cmd>Git<CR>', { noremap = true, silent = true, desc = 'Fugitive: Git Status' })
    end,
}
