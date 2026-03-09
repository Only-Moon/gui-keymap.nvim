local config = require("gui-keymap.config")
local commands = require("gui-keymap.commands")
local hints = require("gui-keymap.hints")
local keymaps = require("gui-keymap.keymaps")
local info = require("gui-keymap.info")
local onboard = require("gui-keymap.onboard")
local state = require("gui-keymap.state")
local utils = require("gui-keymap.utils")

local M = {}

---@type GuiKeymapOptions
M.options = config.merge()
M._enforce_group = nil
M._setup_done = false

function M.apply()
  if not state.enabled then
    return
  end

  hints.setup(M.options)
  keymaps.apply(M.options)
end

local function schedule_enforcement_passes()
  if not M.options.enforce_on_startup then
    return
  end

  for _, delay in ipairs({ 30, 180, 600 }) do
    vim.defer_fn(function()
      M.apply()
    end, delay)
  end
end

function M.setup_enforcement_autocmds()
  if M._enforce_group then
    return
  end

  M._enforce_group = vim.api.nvim_create_augroup("GuiKeymapEnforce", { clear = true })

  vim.api.nvim_create_autocmd("User", {
    group = M._enforce_group,
    pattern = { "VeryLazy", "LazyDone" },
    callback = function()
      M.apply()
    end,
  })
end

---@param user_opts GuiKeymapOptions|nil
---@return GuiKeymapOptions
function M.setup(user_opts)
  if M._setup_done and user_opts == nil then
    return M.options
  end

  M.options = config.merge(user_opts)
  state.set_config(M.options)
  commands.setup()

  local errors = config.validate(M.options)
  if #errors > 0 then
    vim.notify("gui-keymap: invalid configuration: " .. table.concat(errors, ", "), vim.log.levels.WARN)
  end

  state.enabled = true
  M.apply()
  M.setup_enforcement_autocmds()
  schedule_enforcement_passes()
  onboard.setup(M.options)
  M._setup_done = true

  return M.options
end

function M.enable()
  if state.enabled then
    M.apply()
    vim.notify("gui-keymap: mappings are already enabled and were refreshed", vim.log.levels.INFO, {
      title = "GuiKeymapEnable",
    })
    return
  end
  state.enabled = true
  M.apply()
  vim.notify("gui-keymap: mappings enabled", vim.log.levels.INFO, { title = "GuiKeymapEnable" })
end

function M.disable()
  state.enabled = false
  utils.clear_plugin_maps()
  vim.notify("gui-keymap: mappings disabled", vim.log.levels.INFO, { title = "GuiKeymapDisable" })
end

function M.show_info()
  info.show(M.options)
end

function M.reset_hints()
  hints.reset()
end

function M.refresh()
  M.apply()
  vim.notify("gui-keymap: mappings refreshed", vim.log.levels.INFO, { title = "GuiKeymapRefresh" })
end

function M.list_keymaps()
  local lines = {}
  for _, mapping in ipairs(state.get_active_maps()) do
    table.insert(lines, string.format("[%s] %s -> %s", mapping.mode, mapping.lhs, mapping.desc))
  end

  if #lines == 0 then
    vim.notify("gui-keymap: no active mappings", vim.log.levels.INFO)
    return
  end

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "GuiKeymapList" })
end

---@param key string
function M.explain_key(key)
  local item = keymaps.explain_key(key)
  if not item then
    vim.notify("gui-keymap: no explanation found for " .. key, vim.log.levels.WARN)
    return
  end

  vim.notify(string.format("%s -> %s\nVim equivalent -> %s", key, item.gui, item.vim), vim.log.levels.INFO, {
    title = "GuiKeymapExplain",
  })
end

return M
