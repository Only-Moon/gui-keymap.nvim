local M = {}

---@class GuiKeymapClipboardOptions
---@field copy boolean
---@field paste boolean
---@field cut boolean

---@class GuiKeymapOptions
---@field undo_redo boolean
---@field clipboard GuiKeymapClipboardOptions|boolean
---@field select_all boolean
---@field delete_selection boolean
---@field shift_selection boolean
---@field word_delete boolean
---@field save boolean
---@field quit boolean
---@field home_end boolean
---@field yanky_integration boolean
---@field hint_enabled boolean
---@field hint_repeat integer
---@field hint_persist boolean
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
  clipboard = {
    copy = true,
    paste = true,
    cut = true,
  },
  select_all = true,
  delete_selection = true,
  shift_selection = true,
  word_delete = true,
  save = true,
  quit = true,
  home_end = true,
  yanky_integration = true,
  hint_enabled = true,
  hint_repeat = 3,
  hint_persist = true,
  which_key_integration = true,
  enforce_on_startup = true,
  force_priority = true,
  show_welcome = true,
  preserve_mode = true,
  copy = nil,
  paste = nil,
  cut = nil,
  undo = nil,
  redo = nil,
}

---@param merged GuiKeymapOptions
local function normalize_legacy_clipboard_toggles(merged)
  if type(merged.clipboard) == "boolean" then
    merged.clipboard = {
      copy = merged.clipboard,
      paste = merged.clipboard,
      cut = merged.clipboard,
    }
  end

  if merged.copy ~= nil then
    merged.clipboard.copy = merged.copy
  end

  if merged.paste ~= nil then
    merged.clipboard.paste = merged.paste
  end

  if merged.cut ~= nil then
    merged.clipboard.cut = merged.cut
  end
end

---@param merged GuiKeymapOptions
local function sanitize(merged)
  for key, default in pairs(M.defaults) do
    if key ~= "clipboard" and key ~= "copy" and key ~= "paste" and key ~= "cut" and key ~= "undo" and key ~= "redo" then
      if type(default) == "boolean" and type(merged[key]) ~= "boolean" then
        merged[key] = default
      end
    end
  end

  if type(merged.clipboard) ~= "table" then
    merged.clipboard = vim.deepcopy(M.defaults.clipboard)
  end

  for key, default in pairs(M.defaults.clipboard) do
    if type(merged.clipboard[key]) ~= "boolean" then
      merged.clipboard[key] = default
    end
  end

  if type(merged.hint_repeat) ~= "number" or (merged.hint_repeat < 0 and merged.hint_repeat ~= -1) then
    merged.hint_repeat = M.defaults.hint_repeat
  end
end

---@param user_opts GuiKeymapOptions|nil
---@return GuiKeymapOptions
function M.merge(user_opts)
  local merged = vim.tbl_deep_extend("force", {}, M.defaults, user_opts or {})
  normalize_legacy_clipboard_toggles(merged)
  sanitize(merged)
  return merged
end

local boolean_fields = {
  "undo_redo",
  "select_all",
  "delete_selection",
  "shift_selection",
  "word_delete",
  "save",
  "quit",
  "home_end",
  "yanky_integration",
  "hint_enabled",
  "hint_persist",
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

  if type(opts.clipboard) ~= "table" then
    table.insert(errors, "clipboard must be a table with copy/paste/cut booleans")
  else
    if type(opts.clipboard.copy) ~= "boolean" then
      table.insert(errors, "clipboard.copy must be boolean")
    end
    if type(opts.clipboard.paste) ~= "boolean" then
      table.insert(errors, "clipboard.paste must be boolean")
    end
    if type(opts.clipboard.cut) ~= "boolean" then
      table.insert(errors, "clipboard.cut must be boolean")
    end
  end

  if type(opts.hint_repeat) ~= "number" or (opts.hint_repeat < 0 and opts.hint_repeat ~= -1) then
    table.insert(errors, "hint_repeat must be -1 (always) or a non-negative number")
  end

  return errors
end

return M
