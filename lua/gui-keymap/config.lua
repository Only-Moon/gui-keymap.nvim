local M = {}

---@class GuiKeymapOptions
---@field undo_redo boolean
---@field clipboard boolean
---@field select_all boolean
---@field delete_selection boolean
---@field shift_selection boolean
---@field word_delete boolean
---@field yanky_integration boolean
---@field hint_enabled boolean
---@field hint_repeat integer
---@field which_key_integration boolean
---@field enforce_on_startup boolean
---@field force_priority boolean
---@field show_welcome boolean
---@field preserve_mode boolean
---@field copy boolean|nil
---@field paste boolean|nil
---@field cut boolean|nil
---@field undo boolean|nil
---@field redo boolean|nil

---@type GuiKeymapOptions
M.defaults = {
  undo_redo = true,
  clipboard = true,
  select_all = true,
  delete_selection = true,
  shift_selection = true,
  word_delete = true,
  yanky_integration = true,
  hint_enabled = true,
  hint_repeat = 3,
  which_key_integration = true,
  enforce_on_startup = true,
  force_priority = true,
  show_welcome = false,
  preserve_mode = true,
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

local boolean_fields = {
  "undo_redo",
  "clipboard",
  "select_all",
  "delete_selection",
  "shift_selection",
  "word_delete",
  "yanky_integration",
  "hint_enabled",
  "which_key_integration",
  "enforce_on_startup",
  "force_priority",
  "show_welcome",
  "preserve_mode",
}

---@param opts GuiKeymapOptions
---@return string[]
function M.validate(opts)
  local errors = {}

  for _, key in ipairs(boolean_fields) do
    if type(opts[key]) ~= "boolean" then
      table.insert(errors, key .. " must be boolean")
    end
  end

  if type(opts.hint_repeat) ~= "number" or (opts.hint_repeat < 0 and opts.hint_repeat ~= -1) then
    table.insert(errors, "hint_repeat must be -1 (always) or a non-negative number")
  end

  return errors
end

return M
