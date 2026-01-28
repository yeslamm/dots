return {
    'folke/persistence.nvim',
    event = 'BufReadPre', -- this will only start session saving when an actual file was opened
    opts = {
        -- add any custom options here
        dir = vim.fn.stdpath 'state' .. '/sessions/', -- directory where session files are saved
    },
    keys = {
        {
            '<leader>pr',
            function()
                require('persistence').load()
            end,
            desc = 'Restore Session',
        },
        {
            '<leader>ps',
            function()
                require('persistence').select()
            end,
            desc = 'Select Session',
        },
        {
            '<leader>pl',
            function()
                require('persistence').load { last = true }
            end,
            desc = 'Restore Last Session',
        },
        {
            '<leader>pd',
            function()
                require('persistence').stop()
            end,
            desc = "Don't Save Current Session",
        },
    },
}
