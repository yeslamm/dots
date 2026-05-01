---@diagnostic disable: missing-fields
return {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local fzf = require 'fzf-lua'

        fzf.setup {
            -- 1. FZF NATIVE OPTIONS
            fzf_opts = {
                ['--layout'] = 'default',
            },

            -- 2. UI: List on TOP, Preview on BOTTOM, Input in MIDDLE
            winopts = {
                height = 0.85,
                width = 0.80,
                border = 'single',
                preview = {
                    layout = 'vertical',
                    vertical = 'down:50%', -- Preview BELOW the list
                    border = 'single',
                    winopts = {
                        number = true,
                        relativenumber = false,
                        cursorline = true,
                    },
                },
            },

            -- 3. GLOBAL KEYMAPS
            keymap = {
                builtin = {
                    ['<C-d>'] = 'preview-page-down',
                    ['<C-u>'] = 'preview-page-up',
                },
                fzf = {
                    true,
                    ['ctrl-j'] = 'down',
                    ['ctrl-k'] = 'up',
                    ['ctrl-n'] = 'down',
                    ['ctrl-p'] = 'up',
                },
            },

            -- 4. BUFFER SETTINGS
            buffers = {
                prompt = 'Buffers> ',
                actions = {
                    ['ctrl-d'] = false,
                    ['ctrl-u'] = false,
                    ['ctrl-x'] = { fn = fzf.actions.buf_del, reload = true },
                },
            },

            -- 5. FIXED GREP SETTINGS
            grep = {
                -- MOVED -e to the end so it correctly captures your input as the pattern
                rg_opts = '--column --line-number --no-heading --color=never --smart-case --hidden --max-columns=4096 --glob="!.git/" -e',
                rg_glob = true, -- Add this line!
            },

            files = {
                fd_opts = '--color=never --type f --hidden --strip-cwd-prefix --exclude .git --exclude node_modules',
            },

            defaults = {
                file_icons = true,
                color_icons = true,
                git_icons = true,
            },
            fzf_colors = true,

            lsp = {
                jump_to_single_result = true, -- Automatically jump if there's only 1 match
                jump_to_single_result_action = require('fzf-lua.actions').file_edit,
            },
        }

        -- Tell FZF to handle menus, but use a tiny popup without a preview
        fzf.register_ui_select {
            winopts = {
                height = 0.25, -- Very short
                width = 0.35, -- Very narrow
                row = 0.5, -- Dead center vertically
                col = 0.5, -- Dead center horizontally
                preview = { hidden = 'hidden' }, -- Disable the giant preview window
            },
        }

        -- 6. Keymaps
        local map = vim.keymap.set
        map('n', '<leader>sh', fzf.help_tags, { desc = 'Help' })
        map('n', '<leader>sk', fzf.keymaps, { desc = 'Keymaps' })
        map('n', '<leader>sf', fzf.files, { desc = 'Files' })
        map('n', '<leader>ss', fzf.builtin, { desc = 'Builtin' })
        map('n', '<leader>sw', fzf.grep_cword, { desc = 'Current Word' })
        map('n', '<leader>sg', fzf.live_grep, { desc = 'Live Grep' })
        map('n', '<leader>sd', fzf.diagnostics_document, { desc = 'Diagnostics' })
        map('n', '<leader>sr', fzf.resume, { desc = 'Resume' })
        map('n', '<leader>s.', fzf.oldfiles, { desc = 'Recent Files' })
        map('n', '<leader><leader>', fzf.buffers, { desc = 'Buffers' })
        map('n', '<leader>/', fzf.blines, { desc = 'Fuzz Search Buffer' })

        map('n', '<leader>sn', function()
            fzf.files { cwd = vim.fn.stdpath 'config' }
        end, { desc = 'Neovim Files' })
    end,
}
