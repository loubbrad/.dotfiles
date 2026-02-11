MiniDeps.add('stevearc/oil.nvim')

local function oil_select(use_smart_split)
    local oil = require("oil")
    local entry = oil.get_cursor_entry()

    if not entry or entry.type == "directory" then
        oil.select()
        return
    end

    local path = oil.get_current_dir() .. entry.name
    local oil_win = vim.api.nvim_get_current_win()
    local prev_win = vim.g.oil_prev_win
    local has_prev = prev_win and vim.api.nvim_win_is_valid(prev_win)
    vim.g.oil_prev_win = nil

    if #vim.api.nvim_list_wins() == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(path))
        return
    end

    if has_prev then
        vim.api.nvim_set_current_win(prev_win)
    else
        vim.cmd("wincmd p")
    end
    vim.api.nvim_win_close(oil_win, true)

    if use_smart_split then
        _G.smart_split_action(function()
            vim.cmd("edit " .. vim.fn.fnameescape(path))
        end)
    else
        vim.cmd("edit " .. vim.fn.fnameescape(path))
    end
end

require("oil").setup({
    default_file_explorer = true,
    view_options = { show_hidden = true },
    keymaps = {
        ["<CR>"] = { callback = function() oil_select(false) end, desc = "Open file" },
        ["<C-s>"] = { callback = function() oil_select(true) end, desc = "Open in split" },
        ["<C-y>"] = {
            callback = function()
                local oil = require("oil")
                local entry = oil.get_cursor_entry()
                if entry then
                    local path = oil.get_current_dir() .. entry.name
                    vim.fn.setreg("+", path)
                    vim.notify(path)
                end
            end,
            desc = "Yank file path"
        },
        ["<C-r>"] = {
            callback = function()
                require("oil").open(vim.fn.getcwd())
            end,
            desc = "Go to root (cwd)"
        },
    }
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>")

vim.keymap.set("n", "<leader>o", function()
    local oil_wins = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == 'oil' then
            table.insert(oil_wins, win)
        end
    end

    if #oil_wins > 0 then
        local current_win = vim.api.nvim_get_current_win()
        for _, win in ipairs(oil_wins) do
            if win == current_win then
                vim.cmd("wincmd p")
                break
            end
        end
        for _, win in ipairs(oil_wins) do
            vim.api.nvim_win_close(win, true)
        end
    else
        vim.g.oil_prev_win = vim.api.nvim_get_current_win()
        local current_file = vim.api.nvim_buf_get_name(0)
        local dir = vim.fn.getcwd()  -- fallback to cwd
        if current_file ~= "" then
            dir = vim.fn.fnamemodify(current_file, ":h")
        end
        vim.cmd("topleft 30vnew")
        require("oil").open(dir)
    end
end)
