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

local plenary_dir = os.getenv("PLENARY_DIR") or path_join(vim.fn.stdpath("data"), "plenary.nvim")
local is_not_a_directory = vim.fn.isdirectory(plenary_dir) == 0

if is_not_a_directory then
  vim.fn.system({ "git", "clone", "https://github.com/nvim-lua/plenary.nvim", plenary_dir })
end

vim.opt.rtp:append(".")
vim.opt.rtp:append(plenary_dir)

vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")
