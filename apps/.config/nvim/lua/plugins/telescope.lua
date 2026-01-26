-- This file configures Telescope, the fuzzy finder.
-- For more information, see `:help telescope`
return {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
        -- Plenary is a required dependency for Telescope
        'nvim-lua/plenary.nvim',

        -- This dependency improves Telescope's performance by using fzf's C-based sorter
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            -- `build` is used to run a command when the plugin is installed/updated.
            -- This is only run then, not every time Neovim starts up.
            build = 'make',
            -- `cond` is a condition to determine whether this plugin should be loaded and installed.
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },

        -- This extension replaces vim.ui.select with a Telescope picker, providing a consistent UI.
        { 'nvim-telescope/telescope-ui-select.nvim' },

        -- This plugin provides icons for Telescope and other plugins.
        { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
        -- [[ Configure Telescope ]]
        require('telescope').setup {
            defaults = {
                borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' }, -- Use straight corners
                preview = {
                    filesize_limit = 1, -- in MB, disables preview for files larger than 1MB
                },
                layout_config = {
                    horizontal = {
                        prompt_position = 'bottom',
                        width = 0.95,
                        height = 0.90,
                        preview_width = 0.55, -- Preview takes 55% of total width
                    },
                    vertical = {
                        prompt_position = 'bottom',
                        width = 0.95,
                        height = 0.90,
                    },
                },

                -- Customize Telescope mappings in insert mode
                mappings = {
                    i = {
                        ['<C-k>'] = require('telescope.actions').move_selection_previous, -- move to prev result
                        ['<C-j>'] = require('telescope.actions').move_selection_next, -- move to next result
                        ['<C-l>'] = require('telescope.actions').select_default, -- open file
                    },
                },
            },
            -- Configure individual pickers
            pickers = {
                -- Use 'fd' for faster file finding, ignoring common directories
                find_files = {
                    find_command = { 'fd', '--type', 'f', '--hidden', '--exclude', '.git', '--exclude', 'node_modules', '--exclude', '.venv', '--exclude', '.cache' },
                },
                -- Ignore common directories when grepping
                live_grep = {
                    file_ignore_patterns = { 'node_modules', '.git', '.venv' },
                    additional_args = function(_)
                        return { '--hidden' }
                    end,
                },
            },
            -- Configure extensions
            extensions = {
                ['ui-select'] = require('telescope.themes').get_dropdown(),
            },
        }

        -- Enable Telescope extensions
        -- The pcall is a protected call, which prevents errors if the extension isn't installed
        pcall(require('telescope').load_extension, 'fzf')
        pcall(require('telescope').load_extension, 'ui-select')

        -- [[ Telescope Keymaps ]]
        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
        vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
        vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
        vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
        vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
        vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
        vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
        vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
        vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
        vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

        -- Custom fuzzy find in current buffer
        vim.keymap.set('n', '<leader>/', function()
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10,
                previewer = false,
            })
        end, { desc = '[/] Fuzz search current buffer' })

        -- Custom live_grep in open files
        vim.keymap.set('n', '<leader>s/', function()
            builtin.live_grep {
                grep_open_files = true,
                prompt_title = 'Live Grep in Open Files',
            }
        end, { desc = '[S]earch [/] in Open Files' })

        -- Shortcut for searching your Neovim configuration files
        vim.keymap.set('n', '<leader>sn', function()
            builtin.find_files { cwd = vim.fn.stdpath 'config' }
        end, { desc = '[S]earch [N]eovim files' })
    end,
}
