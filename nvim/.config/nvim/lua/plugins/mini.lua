return { -- Collection of various small independent plugins/modules
    {
        'echasnovski/mini.nvim',
        config = function()
            -- mini.ai setup
            require('mini.ai').setup { n_lines = 500 }
            -- require('mini.surround').setup() -- Disabled in favor of nvim-surround
            require('mini.tabline').setup() -- Enable minimal buffer tabline

            require('mini.indentscope').setup { symbol = '│', draw = { delay = 100 } }

            -- ═══════════════════════════════════════════════════════════════════════
            -- 👻 MINI.FILES (DISABLED - uncomment to enable file explorer)
            -- ═══════════════════════════════════════════════════════════════════════
            -- require('mini.files').setup { mappings = { synchronize = 's', go_in_plus = '<CR>' } }
            --
            -- -- Hidden files toggle logic
            -- local show_hidden = true
            -- local filter_show_all = function(fs_entry) return true end
            -- local filter_hide_dotfiles = function(fs_entry)
            --   return not vim.startswith(fs_entry.name, '.')
            -- end
            -- local function toggle_hidden_files()
            --   show_hidden = not show_hidden
            --   local filter_func = show_hidden and filter_show_all or filter_hide_dotfiles
            --   require('mini.files').refresh { content = { filter = filter_func } }
            -- end
            -- vim.keymap.set('n', '.', toggle_hidden_files, { desc = 'Toggle hidden files in mini.files' })
            --
            -- -- Buffer-local mappings when mini.files opens
            -- vim.api.nvim_create_autocmd('User', {
            --   pattern = 'MiniFilesBufferCreate',
            --   callback = function(args)
            --     local buf_id = args.data.buf_id
            --     vim.keymap.set('n', '<CR>', function() require('mini.files').go_in() end,
            --       { buffer = buf_id, desc = 'Open file or enter directory' })
            --     vim.keymap.set('n', '<C-n>', '<Nop>', { buffer = buf_id, desc = 'Disable global <C-n>' })
            --   end,
            -- })
            --
            -- -- Global file explorer toggle
            -- vim.keymap.set('n', '<C-n>', function()
            --   require('mini.files').open(vim.api.nvim_buf_get_name(0))
            -- end, { desc = 'File explorer (mini.files)' })

            -- Disable indentscope in various UI buffers
            vim.api.nvim_create_autocmd('FileType', {
                pattern = { 'NvimTree', 'neo-tree', 'help', 'dashboard', 'undotree', 'Lazy', 'mason' },
                callback = function()
                    vim.b.miniindentscope_disable = true
                end,
            })
        end, -- ← This closes the config function
    }, -- ← This closes the plugin table
} -- ← This closes the return table
