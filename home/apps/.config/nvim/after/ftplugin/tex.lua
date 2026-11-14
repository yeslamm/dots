vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.wrap = true
vim.opt_local.linebreak = true

vim.b.minisurround_config = {
    custom_surroundings = {
        ['~'] = { input = { '~~().-()~~' }, output = { left = '~~', right = '~~' } },
        ['*'] = { input = { '%*%*().-()%*%*' }, output = { left = '**', right = '**' } },
        ['$'] = { input = { '%$().-()%$' }, output = { left = '$', right = '$' } },
    },
}
