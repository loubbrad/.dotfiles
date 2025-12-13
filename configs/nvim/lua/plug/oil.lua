MiniDeps.add('stevearc/oil.nvim')

local function smart_enter()
    local oil = require("oil")
    local entry = oil.get_cursor_entry()

    vim.cmd("edit " .. vim.fn.fnameescape(path))
end

require("oil").setup({
    default_file_explorer = true,
    view_options = { show_hidden = true },
    keymaps = {
        ["<CR>"] = { callback = smart_enter, desc = "Smart Open" },
    }
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>")
vim.keymap.set("n", "<leader>o", function()
    vim.cmd("vsplit | wincmd H | vertical resize 30 | Oil")
end)

vim.keymap.set('n', '<leader>q', function()
    vim.cmd('cclose')
    local current_win = vim.api.nvim_get_current_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == 'oil' then
            if win == current_win then
                vim.cmd("wincmd p") 
            end
            vim.api.nvim_win_close(win, true)
        end
    end
end)

