return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
  keys = { { '<leader>tv', '<cmd>DiffviewOpen<CR>', desc = 'Open [T]ools [V]iew' } },
  opts = {
    -- Your desired configuration
    -- Example:
    diff_bin = 'diff', -- Set this to 'diff' for standard diff or 'delta' if you have it installed
  },
}
