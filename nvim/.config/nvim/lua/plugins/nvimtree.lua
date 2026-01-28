return {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
        'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
    config = function()
        require('nvim-tree').setup {
            sort = { sorter = 'case_sensitive' },
            view = {
                width = 35,
                side = 'left',
            },
            renderer = {
                icons = {
                    show = {
                        modified = true,
                    },
                    glyphs = {
                        modified = '●',
                    },
                },
                highlight_modified = 'all',
            },
            filters = {
                dotfiles = false,
            },
            diagnostics = {
                enable = true,
                icons = {
                    hint = ' ',
                    info = ' ',
                    warning = ' ',
                    error = ' ',
                },
            },
            -- Add this block to sync with current file's directory
            update_focused_file = {
                enable = true,
                update_root = true,
            },
        }
        vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
    end,

    lazy = false, -- load on startup
}
