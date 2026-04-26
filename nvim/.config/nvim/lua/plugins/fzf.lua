---@diagnostic disable: missing-fields
return {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local fzf = require 'fzf-lua'

        fzf.setup {
            -- 1. Start from the Telescope-like profile, then override
            'telescope',
            winopts = {
                border = 'single',
                width = 0.80,
                height = 0.85,
                -- 2. Vertical layout (preview below), matching your old layout_config
                preview = {
                    layout = 'vertical',
                    vertical = 'down:50%', -- 50% of height for preview
                    border = 'single',
                    -- 3. Line numbers & cursorline in the preview (replaces your autocmd)
                    winopts = {
                        number = true,
                        relativenumber = false,
                        cursorline = true,
                    },
                },
            },

            -- 4. Global defaults applied to all pickers
            defaults = {
                file_icons = true,
                color_icons = true,
                git_icons = true, -- show git status in file listings
            },

            -- 5. Mirror your old `find_command` and `vimgrep_arguments`
            files = {
                fd_opts = '--color=never --type f --strip-cwd-prefix' .. ' --exclude .git --exclude node_modules',
            },
            grep = {
                rg_opts = '--column --line-number --no-heading --color=never' .. ' --smart-case --max-columns=4096 -e',
            },

            -- 6. Automatically generate fzf colors to match your Neovim colorscheme
            fzf_colors = true,

            -- 7. Add C-j / C-k for moving down/up (while keeping fzf defaults)
            keymap = {
                fzf = {
                    true, -- inherit all default fzf binds
                    ['ctrl-j'] = 'down',
                    ['ctrl-k'] = 'up',
                },
            },
        }

        -- 8. UI‑select replacement (already present, keep it)
        fzf.register_ui_select()

        -- 9. Your keymaps (unchanged, plus a resume map)
        vim.keymap.set('n', '<leader>sh', fzf.help_tags, { desc = 'Help' })
        vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = 'Keymaps' })
        vim.keymap.set('n', '<leader>sf', fzf.files, { desc = 'Files' })
        vim.keymap.set('n', '<leader>ss', fzf.builtin, { desc = 'Builtin' })
        vim.keymap.set('n', '<leader>sw', fzf.grep_cword, { desc = 'Current Word' })
        vim.keymap.set('n', '<leader>sg', fzf.live_grep, { desc = 'Live Grep' })
        vim.keymap.set('n', '<leader>sd', fzf.diagnostics_document, { desc = 'Diagnostics' })
        vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = 'Resume' })
        vim.keymap.set('n', '<leader>s.', fzf.oldfiles, { desc = 'Recent Files' })
        vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = 'Buffers' })

        vim.keymap.set('n', '<leader>/', fzf.blines, { desc = 'Fuzz Search Buffer' })
        vim.keymap.set('n', '<leader>sn', function()
            fzf.files { cwd = vim.fn.stdpath 'config' }
        end, { desc = 'Neovim Files' })
    end,
}
