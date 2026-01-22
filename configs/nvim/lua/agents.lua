local M = {}

function M.send_to_claude()
  if not os.getenv("TMUX") then
    vim.notify("Not in tmux", vim.log.levels.ERROR)
    return
  end

  local handle = io.popen("tmux list-panes -s -F '#{pane_id} #{pane_current_command}' | grep -w claude")
  local result = handle:read("*a")
  handle:close()

  local panes = {}
  for pane_id in result:gmatch("(%%%d+)") do
    table.insert(panes, pane_id)
  end

  if #panes == 0 then
    vim.notify("No claude instance found", vim.log.levels.ERROR)
    return
  end
  if #panes > 1 then
    vim.notify("Multiple claude instances found", vim.log.levels.ERROR)
    return
  end

  local target = panes[1]
  local file = vim.fn.expand("%:.")
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  local text = string.format("%s l:%d-%d", file, start_line, end_line)

  vim.fn.system(string.format("tmux send-keys -t %s %q", target, text))
  vim.fn.system(string.format("tmux select-window -t %s && tmux select-pane -t %s", target, target))
end

vim.keymap.set("x", "<leader>cc", ":<C-u>lua require('agents').send_to_claude()<CR>")

return M
