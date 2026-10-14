vim.loader.enable()

require 'core.options'
require 'core.keybinds'
require 'core.autocmds'
require 'core.packs'

local plugins = {
    'colorscheme',
    'mini',
    'lsp',
    'roslyn',
    'rustaceanvim',
    'blink',
    'treesitter',
    'oil',
    'fzf',
    'gitsigns',
    'smart_splits',
    'lualine',
    'autopairs',
    'render_markdown',
    'undotree',
    'diffview',
    'dap',
    'vimtex',
    'conform',
    'lint',
    'which_key',
    'todo_comments',
    'indent_blankline',
    'highlight_colors',
}

for _, plugin in ipairs(plugins) do
    require('plugins.' .. plugin)
end
