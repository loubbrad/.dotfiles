vim.pack.add({
    'https://github.com/stevearc/oil.nvim',
}, { confirm = false })

local function is_oil_win(win)
    return win
        and vim.api.nvim_win_is_valid(win)
        and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "oil"
end

local function clear_oil_drawer_state()
    vim.t.oil_prev_win = nil
    vim.t.oil_drawer_win = nil
    vim.t.oil_child_dirs = nil
end

local function close_oil_drawer()
    local win = vim.t.oil_drawer_win
    clear_oil_drawer_state()

    if not is_oil_win(win) then
        return false
    end

    if #vim.api.nvim_list_wins() == 1 then
        vim.api.nvim_set_current_win(win)
        require("oil").close()
    else
        vim.api.nvim_win_close(win, true)
    end

    return true
end

local function oil_parent()
    local dir = require("oil").get_current_dir()
    local child_dirs = vim.t.oil_child_dirs or {}
    table.insert(child_dirs, dir)
    vim.t.oil_child_dirs = child_dirs
    require("oil").open()
end

local function oil_child()
    local child_dirs = vim.t.oil_child_dirs
    local dir = child_dirs and table.remove(child_dirs)
    vim.t.oil_child_dirs = child_dirs
    if dir and vim.fn.isdirectory(dir) == 1 then
        require("oil").open(dir)
    end
end

local function oil_select(use_smart_split)
    local oil = require("oil")
    local entry = oil.get_cursor_entry()

    if not entry or entry.type == "directory" then
        vim.t.oil_child_dirs = nil
        oil.select()
        return
    end

    local path = oil.get_current_dir() .. entry.name
    local prev_win = vim.t.oil_prev_win
    local has_prev = prev_win and vim.api.nvim_win_is_valid(prev_win)
    vim.t.oil_prev_win = nil

    if #vim.api.nvim_list_wins() == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(path))
        return
    end

    if has_prev then
        vim.api.nvim_set_current_win(prev_win)
    else
        vim.cmd("wincmd p")
    end
    close_oil_drawer()

    if use_smart_split then
        require('commands').smart_split_action(function()
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
        ["-"] = { callback = oil_parent, desc = "Go to parent" },
        ["_"] = { callback = oil_child, desc = "Return to child" },
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

vim.keymap.set("n", "<leader>o", function()
    local drawer_win = vim.t.oil_drawer_win

    if is_oil_win(drawer_win) then
        local current_win = vim.api.nvim_get_current_win()
        if drawer_win == current_win then
            local prev = vim.t.oil_prev_win
            if prev and vim.api.nvim_win_is_valid(prev) then
                vim.api.nvim_set_current_win(prev)
            elseif #vim.api.nvim_list_wins() > 1 then
                vim.cmd("wincmd p")
            end
        end

        close_oil_drawer()
    else
        clear_oil_drawer_state()
        vim.t.oil_prev_win = vim.api.nvim_get_current_win()
        local current_file = vim.api.nvim_buf_get_name(0)
        local dir = vim.fn.getcwd()  -- fallback to cwd
        if current_file ~= "" then
            dir = vim.fn.fnamemodify(current_file, ":h")
        end
        vim.cmd("topleft 30vnew")
        vim.t.oil_drawer_win = vim.api.nvim_get_current_win()
        require("oil").open(dir)
    end
end)
