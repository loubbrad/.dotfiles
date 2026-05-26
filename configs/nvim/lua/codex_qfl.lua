local M = {}

local function registry_dir()
  local base = vim.env.XDG_RUNTIME_DIR
  if base and base ~= "" then
    return base .. "/codex-qfl-nvim"
  end
  return "/tmp/codex-qfl-nvim-" .. (vim.env.USER or "user")
end

local function registry_path()
  local pane = vim.env.TMUX_PANE
  if not pane or pane == "" then
    return nil
  end
  return registry_dir() .. "/" .. pane .. ".json"
end

local registered_path

local function write_registry()
  local path = registry_path()
  if not path or vim.v.servername == "" then
    return
  end

  vim.fn.mkdir(registry_dir(), "p", 448)
  vim.fn.writefile({
    vim.json.encode({
      server = vim.v.servername,
    }),
  }, path)
  registered_path = path
end

local function remove_registry()
  if registered_path then
    os.remove(registered_path)
  end
end

function M.setup()
  write_registry()
  vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
    callback = write_registry,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = remove_registry,
  })
end

return M
