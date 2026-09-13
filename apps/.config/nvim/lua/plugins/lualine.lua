local hide_in_width = function()
  return vim.fn.winwidth(0) > 100
end

local function lsp_clients()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ''
  end
  local names = {}
  for _, client in pairs(clients) do
    table.insert(names, client.name)
  end
  local client_str = table.concat(names, '|')
  if #client_str > 20 and not hide_in_width() then
    return ' ' .. clients[1].name
  end
  return ' ' .. client_str
end

local diagnostics = {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  sections = { 'error', 'warn', 'info', 'hint' },
  symbols = { error = '● ', warn = '● ', info = '● ', hint = '● ' },
  colored = true,
  update_in_insert = false,
  always_visible = false,
  cond = hide_in_width,
}

local diff = {
  'diff',
  colored = true,
  symbols = { added = ' ', modified = ' ', removed = ' ' },
  cond = hide_in_width,
}

require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = 'auto',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    always_divide_middle = true,
    globalstatus = true,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch' },
    lualine_c = { { 'filename', path = 3 } },
    lualine_x = {
      diagnostics,
      diff,
      lsp_clients,
      { 'filetype' },
    },
    lualine_y = { 'location' },
    lualine_z = { 'progress' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = { { 'location', padding = 0 } },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
})
