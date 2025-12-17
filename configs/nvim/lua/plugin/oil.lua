MiniDeps.add('stevearc/oil.nvim')

local function smart_enter()
    local oil = require("oil")
    local entry = oil.get_cursor_entry()

    if not entry or entry.type == "directory" then
        oil.select()
        return
    end

    local path = oil.get_current_dir() .. entry.name
    local target_win = vim.g.oil_prev_win

    if not target_win or not vim.api.nvim_win_is_valid(target_win) then
        target_win = nil 
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if win ~= vim.api.nvim_get_current_win() then
                target_win = win
                break
            end
        end
    end

    if target_win then
        vim.api.nvim_set_current_win(target_win)
        vim.g.oil_prev_win = nil 
    end

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
    if vim.api.nvim_buf_get_option(0, "filetype") ~= "oil" then
        vim.g.oil_prev_win = vim.api.nvim_get_current_win()
    end

    local oil_win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == 'oil' then
            oil_win = win
            break
        end
    end

    if oil_win then
        vim.api.nvim_set_current_win(oil_win)
    else
        vim.cmd("topleft 30vnew | Oil")
    end
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
