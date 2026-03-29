local M = {
  current = "0.12.1",
}

local path_separator = package.config:sub(1, 1)

local function path_join(...)
  local parts = { ... }
  local cleaned = {}

  for index, part in ipairs(parts) do
    if type(part) == "string" and part ~= "" then
      local current = part
      if index > 1 then
        current = current:gsub("^[/\\]+", "")
      end
      if index < #parts then
        current = current:gsub("[/\\]+$", "")
      end
      table.insert(cleaned, current)
    end
  end

  return table.concat(cleaned, path_separator)
end

local function plugin_root()
  local init_path = debug.getinfo(1, "S").source:sub(2)
  local lua_dir = vim.fn.fnamemodify(init_path, ":h")
  local root = vim.fn.fnamemodify(lua_dir, ":h:h")
  return root
end

local function git_head(root)
  if vim.fn.isdirectory(path_join(root, ".git")) ~= 1 or vim.fn.executable("git") ~= 1 then
    return nil
  end

  local result = vim.fn.systemlist({ "git", "-C", root, "rev-parse", "HEAD" })
  if vim.v.shell_error ~= 0 or type(result) ~= "table" or result[1] == nil or result[1] == "" then
    return nil
  end

  return result[1]
end

function M.identity()
  local root = plugin_root()
  return git_head(root) or M.current
end

return M
