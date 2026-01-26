return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons', -- or other dependencies you prefer
  },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  config = function()
    require('render-markdown').setup {
      completions = { lsp = { enabled = true } },
    }
  end,
}
