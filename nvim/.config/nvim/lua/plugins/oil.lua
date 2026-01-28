return {
  'stevearc/oil.nvim',
  opts = {},
  dependencies = { 'nvim-tree/nvim-web-devicons' }, -- Optional, for icons
  lazy = false, -- Lazy loading is not recommended
  config = function()
    require('oil').setup {
      default_file_explorer = true,
      prompt_save_on_select_new_entry = false,
      float = {
        padding = 2,
        max_width = 80,
        max_height = 40,
        border = 'rounded',
        win_options = {
          winblend = 0,
        },
      },
      view_options = {
        show_hidden = true,
        is_hidden_file = function(name, bufnr)
          return vim.startswith(name, '.')
        end,
        is_always_hidden = function(name, bufnr)
          return false
        end,
      },
      keymaps = {
        ['q'] = 'actions.close', -- Remap 'q' to close Oil buffer
        ['<C-c>'] = false, -- Optional: disable Ctrl+c to avoid conflict
        ['='] = function()
          vim.cmd 'write'
        end,
      },
    }
    -- vim.keymap.set('n', '<C-o>', require('oil').toggle_float, { noremap = true, silent = true, desc = 'Toggle Oil Float' })
    vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
  end,
}
