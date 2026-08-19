---@diagnostic disable: missing-fields
return {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local fzf = require 'fzf-lua'

        fzf.setup {
            fzf_opts = {
                ['--cycle'] = true,
                ['--layout'] = 'default',
            },

            winopts = {
                height = 0.85,
                width = 0.80,
                border = 'single',
                preview = {
                    layout = 'vertical',
                    vertical = 'down:50%',
                    border = 'single',
                    wrap = false,
                    winopts = {
                        number = true,
                        relativenumber = false,
                        cursorline = true,
                    },
                },
            },

            keymap = {
                builtin = {
                    true,
                    ['<M-d>'] = 'preview-page-down',
                    ['<M-u>'] = 'preview-page-up',
                    ['<M-j>'] = 'preview-down',
                    ['<M-k>'] = 'preview-up',
                    ['<M-/>'] = 'toggle-preview',
                    ['<M-w>'] = 'toggle-preview-wrap',
                    ['<M-z>'] = 'toggle-fullscreen',
                },
                fzf = {
                    true,
                    ['ctrl-j'] = 'ignore',
                    ['ctrl-k'] = 'ignore',
                    ['ctrl-n'] = 'down',
                    ['ctrl-p'] = 'up',
                },
            },

            buffers = {
                prompt = 'Buffers> ',
                actions = {
                    ['ctrl-x'] = { fn = fzf.actions.buf_del, reload = true },
                },
            },

            grep = {
                rg_opts = '--column --line-number --no-heading --color=always --smart-case --hidden --max-columns=4096 --glob="!.git/" -e',
                rg_glob = true,
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
                jump1 = true,
                jump1_action = fzf.actions.file_edit,
            },
        }

        fzf.register_ui_select {
            winopts = {
                height = 0.25,
                width = 0.35,
                row = 0.5,
                col = 0.5,
                preview = { hidden = 'hidden' },
            },
        }

        local map = vim.keymap.set
        map('n', '<leader>sf', fzf.files, { desc = 'Files' })
        map('n', '<leader>ss', fzf.builtin, { desc = 'Builtin' })
        map('n', '<leader>sw', fzf.grep_cword, { desc = 'Current Word' })
        map('n', '<leader>sg', fzf.live_grep, { desc = 'Live Grep' })
        map('n', '<leader>sd', fzf.diagnostics_document, { desc = 'Diagnostics' })
        map('n', '<leader>sh', fzf.help_tags, { desc = 'Help Tags' })
        map('n', '<leader>sk', fzf.keymaps, { desc = 'Keymaps' })
        map('n', '<leader>s.', fzf.oldfiles, { desc = 'Recent Files' })
        map('n', '<leader><leader>', fzf.buffers, { desc = 'Buffers' })
        map('n', '<leader>/', fzf.blines, { desc = 'Fuzz Search Buffer' })
        map('n', '<leader>sr', fzf.registers, { desc = 'Registers' })

        map('n', '<leader>sn', function()
            fzf.files { cwd = vim.fn.stdpath 'config' }
        end, { desc = 'Neovim Files' })
    end,
}
