local is_wide = function()
    return vim.o.columns > 100
end

local function lsp_clients()
    local clients = vim.lsp.get_clients { bufnr = 0 }
    if #clients == 0 then
        return ''
    end
    local names = vim.iter(clients)
        :map(function(c)
            return c.name
        end)
        :totable()
    local client_str = table.concat(names, '|')
    if #client_str > 20 and not is_wide() then
        return ' ' .. clients[1].name
    end
    return ' ' .. client_str
end

require('lualine').setup {
    options = {
        globalstatus = true,
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch' },
        lualine_c = { { 'filename', path = 3 } },
        lualine_x = {
            {
                'diagnostics',
                symbols = { error = '● ', warn = '● ', info = '● ', hint = '● ' },
                cond = is_wide,
            },
            {
                'diff',
                symbols = { added = ' ', modified = ' ', removed = ' ' },
                cond = is_wide,
            },
            lsp_clients,
            { 'filetype' },
        },
        lualine_y = { 'location' },
        lualine_z = { 'progress' },
    },
}
