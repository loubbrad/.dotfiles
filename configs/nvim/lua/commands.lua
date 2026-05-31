local M = {}

function M.smart_split_action(callback, target_win)
  local explicit = target_win ~= nil
  local curr_win = vim.api.nvim_get_current_win()
  local curr_buf = vim.api.nvim_get_current_buf()
  local curr_pos = vim.api.nvim_win_get_cursor(0)
  local created_win

  if not target_win then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if win ~= curr_win and vim.bo[buf].filetype ~= "oil" then
        target_win = win
        break
      end
    end
  end

  if target_win then
    vim.api.nvim_set_current_win(target_win)
  else
    vim.cmd("vsplit")
    created_win = vim.api.nvim_get_current_win()
  end

  if not explicit then
    vim.api.nvim_set_current_buf(curr_buf)
    vim.api.nvim_win_set_cursor(0, curr_pos)
  end

  local ok, err = pcall(callback)
  if not ok then
    if created_win and vim.api.nvim_win_is_valid(created_win) then
      vim.api.nvim_win_close(created_win, true)
    end

    if vim.api.nvim_win_is_valid(curr_win) then
      vim.api.nvim_set_current_win(curr_win)
    end

    error(err, 0)
  end
end

function M.toggle_float(get_win, open)
  local win = get_win()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
    return
  end

  open()
end

function M.send_to_agent()
  if not os.getenv("TMUX") then
    vim.notify("Not in tmux", vim.log.levels.ERROR)
    return
  end

  local handle = io.popen("tmux list-panes -s -F '#{pane_id} #{pane_width} #{pane_height} #{pane_current_command} #{window_name}' | grep -E -w 'claude|codex'")
  local result = handle:read("*a")
  handle:close()

  local target
  local smallest_area

  for line in result:gmatch("[^\n]+") do
    local pane_id, width, height = line:match("^(%%%d+) (%d+) (%d+) ")
    if pane_id then
      local area = tonumber(width) * tonumber(height)
      if not smallest_area or area < smallest_area then
        target = pane_id
        smallest_area = area
      end
    end
  end

  if not target then
    vim.notify("No claude or codex instance found", vim.log.levels.ERROR)
    return
  end

  local file = vim.fn.expand("%:p")
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local text = string.format("%s l:%d-%d", file, start_line, end_line)

  vim.fn.system(string.format("tmux send-keys -t %s %q \\; select-window -t %s \\; select-pane -t %s", target, text, target, target))
end

function M.buf_grep(opts)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local results = vim.fn.systemlist("grep " .. opts.args, lines)

  if #results == 0 then
    vim.notify("No matches", vim.log.levels.INFO)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, results)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"
  vim.api.nvim_set_current_buf(buf)
end

function M.setup()
  vim.keymap.set("x", "<leader>cc", function()
    require("commands").send_to_agent()
  end)

  vim.api.nvim_create_user_command("BufGrep", M.buf_grep, { nargs = "+" })

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
    desc = "Briefly highlight yanked text",
    callback = function()
      vim.highlight.on_yank({ higroup = "IncSearch", timeout = 250 })
    end,
  })
end

return M
