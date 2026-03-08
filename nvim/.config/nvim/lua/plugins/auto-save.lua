return {
    'okuuva/auto-save.nvim',
    version = '^1.0.0',
    opts = {
        enabled = true,
        trigger_events = {
            immediate_save = { 'BufLeave', 'FocusLost' },
            defer_save = { 'InsertLeave', 'TextChanged' },
            cancel_deferred_save = { 'InsertEnter' },
        },
        condition = function(buf)
            local fn = vim.fn
            local utils = require('auto-save.utils.data')
            if fn.getbufvar(buf, '&modifiable') ~= 1 then
                return false
            end
            local excluded_filetypes = {
                'oil',
                'NvimTree',
                'TelescopePrompt',
                'lazy',
                'mason',
                'harpoon',
                'gitcommit',
                'TelescopeResults',
            }
            if utils.not_in(fn.getbufvar(buf, '&filetype'), excluded_filetypes) then
                return true
            end
            return false
        end,
        write_all_buffers = false,
        noautocmd = false,
        debounce_delay = 1000,
    },
    keys = {
        {
            '<leader>n',
            function()
                local autosave = require 'auto-save'
                autosave.toggle()
                -- Track state globally since the plugin doesn't expose it easily
                if vim.g.autosave_enabled == nil then
                    vim.g.autosave_enabled = true
                end
                vim.g.autosave_enabled = not vim.g.autosave_enabled

                local status = vim.g.autosave_enabled and 'Enabled' or 'Disabled'
                local icon = vim.g.autosave_enabled and '󰄬' or '󰅖'
                vim.notify('Auto-save ' .. status, vim.log.levels.INFO, {
                    title = 'Auto-Save',
                    icon = icon,
                })
            end,
            desc = 'Toggle Auto-save',
        },
    },
}
