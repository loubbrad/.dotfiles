MiniDeps.add('lewis6991/gitsigns.nvim')
local gitsigns = require('gitsigns')

gitsigns.setup({
    signs = {
        add = { text = '│' },
        change = { text = '│' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
    }
})

local function next_hunk()
    if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
    else
        gitsigns.next_hunk()
    end
end

local function prev_hunk()
    if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
    else
        gitsigns.prev_hunk()
    end
end

vim.keymap.set('n', ']h', next_hunk, { desc = 'Next Hunk' })
vim.keymap.set('n', '[h', prev_hunk, { desc = 'Prev Hunk' })
vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Preview Hunk' })
vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Revert Hunk' })
vim.keymap.set('n', '<leader>hd', gitsigns.diffthis, { desc = 'Diff This' })
vim.keymap.set('n', '<leader>hq', function()
  gitsigns.setqflist(0, { open = true })
end)

