vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 3
vim.opt_local.showbreak = '  '

vim.b.minisurround_config = {
    custom_surroundings = {
        ['~'] = { input = { '~~().-()~~' }, output = { left = '~~', right = '~~' } },
        ['*'] = { input = { '%*%*().-()%*%*' }, output = { left = '**', right = '**' } },
        ['$'] = { input = { '%$().-()%$' }, output = { left = '$', right = '$' } },
    },
}
