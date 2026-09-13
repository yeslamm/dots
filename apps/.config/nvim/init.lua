-- init.lua
vim.loader.enable()

require('core.options')
require('core.keybinds')
require('core.autocmds')
require('core.packs')

local core_plugins = {
    'colorscheme',
    'mini',
    'lsp',
    'blink',
    'treesitter',
    'oil',
    'fzf',
    'gitsigns',
    'smart_splits',
    'lualine',

    'mason',
    'autopairs',
    'render_markdown',
    'undotree',
    'diffview',
    'dap',
}

for _, plugin in ipairs(core_plugins) do
    require('plugins.' .. plugin)
end

vim.schedule(function()
    local deferred_plugins = {
        'conform',
        'lint',
        'which_key',
        'todo_comments',
        'indent_blankline',
        'highlight_colors',
    }

    for _, plugin in ipairs(deferred_plugins) do
        require('plugins.' .. plugin)
    end
end)

vim.api.nvim_set_hl(0, 'MasonNormal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'QuickFixLine', { link = 'Normal' })
