MiniDeps.add('ibhagwan/fzf-lua')
local fzf = require('fzf-lua')
local actions = require('fzf-lua.actions')

local function copy_abs_path(selected)
    local file = require('fzf-lua.path').entry_to_file(selected[1])
    local abs_path = vim.fn.fnamemodify(file.path, ":p")
    vim.fn.setreg("+", abs_path)
    vim.notify("Copied: " .. abs_path)
end

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
            ["ctrl-y"]  = copy_abs_path,
            ["ctrl-q"]  = { fn = actions.file_sel_to_qf, prefix = "select-all+" },
        },
        grep = {
            ["default"] = actions.file_edit,
            ["ctrl-s"]  = smart_split,
            ["ctrl-y"]  = copy_abs_path,
            ["ctrl-q"]  = { fn = actions.file_sel_to_qf, prefix = "select-all+" },
        },
        buffers = {
            ["default"] = actions.file_edit,
            ["ctrl-s"]  = smart_split,
            ["ctrl-y"]  = copy_abs_path,
            ["ctrl-q"]  = { fn = actions.file_sel_to_qf, prefix = "select-all+" },
        },
        lsp = {
            ["default"] = actions.file_edit,
            ["ctrl-s"]  = smart_split,
            ["ctrl-y"]  = copy_abs_path,
            ["ctrl-q"]  = { fn = actions.file_sel_to_qf, prefix = "select-all+" },
        },
    }
})

vim.keymap.set('n', '<leader>ff', fzf.files, { desc = 'Fzf Files' })
vim.keymap.set('n', '<leader>fg', fzf.grep, { desc = 'Fzf Grep' })
vim.keymap.set('n', '<leader>fb', fzf.buffers, { desc = 'Fzf Buffers' })
vim.keymap.set('n', '<leader>fr', fzf.resume, { desc = 'Fzf Resume' })
vim.keymap.set('n', '<leader>f#', fzf.grep_cword, { desc = 'Grep Word' })
vim.keymap.set('n', '<leader>:',  fzf.command_history, { desc = 'Command History' })
