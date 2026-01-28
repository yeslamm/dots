return {
  'okuuva/auto-save.nvim',
  config = function()
    require('auto-save').setup {
      enabled = true, -- start autosave automatically
      trigger_events = {
        immediate_save = { 'BufLeave', 'FocusLost', 'QuitPre', 'VimSuspend' },
        defer_save = { 'InsertLeave', 'TextChanged' },
        cancel_deferred_save = { 'InsertEnter' },
      },
      debounce_delay = 800, -- milliseconds between saves
      exclude_ft = { 'neo-tree' }, -- filetypes to exclude
      condition = function(buf)
        local excluded_filetypes = { 'c' } -- add any languages you want to exclude here
        local ft = vim.fn.getbufvar(buf, '&filetype')
        if vim.tbl_contains(excluded_filetypes, ft) then
          return false -- disable auto-save for C files
        end
        return true
      end,
    }
    vim.api.nvim_set_keymap('n', '<leader>n', ':ASToggle<CR>', { desc = 'save toggle' })
  end,
}
