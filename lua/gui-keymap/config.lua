---@class GuiKeymapOptions
---@field copy boolean
---@field paste boolean
---@field cut boolean
---@field select_all boolean
---@field undo boolean
---@field redo boolean

local M = {}

---@type GuiKeymapOptions
M.defaults = {
  copy = true,
  paste = true,
  cut = true,
  select_all = true,
  undo = true,
  redo = true,
}

---@param user_opts GuiKeymapOptions|nil
---@return GuiKeymapOptions
function M.merge(user_opts)
  return vim.tbl_deep_extend("force", {}, M.defaults, user_opts or {})
end

return M
