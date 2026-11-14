local fzf = require 'fzf-lua'

fzf.setup {
    fzf_colors = true,
    defaults = {
        formatter = 'path.filename_first',
    },
    fzf_opts = {
        ['--cycle'] = true,
        ['--layout'] = 'default',
    },
    winopts = {
        row = 0.40,
        border = 'single',
        preview = {
            layout = 'vertical',
            vertical = 'down:50%',
            border = 'single',
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
        },
    },
}

fzf.register_ui_select(nil, true)

local map = vim.keymap.set
map('n', '<leader>sf', fzf.files, { desc = 'Files' })
map('n', '<leader>ss', fzf.builtin, { desc = 'Builtin' })
map('n', '<leader>sw', fzf.grep_cword, { desc = 'Current Word' })
map('n', '<leader>sg', fzf.live_grep, { desc = 'Live Grep' })
map('n', '<leader>sd', fzf.diagnostics_document, { desc = 'Diagnostics' })
map('n', '<leader>s.', fzf.oldfiles, { desc = 'Recent Files' })
map('n', '<leader>sr', fzf.resume, { desc = 'Resume Last Search' })
map('n', '<leader><leader>', fzf.buffers, { desc = 'Buffers' })
map('n', '<leader>/', fzf.blines, { desc = 'Fuzz Search Buffer' })
map('n', '<leader>sn', function()
    fzf.files { cwd = vim.fn.stdpath 'config' }
end, { desc = 'Neovim Files' })
