local config = require("gui-keymap.config")
local utils = require("gui-keymap.utils")

local M = {}

local health = vim.health

local function start(msg)
  if health and health.start then
    health.start(msg)
  end
end

local function ok(msg)
  if health and health.ok then
    health.ok(msg)
  end
end

local function warn(msg)
  if health and health.warn then
    health.warn(msg)
  end
end

local function info(msg)
  if health and health.info then
    health.info(msg)
  end
end

function M.check()
  start("gui-keymap.nvim")

  if vim.fn.has("nvim-0.8") == 1 then
    ok("Neovim version is supported")
  else
    warn("Neovim >= 0.8.0 is required")
  end

  if vim.g.loaded_gui_keymap == 1 then
    ok("plugin loaded")
  else
    warn("plugin is not loaded yet")
  end

  local plugin = require("gui-keymap")
  local validation_errors = config.validate(plugin.options)
  if #validation_errors == 0 then
    ok("configuration is valid")
  else
    warn("configuration issues: " .. table.concat(validation_errors, ", "))
  end

  local state = utils.get_state()
  if #state.conflicts == 0 then
    ok("no keymap conflicts detected")
  else
    for _, conflict in ipairs(state.conflicts) do
      warn(string.format("keymap conflict for %s in mode %s", conflict.lhs, conflict.mode))
    end
  end

  if state.yanky_available then
    if state.yanky_enabled then
      ok("yanky.nvim available and integration enabled")
    else
      info("yanky.nvim available, but integration disabled by config")
    end
  else
    info("yanky.nvim not installed (optional)")
  end
end

return M
