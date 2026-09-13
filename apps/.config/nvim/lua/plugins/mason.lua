local loaded = false

local function init_mason()
  if loaded then return end

  require('mason').setup({
    ui = {
      border = 'single',
      icons = {
        package_installed = '✓',
        package_pending = '➜',
        package_uninstalled = '✗',
      },
    },
  })

  require('mason-tool-installer').setup({
    ensure_installed = {
      'stylua',
      'shellcheck',
      'shfmt',
      'prettier',
      'stylelint',
      'clang-format',
      'csharpier',
    },
  })

  loaded = true
end

local commands = { 'Mason', 'MasonInstall', 'MasonUpdate', 'MasonUninstall', 'MasonLog' }
for _, cmd in ipairs(commands) do
  vim.api.nvim_create_user_command(cmd, function(args)
    for _, c in ipairs(commands) do
      pcall(vim.api.nvim_del_user_command, c)
    end

    init_mason()
    vim.cmd(cmd .. (args.args ~= '' and (' ' .. args.args) or ''))
  end, { bang = true, nargs = '*' })
end
