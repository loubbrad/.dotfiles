local function emit(value, code)
  io.stdout:write(vim.json.encode(value), "\n")
  os.exit(code or 0)
end

local function shell_quote(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function vim_quote(s)
  return "'" .. tostring(s):gsub("'", "''") .. "'"
end

local function trim(s)
  return (s or ""):match("^%s*(.-)%s*$")
end

local function sh(cmd)
  local f = assert(io.popen(cmd .. " 2>&1"))
  local out = f:read("*a")
  local ok, _, code = f:close()
  return ok, out, code
end

local function parse_nonnegative(value, name)
  if value == nil then
    return nil
  end
  if not tostring(value):match("^%d+$") then
    emit({ ok = false, error = name .. " must be a non-negative integer" }, 2)
  end
  return tonumber(value)
end

local function parse_args()
  local command = arg[1] or "server"

  local opts = { command = command }

  for i = 2, #arg do
    local a = arg[i]
    local key, value = a:match("^%-%-([^=]+)=(.*)$")
    if key then
      key = key:gsub("_", "-")
      if key == "modify-prev" then
        opts.modify_prev = parse_nonnegative(value, "--modify-prev")
      elseif key == "prev" then
        opts.prev = parse_nonnegative(value, "--prev")
      else
        emit({ ok = false, error = "unknown option: --" .. key }, 2)
      end
    else
      emit({ ok = false, error = "unexpected positional argument: " .. tostring(a) }, 2)
    end
  end

  if command == "write" then
    return opts
  elseif command == "read" then
    if opts.prev == nil then
      opts.prev = 0
    end
    return opts
  elseif command ~= "server" then
    emit({ ok = false, error = "unknown command: " .. tostring(command) }, 2)
  end

  return opts
end

local function find_server()
  local roots = {}
  local _, roots_out = sh("tmux list-panes -s -F '#{pane_pid}'")
  for pid in roots_out:gmatch("%d+") do
    roots[pid] = true
  end
  if next(roots) == nil then
    emit({ ok = false, error = "no tmux panes found for the current session" }, 1)
  end

  local procs = {}
  local _, ps_out = sh("ps -eo pid=,ppid=,comm=,args=")
  for line in ps_out:gmatch("[^\n]+") do
    local pid, ppid, comm, args = line:match("^%s*(%d+)%s+(%d+)%s+(%S+)%s+(.*)$")
    if pid then
      procs[pid] = { ppid = ppid, comm = comm, args = args }
    end
  end

  local function in_session(pid)
    while pid and procs[pid] do
      if roots[pid] then
        return true
      end
      pid = procs[pid].ppid
    end
    return false
  end

  local user = os.getenv("USER")
  if not user then
    emit({ ok = false, error = "USER is not set" }, 1)
  end

  local sockets = {}
  local _, socket_out = sh(("find %s -type s -name 'nvim.*.0' 2>/dev/null"):format(shell_quote("/tmp/nvim." .. user)))
  for s in socket_out:gmatch("[^\n]+") do
    sockets[s:match("nvim%.(%d+)%.0$")] = s
  end

  local pids = {}
  for pid in pairs(procs) do
    pids[#pids + 1] = pid
  end
  table.sort(pids, function(a, b)
    return tonumber(a) < tonumber(b)
  end)

  for _, pid in ipairs(pids) do
    local p = procs[pid]
    if p.comm == "nvim" and p.args:match("%-%-embed") and in_session(pid) and sockets[pid] then
      return sockets[pid]
    end
  end

  emit({ ok = false, error = "no Neovim server found in the current tmux session" }, 1)
end

local function decode_entries(input)
  input = trim(input)
  if input == "" then
    emit({ ok = false, error = "write expects NDJSON quickfix entries on stdin" }, 2)
  end

  local entries = {}
  for line in input:gmatch("[^\n]+") do
    line = trim(line)
    if line ~= "" then
      local ok, decoded = pcall(vim.json.decode, line)
      if not ok or type(decoded) ~= "table" then
        emit({ ok = false, error = "stdin must be NDJSON quickfix objects", line = line }, 2)
      end
      if decoded[1] ~= nil then
        emit({ ok = false, error = "stdin must be NDJSON quickfix objects, not arrays" }, 2)
      end
      entries[#entries + 1] = decoded
    end
  end

  for i, item in ipairs(entries) do
    if type(item) ~= "table" then
      emit({ ok = false, error = "quickfix entry is not an object", index = i }, 2)
    end
    for _, key in ipairs({ "lnum", "col", "end_lnum", "end_col", "nr", "valid", "vcol" }) do
      if type(item[key]) == "string" and item[key]:match("^%d+$") then
        item[key] = tonumber(item[key])
      end
    end
  end

  return entries
end

local function write_file(path, text)
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local function remote_source(request_path)
  local source = [=[
local function history()
  local current = vim.fn.getqflist({ nr = 0 }).nr or 0
  local last = vim.fn.getqflist({ nr = "$" }).nr or current
  return {
    current = current,
    last = last,
    total = last,
    older = math.max(current - 1, 0),
    newer = math.max(last - current, 0),
  }
end

local function move_older(prev)
  local h = history()
  if prev > h.older then
    return false, {
      ok = false,
      error = ("quickfix history has %d list(s); current list is %d, so only %d older list(s) are available"):format(h.total, h.current, h.older),
      requested_prev = prev,
      history = h,
    }
  end
  if prev > 0 then
    vim.cmd("colder " .. prev)
  end
  return true, h
end

local function restore(target)
  local h = history()
  local delta = target - h.current
  if delta > 0 then
    return pcall(vim.cmd, "cnewer " .. delta)
  elseif delta < 0 then
    return pcall(vim.cmd, "colder " .. -delta)
  end
  return true
end

local function list_meta()
  local qf = vim.fn.getqflist({ nr = 0, id = 0, title = 1, idx = 1, size = 1 })
  return { nr = qf.nr, id = qf.id, title = qf.title, idx = qf.idx, size = qf.size }
end

local function list_items()
  local qf = vim.fn.getqflist({ nr = 0, id = 0, title = 1, idx = 0, size = 1, items = 1 })
  for _, item in ipairs(qf.items or {}) do
    if item.bufnr and item.bufnr > 0 and not item.filename then
      local name = vim.api.nvim_buf_get_name(item.bufnr)
      if name ~= "" then
        item.filename = name
      end
    end
  end
  return {
    nr = qf.nr,
    id = qf.id,
    title = qf.title,
    idx = qf.idx,
    size = qf.size,
    items = qf.items or {},
  }
end

local function main()
  local request = vim.json.decode(table.concat(vim.fn.readfile(__REQUEST_PATH__), "\n"))
  if request.op == "read" then
    local prev = request.prev or 0
    local original = history().current
    local ok, err = move_older(prev)
    if not ok then
      err.op = "read"
      return err
    end

    local qf = list_items()
    local restore_ok, restore_err = restore(original)
    local restore_error
    if not restore_ok then
      restore_error = tostring(restore_err)
    end
    return {
      ok = true,
      op = "read",
      server = request.server,
      prev = prev,
      count = #qf.items,
      list = qf,
      history = history(),
      restored = restore_ok,
      restore_error = restore_error,
    }
  end

  if request.op == "write" then
    local items = request.items or {}
    if request.modify_prev == nil then
      vim.fn.setqflist({}, " ", { title = "Codex", items = items })
      return {
        ok = true,
        op = "write",
        server = request.server,
        created = true,
        count = #items,
        list = list_meta(),
        history = history(),
      }
    end

    local original = history().current
    local ok, err = move_older(request.modify_prev)
    if not ok then
      err.op = "write"
      return err
    end

    vim.fn.setqflist({}, "r", { title = "Codex", items = items })
    local modified = list_meta()
    local restore_ok, restore_err = restore(original)
    local restore_error
    if not restore_ok then
      restore_error = tostring(restore_err)
    end
    return {
      ok = true,
      op = "write",
      server = request.server,
      created = false,
      modified_prev = request.modify_prev,
      count = #items,
      list = modified,
      history = history(),
      restored = restore_ok,
      restore_error = restore_error,
    }
  end

  return { ok = false, error = "unknown remote op: " .. tostring(request.op) }
end

local ok, result = pcall(main)
if ok then
  return result
end
return { ok = false, error = tostring(result) }
]=]
  return source:gsub("__REQUEST_PATH__", vim_quote(request_path))
end

local function remote_eval(server, request)
  local request_path = os.tmpname()
  local script_path = os.tmpname()
  write_file(request_path, vim.json.encode(request))
  write_file(script_path, remote_source(request_path))

  local nvim = vim.v.progpath ~= "" and vim.v.progpath or "nvim"
  local expr = ("json_encode(luaeval('dofile(_A)', %s))"):format(vim_quote(script_path))
  local ok, out = sh(("%s --server %s --remote-expr %s"):format(shell_quote(nvim), shell_quote(server), shell_quote(expr)))

  os.remove(request_path)
  os.remove(script_path)

  out = trim(out)
  if not ok then
    emit({ ok = false, error = "remote Neovim call failed", output = out }, 1)
  end

  local decoded_ok, decoded = pcall(vim.json.decode, out)
  if not decoded_ok or type(decoded) ~= "table" then
    emit({ ok = false, error = "remote Neovim returned non-JSON output", output = out }, 1)
  end

  io.stdout:write(out, "\n")
  os.exit(decoded.ok == false and 1 or 0)
end

local opts = parse_args()
local server = find_server()

if opts.command == "server" then
  emit({ ok = true, op = "server", server = server })
end

if opts.command == "read" then
  remote_eval(server, { op = "read", server = server, prev = opts.prev })
end

if opts.command == "write" then
  remote_eval(server, {
    op = "write",
    server = server,
    modify_prev = opts.modify_prev,
    items = decode_entries(io.read("*a")),
  })
end
