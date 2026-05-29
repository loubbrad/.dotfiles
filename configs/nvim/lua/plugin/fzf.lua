vim.pack.add({
    'https://github.com/ibhagwan/fzf-lua',
}, { confirm = false })

local fzf = require('fzf-lua')
local actions = require('fzf-lua.actions')

local function copy_abs_path(selected)
    local file = require('fzf-lua.path').entry_to_file(selected[1])
    local abs_path = vim.fn.fnamemodify(file.path, ":p")
    vim.fn.setreg("+", abs_path)
    vim.notify("Copied: " .. abs_path)
end

local function smart_split(selected, opts)
    require('commands').smart_split_action(function()
        actions.file_edit(selected, opts)
    end)
end

-- Used to manipulates splits in term mode
local function fzf_wincmd(e)
    local key = vim.fn.getcharstr()
    local valid = {
        h = true, j = true, k = true, l = true,
        H = true, J = true, K = true, L = true,
        o = true, w = true, p = true,
        ["="] = true, ["_"] = true, ["|"] = true,
        ["+"] = true, ["-"] = true, ["<"] = true, [">"] = true,
    }

    if valid[key] and vim.api.nvim_win_is_valid(e.winid) then
        vim.api.nvim_set_current_win(e.winid)
        pcall(vim.cmd, "wincmd " .. key)
    end

    vim.cmd("startinsert")
end

fzf.setup({
    {"fzf-vim"},
    winopts = {
        split = "botright 12new",
        preview = {
            border = "single",
            scrollbar = false,
        },
        on_create = function(e)
            vim.keymap.set({ "t", "n" }, "<leader>w", function()
                fzf_wincmd(e)
            end, { buffer = e.bufnr, nowait = true, silent = true })
        end,
    },
    fzf_opts = {
        ["--layout"] = "reverse",
    },
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

-- Remove ugly background
vim.api.nvim_set_hl(0, "fzf1", { fg = "#E12672", bg = "NONE" })
vim.api.nvim_set_hl(0, "fzf2", { fg = "#BCDDBD", bg = "NONE" })
vim.api.nvim_set_hl(0, "fzf3", { fg = "#D9D9D9", bg = "NONE" })

vim.keymap.set('n', '<leader>ff', fzf.files, { desc = 'Fzf Files' })
vim.keymap.set('n', '<leader>fd', fzf.diagnostics_document, { desc = 'Fzf Diagnostics' })
vim.keymap.set('n', '<leader>fg', fzf.grep, { desc = 'Fzf Grep' })
vim.keymap.set('n', '<leader>fb', fzf.buffers, { desc = 'Fzf Buffers' })
vim.keymap.set('n', '<leader>fs', fzf.git_status, { desc = 'Fzf Git Status' })
vim.keymap.set('n', '<leader>fq', fzf.quickfix, { desc = 'Fzf Quickfix' })
vim.keymap.set('n', '<leader>fr', fzf.resume, { desc = 'Fzf Resume' })
vim.keymap.set('n', '<leader>f#', fzf.grep_cword, { desc = 'Grep Word' })
vim.keymap.set('n', '<leader>:',  fzf.command_history, { desc = 'Command History' })
vim.keymap.set('n', '<leader>/',  fzf.grep_curbuf, { desc = 'Grep Current Buffer' })
vim.keymap.set('n', '<leader>?',  fzf.grep_curbuf, { desc = 'Grep Current Buffer' })
