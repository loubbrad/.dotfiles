vim.pack.add({
    'https://github.com/stevearc/oil.nvim',
}, { confirm = false })

local oil = require("oil")

local function oil_parent()
    local dir = oil.get_current_dir()
    local child_dirs = vim.t.oil_child_dirs or {}
    table.insert(child_dirs, dir)
    vim.t.oil_child_dirs = child_dirs
    oil.open()
end

local function oil_child()
    local child_dirs = vim.t.oil_child_dirs
    local dir = child_dirs and table.remove(child_dirs)
    vim.t.oil_child_dirs = child_dirs
    if dir and vim.fn.isdirectory(dir) == 1 then
        oil.open(dir)
    end
end

local function oil_select(use_smart_split)
    local entry = oil.get_cursor_entry()
    vim.t.oil_child_dirs = nil

    if not use_smart_split or not entry or entry.type == "directory" then
        oil.select()
        return
    end

    oil.select({
        handle_buffer_callback = function(bufnr)
            require("commands").smart_split_action(function()
                vim.api.nvim_set_current_buf(bufnr)
            end)
        end,
    })
end

oil.setup({
    default_file_explorer = true,
    view_options = { show_hidden = true },
    float = {
        padding = 0,
        border = "none",
        override = function(conf)
            conf.row = 0
            conf.col = 0
            conf.width = vim.o.columns
            conf.height = vim.o.lines - vim.o.cmdheight
            conf.style = "minimal"
            return conf
        end,
    },
    keymaps = {
        ["<CR>"] = { callback = function() oil_select(false) end, desc = "Open file" },
        ["<C-s>"] = { callback = function() oil_select(true) end, desc = "Open in split" },
        ["-"] = { callback = oil_parent, desc = "Go to parent" },
        ["_"] = { callback = oil_child, desc = "Return to child" },
        ["<C-y>"] = {
            callback = function()
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
                vim.t.oil_child_dirs = nil
                oil.open(vim.fn.getcwd())
            end,
            desc = "Go to root (cwd)"
        },
    }
})

vim.keymap.set("n", "<leader>o", function()
    vim.t.oil_child_dirs = nil

    if vim.w.is_oil_win then
        oil.close()
        return
    end

    local current_file = vim.api.nvim_buf_get_name(0)
    local dir = current_file ~= "" and vim.fn.fnamemodify(current_file, ":h") or vim.fn.getcwd()
    oil.open_float(dir)
end)
