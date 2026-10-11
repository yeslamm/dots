vim.g.vimtex_view_method = 'zathura_simple'
vim.g.vimtex_quickfix_open_on_warning = 0
vim.g.vimtex_compiler_latexmk = {
    out_dir = '.texbuild',
    options = { '-verbose', '-file-line-error', '-synctex=1', '-interaction=nonstopmode' },
}
