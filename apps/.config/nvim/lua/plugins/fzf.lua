---@diagnostic disable: missing-fields
return {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local fzf = require 'fzf-lua'

        fzf.setup {
            fzf_opts = {
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
                    winopts = {
                        number = true,
                        relativenumber = false,
                        cursorline = true,
                    },
                },
            },

            keymap = {
                builtin = {
                    ['<C-d>'] = 'preview-page-down',
                    ['<C-u>'] = 'preview-page-up',
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
                    ['ctrl-d'] = false,
                    ['ctrl-u'] = false,
                    ['ctrl-x'] = { fn = fzf.actions.buf_del, reload = true },
                },
            },

            grep = {
                rg_opts = '--column --line-number --no-heading --color=never --smart-case --hidden --max-columns=4096 --glob="!.git/" -e',
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
                jump_to_single_result = true,
                jump_to_single_result_action = require('fzf-lua.actions').file_edit,
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
        map('n', '<leader>s.', fzf.oldfiles, { desc = 'Recent Files' })
        map('n', '<leader><leader>', fzf.buffers, { desc = 'Buffers' })
        map('n', '<leader>/', fzf.blines, { desc = 'Fuzz Search Buffer' })
        map('n', '<leader>sr', fzf.registers, { desc = 'Registers' })

        map('n', '<leader>vf', function()
            fzf.files { cwd = '~/vault', prompt = 'Vault Files> ' }
        end, { desc = 'Files' })

        map('n', '<leader>vg', function()
            fzf.live_grep {
                cwd = '~/vault',
                prompt = 'Vault Grep> ',
            }
        end, { desc = 'Grep' })

        map('n', '<leader>sn', function()
            fzf.files { cwd = vim.fn.stdpath 'config' }
        end, { desc = 'Neovim Files' })
    end,
}
