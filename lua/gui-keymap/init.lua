local config = require("gui-keymap.config")
local hints = require("gui-keymap.hints")
local keymaps = require("gui-keymap.keymaps")
local info = require("gui-keymap.info")

local M = {}

---@type GuiKeymapOptions
M.options = config.merge()

---@param user_opts GuiKeymapOptions|nil
---@return GuiKeymapOptions
function M.setup(user_opts)
  M.options = config.merge(user_opts)

  local errors = config.validate(M.options)
  if #errors > 0 then
    vim.notify("gui-keymap: invalid configuration: " .. table.concat(errors, ", "), vim.log.levels.WARN)
  end

  hints.setup(M.options)
  keymaps.apply(M.options)

  return M.options
end

function M.show_info()
  info.show(M.options)
end

function M.reset_hints()
  hints.reset()
end

return M
