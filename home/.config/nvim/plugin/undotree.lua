vim.cmd 'packadd nvim.undotree'

vim.keymap.set('n', '<leader>u', function()
    require('undotree').open { command = 'botright 40vnew' }
end, { desc = 'Toggle Undotree' })
