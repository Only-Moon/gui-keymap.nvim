local config = require("gui-keymap.config")
local keymaps = require("gui-keymap.keymaps")

local M = {}

---@type GuiKeymapOptions
M.options = config.merge()

---@param user_opts GuiKeymapOptions|nil
---@return GuiKeymapOptions
function M.setup(user_opts)
  M.options = config.merge(user_opts)
  keymaps.apply(M.options)
  return M.options
end

return M
