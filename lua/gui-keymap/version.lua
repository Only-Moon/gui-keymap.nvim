local M = {
  current = "0.12.1",
}

local function plugin_root()
  local init_path = debug.getinfo(1, "S").source:sub(2)
  local lua_dir = vim.fn.fnamemodify(init_path, ":h")
  local root = vim.fn.fnamemodify(lua_dir, ":h:h")
  return root
end

local function git_head(root)
  if vim.fn.isdirectory(root .. "/.git") ~= 1 or vim.fn.executable("git") ~= 1 then
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
