require 'core.options'
require 'core.keybinds'
require 'core.autocmds'

vim.g.have_nerd_font = true

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
        error('Error cloning lazy.nvim:\n' .. out)
    end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    require 'plugins.autocompletion',
    require 'plugins.autoformatting',
    require 'plugins.auto-save',
    require 'plugins.autopairs',
    require 'plugins.code_runner',
    require 'plugins.dap',
    require 'plugins.dashboard',
    require 'plugins.diffview',
    require 'plugins.telescope',
    require 'plugins.gitsigns',
    require 'plugins.highlight',
    require 'plugins.image',
    require 'plugins.indent_line',
    require 'plugins.lint',
    require 'plugins.live_preview',
    require 'plugins.lsp',
    require 'plugins.lualine',
    require 'plugins.markdown',
    require 'plugins.mason-conform',
    require 'plugins.mini',
    require 'plugins.neogit',
    require 'plugins.neoscroll',
    require 'plugins.noice',
    require 'plugins.nui',
    require 'plugins.nvimtree',
    require 'plugins.oil',
    -- require 'plugins.onedark',
    -- require 'plugins.zenbones',
    require 'plugins.vague',
    require 'plugins.smart-splits',
    require 'plugins.surround',
    require 'plugins.todo',
    require 'plugins.toggleterm',
    require 'plugins.treesitter',
    require 'plugins.TreeSJ',
    require 'plugins.trouble',
    require 'plugins.undotree',
    require 'plugins.which_key',

    {
        'williamboman/mason.nvim',
        opts = {
            ui = {
                border = 'single',
            },
        },
    },
}, {
    -- Moved `rocks` here to the options table where it belongs
    rocks = {
        enabled = false,
        hererocks = false,
    },
    ui = {
        backdrop = 100,
        border = 'single',
        icons = vim.g.have_nerd_font and {} or {
            cmd = '⌘',
            config = ' ',
            event = '󰃭 ',
            ft = ' ',
            init = '󰅩',
            keys = ' ',
            plugin = ' ',
            runtime = '󰌢 ',
            require = '󰽧',
            source = '󰈙 ',
            start = ' ',
            task = ' ',
            lazy = '󰒲 ',
        },
    },
})

-- local function set_tabline_colors()
--     local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal' })
--     local visual_hl = vim.api.nvim_get_hl(0, { name = 'Visual' })
--
--     vim.api.nvim_set_hl(0, 'TabLineFill', { link = 'Normal' })
--     vim.api.nvim_set_hl(0, 'TabLine', {
--         bg = normal_hl.bg,
--         ctermbg = normal_hl.ctermbg,
--     })
--     vim.api.nvim_set_hl(0, 'TabLineSel', {
--         bg = visual_hl.bg,
--         ctermbg = visual_hl.ctermbg,
--         fg = normal_hl.fg,
--         bold = true,
--     })
-- end
--
-- vim.api.nvim_create_autocmd('ColorScheme', {
--     callback = set_tabline_colors,
-- })
-- set_tabline_colors()
