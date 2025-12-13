MiniDeps.add('ibhagwan/fzf-lua')
local fzf = require('fzf-lua')
local actions = require('fzf-lua.actions')

local function smart_split(selected, opts)
    _G.smart_split_action(function()
        actions.file_edit(selected, opts)
    end)
end

fzf.setup({
    actions = {
        files = {
            ["default"] = actions.file_edit, 
            ["ctrl-s"]  = smart_split,       
        },
        grep = {
            ["default"] = actions.file_edit,
            ["ctrl-s"]  = smart_split,
        },
        buffers = {
            ["default"] = actions.file_edit,
            ["ctrl-s"]  = smart_split,
        }
    }
})

vim.keymap.set('n', '<leader>ff', fzf.files, { desc = 'Fzf Files' })
vim.keymap.set('n', '<leader>fg', fzf.live_grep, { desc = 'Fzf Grep' })
vim.keymap.set('n', '<leader>fb', fzf.buffers, { desc = 'Fzf Buffers' })
vim.keymap.set('n', '<leader>f#', fzf.grep_cword, { desc = 'Grep Word' })
vim.keymap.set('n', '<leader>:',  fzf.command_history, { desc = 'Command History' })
