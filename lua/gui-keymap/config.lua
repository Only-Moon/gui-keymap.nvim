---@class GuiKeymapOptions
---@field undo_redo boolean
---@field clipboard boolean
---@field select_all boolean
---@field delete_selection boolean
---@field shift_selection boolean
---@field yanky_integration boolean
---@field hint_enabled boolean
---@field hint_repeat integer
---@field which_key_integration boolean
---@field copy boolean|nil
---@field paste boolean|nil
---@field cut boolean|nil
---@field undo boolean|nil
---@field redo boolean|nil

local M = {}

---@type GuiKeymapOptions
M.defaults = {
  undo_redo = true,
  clipboard = true,
  select_all = true,
  delete_selection = true,
  shift_selection = true,
  yanky_integration = true,
  hint_enabled = true,
  hint_repeat = 3,
  which_key_integration = true,
  copy = nil,
  paste = nil,
  cut = nil,
  undo = nil,
  redo = nil,
}

---@param user_opts GuiKeymapOptions|nil
---@return GuiKeymapOptions
function M.merge(user_opts)
  return vim.tbl_deep_extend("force", {}, M.defaults, user_opts or {})
end

---@param opts GuiKeymapOptions
---@return string[]
function M.validate(opts)
  local errors = {}

  if type(opts.hint_enabled) ~= "boolean" then
    table.insert(errors, "hint_enabled must be boolean")
  end

  if type(opts.hint_repeat) ~= "number" or (opts.hint_repeat < 0 and opts.hint_repeat ~= -1) then
    table.insert(errors, "hint_repeat must be -1 (always) or a non-negative number")
  end

  return errors
end

return M
