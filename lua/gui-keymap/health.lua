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
  local conflicts = utils.get_conflicts()
  ok(
    string.format(
      "requested %d mappings, applied %d, skipped %d",
      #state.requested_maps,
      #state.active_maps,
      #state.skipped_maps
    )
  )

  if #conflicts == 0 then
    ok("no keymap conflicts detected")
  else
    local summary = utils.get_conflict_summary()
    local summary_keys = vim.tbl_keys(summary)
    table.sort(summary_keys)
    for _, feature in ipairs(summary_keys) do
      warn(string.format("conflicts for feature %s: %d", feature, summary[feature]))
    end
    for _, conflict in ipairs(conflicts) do
      warn(string.format("keymap conflict for %s in mode %s", conflict.lhs, conflict.mode))
    end
  end

  if state.yanky_available then
    if state.yanky_enabled then
      if state.yanky_loaded then
        ok("yanky.nvim available, loaded, and integration enabled")
      else
        ok("yanky.nvim installed (lazy-not-loaded) and integration enabled")
      end
    else
      if state.yanky_loaded then
        info("yanky.nvim loaded, but integration disabled by config")
      else
        info("yanky.nvim installed (lazy-not-loaded), but integration disabled by config")
      end
    end
  else
    info("yanky.nvim not installed (optional)")
  end

  if state.which_key_available then
    ok("which-key.nvim available")
  else
    info("which-key.nvim not installed (optional)")
  end

  if #state.fallback_maps > 0 then
    info(string.format("%d terminal fallback mappings active", #state.fallback_maps))
  end

  if #state.terminal_sensitive > 0 then
    info(string.format("%d terminal-sensitive mappings detected", #state.terminal_sensitive))
  end

  if plugin.options.hint_enabled then
    info(
      string.format(
        "hints enabled (repeat %d, persist %s)",
        plugin.options.hint_repeat,
        plugin.options.hint_persist and "yes" or "no"
      )
    )
  end
end

return M
