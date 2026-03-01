local M = {}

local function esc(text)
  return text:gsub("%%", "%%%%")
end

local function split_path(path)
  local parts = {}

  for part in path:gmatch("[^/]+") do
    table.insert(parts, part)
  end

  return parts
end

local function suffix_path(path, depth)
  local parts = split_path(path)
  local start = math.max(1, #parts - depth + 1)

  return table.concat(parts, "/", start)
end

local function unique_labels(marks)
  local labels = {}
  local base_labels = {}
  local groups = {}
  local path_groups = {}

  for index, mark in ipairs(marks) do
    local basename = vim.fn.fnamemodify(mark.file, ":t")
    labels[index] = basename
    base_labels[index] = basename
    groups[basename] = groups[basename] or {}
    table.insert(groups[basename], index)
    path_groups[mark.file] = path_groups[mark.file] or {}
    table.insert(path_groups[mark.file], index)
  end

  for _, indices in pairs(groups) do
    if #indices > 1 then
      local unique_paths = {}
      for _, index in ipairs(indices) do
        unique_paths[marks[index].file] = true
      end

      if vim.tbl_count(unique_paths) > 1 then
        local depth = 2

        while true do
          local seen = {}
          local duplicate = false

          for _, index in ipairs(indices) do
            labels[index] = suffix_path(marks[index].file, depth)
            base_labels[index] = labels[index]
            if seen[labels[index]] then
              duplicate = true
            end
            seen[labels[index]] = true
          end

          if not duplicate then
            break
          end

          depth = depth + 1

          if depth > 12 then
            break
          end
        end
      end
    end
  end

  for _, indices in pairs(path_groups) do
    if #indices > 1 then
      local seen = {}

      for _, index in ipairs(indices) do
        local mark = marks[index]
        local line = mark.line or 0
        local key = tostring(line)

        if seen[key] then
          labels[index] = string.format("%s %d,%d", base_labels[index], line, mark.col or 0)
          local previous = seen[key]
          local previous_mark = marks[previous]
          labels[previous] = string.format("%s %d,%d", base_labels[previous], previous_mark.line or 0, previous_mark.col or 0)
        else
          labels[index] = string.format("%s %d", base_labels[index], line)
          seen[key] = index
        end
      end
    end
  end

  return labels
end

local function marks_label()
  local marks = {}

  for _, mark in ipairs(vim.fn.getmarklist()) do
    local name = mark.mark:sub(2)
    local file = mark.file and vim.fn.fnamemodify(mark.file, ":p") or ""

    if name:match("^%u$") and file ~= "" then
      table.insert(marks, {
        name = name,
        file = file,
        line = mark.pos and mark.pos[2] or 0,
        col = mark.pos and mark.pos[3] or 0,
      })
    end
  end

  if #marks == 0 then
    return ""
  end

  local labels = unique_labels(marks)
  local parts = {}

  -- Neovim does not expose mark age, so the built-in global mark order is used.
  for index, mark in ipairs(marks) do
    local sep = index < #marks and " " or ""
    table.insert(parts, esc(mark.name) .. ":" .. esc(labels[index]) .. sep)
  end

  return table.concat(parts)
end

function M.render()
  local left = marks_label()

  return table.concat({
    left,
    "%=",
    "%<",
    "%(%l,%c%V%)",
    " ",
    "%f",
    " ",
    "%h%w%m%r",
  })
end

function M.setup()
  vim.api.nvim_set_hl(0, "StatusLine", { link = "Normal" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { link = "Normal" })
  vim.o.statusline = "%!v:lua.require('statusline').render()"
end

return M
