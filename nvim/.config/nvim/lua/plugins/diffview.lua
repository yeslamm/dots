return {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
    keys = { { '<leader>gv', '<cmd>DiffviewOpen<CR>', desc = 'Diffview' } },
    opts = {
        diff_bin = 'diff',
    },
}
