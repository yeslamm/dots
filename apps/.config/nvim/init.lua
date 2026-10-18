vim.loader.enable()

require 'core.options'
require 'core.keybinds'
require 'core.autocmds'
require 'core.packs'

local immediate_plugins = {
    'colorscheme',
    'mini',
    'treesitter',
    'lsp',
    'roslyn',
    'rustaceanvim',
    'blink',
    'oil',
    'lualine',
    'vimtex',
}

for _, plugin in ipairs(immediate_plugins) do
    require('plugins.' .. plugin)
end

local deferred_plugins = {
    'fzf',
    'gitsigns',
    'smart_splits',
    'autopairs',
    'render_markdown',
    'undotree',
    'diffview',
    'dap',
    'conform',
    'lint',
    'which_key',
    'todo_comments',
    'indent_blankline',
    'highlight_colors',
}

vim.schedule(function()
    for _, plugin in ipairs(deferred_plugins) do
        require('plugins.' .. plugin)
    end
end)
