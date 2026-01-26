require 'core.options'
require 'core.keybinds'
require 'core.autocmds'

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
        error('Error cloning lazy.nvim:\n' .. out)
    end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
    require 'plugins.lsp',
    require 'plugins.autoformatting',
    require 'plugins.autocompletion',
    require 'plugins.trouble',
    require 'plugins.mason-conform',
    require 'plugins.lint',
    require 'plugins.autopairs',
    require 'plugins.gitsigns',
    require 'plugins.neogit',
    require 'plugins.fugitive',
    require 'plugins.which_key',
    require 'plugins.telescope',
    require 'plugins.lualine',
    require 'plugins.mini',
    require 'plugins.indent_line',
    require 'plugins.tmux-nav',
    require 'plugins.surround',
    require 'plugins.persistence',
    require 'plugins.dashboard',
    require 'plugins.markdown',
    require 'plugins.noice',
    require 'plugins.neoscroll',
    require 'plugins.onedark',
    require 'plugins.todo',
    require 'plugins.toggleterm',
    require 'plugins.code_runner',
    require 'plugins.dap',
    require 'plugins.treesitter',
    require 'plugins.live_preview',
    require 'plugins.TreeSJ',
    require 'plugins.undotree',
    require 'plugins.diffview',
    require 'plugins.oil',
    require 'plugins.nvimtree',
    -- require 'plugins.barbar', -- Tabs/Buffers
    require 'plugins.persistence',

    rocks = {
        enabled = false,
        hererocks = false,
    },

    {
        'williamboman/mason.nvim',
        opts = {
            ui = {
                border = 'single',
            },
        },
    },
}, {
    ui = {
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
local function set_tabline_colors()
    -- Get the colors of the Normal group (editor background)
    local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal' })
    -- Get the colors of the Visual group for a nice highlight on the active tab
    local visual_hl = vim.api.nvim_get_hl(0, { name = 'Visual' })

    -- 1. TabLineFill (Unused space) - Link it directly to Normal
    vim.api.nvim_set_hl(0, 'TabLineFill', { link = 'Normal' })

    -- 2. TabLine (Inactive tabs) - Background same as Normal
    vim.api.nvim_set_hl(0, 'TabLine', {
        bg = normal_hl.bg,
        ctermbg = normal_hl.ctermbg,
    })

    -- 3. TabLineSel (Active tab) - Distinct background (using Visual group) and Bold
    vim.api.nvim_set_hl(0, 'TabLineSel', {
        bg = visual_hl.bg,
        ctermbg = visual_hl.ctermbg,
        fg = normal_hl.fg,
        bold = true,
    })
end

-- Your existing autocmds (lines 122-125) remain correct:
vim.api.nvim_create_autocmd('ColorScheme', {
    callback = set_tabline_colors,
})
set_tabline_colors()
