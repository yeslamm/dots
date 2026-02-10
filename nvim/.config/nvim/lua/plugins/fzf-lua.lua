return {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local fzf = require 'fzf-lua'
        fzf.setup {
            -- Modern look and feel
            'fzf-native',
            winopts = {
                height = 0.90,
                width = 0.90,
                row = 0.50,
                col = 0.50,
                -- Use native Neovim float highlights
                hls = {
                    normal = 'NormalFloat',
                    border = 'FloatBorder',
                    preview_normal = 'NormalFloat',
                    preview_border = 'FloatBorder',
                },
                preview = {
                    layout = 'vertical',
                    vertical = 'down:45%',
                },
            },
            keymap = {
                builtin = {
                    ['<C-d>'] = 'preview-page-down',
                    ['<C-u>'] = 'preview-page-up',
                },
                fzf = {
                    ['ctrl-j'] = 'down',
                    ['ctrl-k'] = 'up',
                    ['ctrl-n'] = 'next-history',
                    ['ctrl-p'] = 'prev-history',
                    ['ctrl-d'] = 'preview-page-down',
                    ['ctrl-u'] = 'preview-page-up',
                },
            },
            -- UI Improvements
            fzf_opts = {
                ['--no-info'] = '',
                ['--info'] = 'inline', -- Cleaner info line
                ['--margin'] = '1,1',
                ['--padding'] = '0,0',
            },
            -- Mimic your telescope preferences but better
            files = {
                formatter = 'path.filename_first', -- Show filename, then path (easier to read)
                fd_opts = '--type f --hidden --exclude .git --exclude node_modules --exclude .venv --exclude .cache',
            },
            grep = {
                rg_opts = '--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e',
            },
        }

        -- Register fzf-lua as the ui.select provider
        fzf.register_ui_select()

        -- [[ Fzf-lua Keymaps ]]
        vim.keymap.set('n', '<leader>sh', fzf.help_tags, { desc = '[S]earch [H]elp' })
        vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [K]eymaps' })
        vim.keymap.set('n', '<leader>sf', fzf.files, { desc = '[S]earch [F]iles' })
        vim.keymap.set('n', '<leader>ss', fzf.builtin, { desc = '[S]earch [S]elect Fzf-lua' })
        vim.keymap.set('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch current [W]ord' })
        vim.keymap.set('n', '<leader>sg', fzf.live_grep, { desc = '[S]earch by [G]rep' })
        vim.keymap.set('n', '<leader>sd', fzf.diagnostics_workspace, { desc = '[S]earch [D]iagnostics' })
        vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = '[S]earch [R]esume' })
        vim.keymap.set('n', '<leader>s.', fzf.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
        vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = '[ ] Find existing buffers' })

        -- Custom fuzzy find in current buffer
        vim.keymap.set('n', '<leader>/', fzf.lgrep_curbuf, { desc = '[/] Fuzz search current buffer' })

        -- Custom live_grep in open files
        vim.keymap.set('n', '<leader>s/', function()
            fzf.live_grep {
                multiplexer = 'grep',
                filespec = table.concat(vim.tbl_map(vim.api.nvim_buf_get_name, vim.api.nvim_list_bufs()), ' '),
            }
        end, { desc = '[S]earch [/] in Open Files' })

        -- Shortcut for searching your Neovim configuration files
        vim.keymap.set('n', '<leader>sn', function()
            fzf.files { cwd = vim.fn.stdpath 'config' }
        end, { desc = '[S]earch [N]eovim files' })
    end,
}
