local loaded = false

local function open_diffview(cmd)
    if not loaded then
        require('diffview').setup {
            diff_bin = 'diff',
        }
        loaded = true
    end
    vim.cmd(cmd)
end

vim.keymap.set('n', '<leader>gv', function()
    open_diffview 'DiffviewOpen'
end, { desc = 'Diffview' })
