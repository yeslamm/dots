return {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },
        { 'nvim-telescope/telescope-ui-select.nvim' },
        { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
        '3rd/image.nvim',
    },
    config = function()
        local telescope = require 'telescope'

        telescope.setup {
            defaults = {
                previewer = true,
                layout_strategy = 'vertical',
                layout_config = {
                    vertical = {
                        width = 0.8,
                        height = 0.85,
                        preview_height = 0.5,
                        preview_cutoff = 0,
                    },
                },
                vimgrep_arguments = {
                    'rg',
                    '--color=never',
                    '--no-heading',
                    '--with-filename',
                    '--line-number',
                    '--column',
                    '--smart-case',
                },
                find_command = {
                    'fd',
                    '--type',
                    'f',
                    '--strip-cwd-prefix',
                    '--exclude',
                    '.git',
                },
                mappings = {
                    i = {
                        ['<C-j>'] = 'move_selection_next',
                        ['<C-k>'] = 'move_selection_previous',
                        ['<C-n>'] = 'move_selection_next',
                        ['<C-p>'] = 'move_selection_previous',
                        ['<C-u>'] = 'preview_scrolling_up',
                        ['<C-d>'] = 'preview_scrolling_down',
                        ['<CR>'] = 'select_default',
                    },
                    n = {
                        ['<C-j>'] = 'move_selection_next',
                        ['<C-k>'] = 'move_selection_previous',
                        ['<C-n>'] = 'move_selection_next',
                        ['<C-p>'] = 'move_selection_previous',
                        ['<C-u>'] = 'preview_scrolling_up',
                        ['<C-d>'] = 'preview_scrolling_down',
                    },
                },
                file_ignore_patterns = { 'node_modules', '.git/' },
            },
            extensions = {
                ['ui-select'] = {
                    require('telescope.themes').get_dropdown(),
                },
            },
        }

        -- Enable Telescope extensions if they are installed
        pcall(telescope.load_extension, 'fzf')
        pcall(telescope.load_extension, 'ui-select')

        -- Enable line numbers in previewer
        vim.api.nvim_create_autocmd('User', {
            pattern = 'TelescopePreviewerLoaded',
            callback = function()
                vim.wo.number = true
            end,
        })

        -- See `:help telescope.builtin`
        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Help' })
        vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'Keymaps' })
        vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Files' })
        vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = 'Builtin' })
        vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = 'Current Word' })
        vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Live Grep' })
        vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Diagnostics' })
        vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Resume' })
        vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = 'Recent Files' })
        vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Buffers' })

        -- Custom fuzzy find in current buffer
        vim.keymap.set('n', '<leader>/', function()
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10,
            })
        end, { desc = 'Fuzz Search' })

        -- Live grep in open files
        vim.keymap.set('n', '<leader>s/', function()
            builtin.live_grep {
                grep_open_files = true,
                prompt_title = 'Live Grep in Open Files',
            }
        end, { desc = 'Open Files' })

        -- Shortcut for searching your Neovim configuration files
        vim.keymap.set('n', '<leader>sn', function()
            builtin.find_files { cwd = vim.fn.stdpath 'config' }
        end, { desc = 'Neovim Files' })
    end,
}