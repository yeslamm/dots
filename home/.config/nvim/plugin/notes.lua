local notes_dir = vim.fn.expand '~/notes'
local map = vim.keymap.set

local function open_note(rel_path, heading)
    local full_path = notes_dir .. '/' .. rel_path
    vim.fn.mkdir(vim.fn.fnamemodify(full_path, ':h'), 'p')
    vim.cmd.edit(full_path)

    if vim.fn.getfsize(full_path) <= 0 then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { '# ' .. heading, '' })
        vim.cmd.write()
    end
end

map('n', '<leader>nd', function()
    open_note('dailies/' .. os.date '%Y-%m-%d' .. '.md', os.date '%a, %b %d')
end, { desc = "Today's note" })

map('n', '<leader>nb', function()
    open_note('backlog.md', 'Backlog')
end, { desc = 'Backlog note' })

map('n', '<leader>ns', function()
    vim.system({ vim.fn.expand '~/.local/bin/notes-sync' }, {}, function(out)
        vim.schedule(function()
            if out.code == 0 then
                vim.notify('Notes synced!', vim.log.levels.INFO)
            else
                vim.notify('Notes sync failed:\n' .. (out.stderr or ''), vim.log.levels.ERROR)
            end
        end)
    end)
end, { desc = 'Sync notes' })

map('n', '<leader>nf', function()
    require('fzf-lua').files { cwd = notes_dir }
end, { desc = 'Find notes' })

map('n', '<leader>ng', function()
    require('fzf-lua').live_grep { cwd = notes_dir }
end, { desc = 'Grep notes' })
