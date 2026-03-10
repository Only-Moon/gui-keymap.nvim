local utils = require("gui-keymap.utils")

local M = {}

local function sorted_summary(summary)
  local lines = {}
  local keys = vim.tbl_keys(summary)
  table.sort(keys)
  for _, key in ipairs(keys) do
    table.insert(lines, string.format("- %s: %d", key, summary[key]))
  end
  return lines
end

---@param opts GuiKeymapOptions
---@return string[]
local function build_lines(opts)
  local state = utils.get_state()
  local lines = {
    "Active GUI keymaps: " .. tostring(#state.active_maps),
    "Requested GUI keymaps: " .. tostring(#state.requested_maps),
    "Skipped GUI keymaps: " .. tostring(#state.skipped_maps),
  }

  table.insert(lines, "Disabled features:")
  local disabled = {}
  for feature, is_disabled in pairs(state.disabled_features) do
    if is_disabled then
      table.insert(disabled, "- " .. feature)
    end
  end

  if #disabled == 0 then
    table.insert(lines, "- none")
  else
    vim.list_extend(lines, disabled)
  end

  table.insert(lines, "")
  local conflicts = utils.get_conflicts()
  table.insert(lines, "Conflicts: " .. tostring(#conflicts))
  for _, conflict in ipairs(conflicts) do
    table.insert(
      lines,
      string.format(
        "- [%s] %s (%s)",
        conflict.mode,
        conflict.lhs,
        conflict.existing_desc ~= "" and conflict.existing_desc or "preexisting map"
      )
    )
  end

  local summary = utils.get_conflict_summary()
  table.insert(lines, "")
  table.insert(lines, "Conflict summary by feature:")
  local summary_lines = sorted_summary(summary)
  if #summary_lines == 0 then
    table.insert(lines, "- none")
  else
    vim.list_extend(lines, summary_lines)
  end

  table.insert(lines, "")
  table.insert(lines, "Fallback mappings: " .. tostring(#state.fallback_maps))
  for _, mapping in ipairs(state.fallback_maps) do
    table.insert(lines, string.format("- [%s] %s", mapping.mode, mapping.lhs))
  end

  table.insert(lines, "")
  table.insert(lines, "Terminal-sensitive mappings: " .. tostring(#state.terminal_sensitive))
  for _, mapping in ipairs(state.terminal_sensitive) do
    table.insert(lines, string.format("- [%s] %s", mapping.mode, mapping.lhs))
  end

  table.insert(lines, "")
  local yanky_status
  if not state.yanky_available then
    yanky_status = "not installed"
  elseif state.yanky_enabled then
    yanky_status = state.yanky_loaded and "enabled (loaded)" or "enabled (installed, lazy-not-loaded)"
  else
    yanky_status = state.yanky_loaded and "disabled by config (loaded)" or "disabled by config (installed)"
  end
  table.insert(lines, "Yanky integration: " .. yanky_status)
  table.insert(lines, "which-key integration: " .. (state.which_key_available and "available" or "not installed"))
  table.insert(
    lines,
    "Hints: "
      .. ((opts.hint_enabled and "enabled") or "disabled")
      .. string.format(" (repeat: %d, persist: %s)", opts.hint_repeat, opts.hint_persist and "yes" or "no")
  )

  table.insert(lines, "Hint feature toggles:")
  local hint_lines = {}
  local hint_keys = vim.tbl_keys(opts.hint_features or {})
  table.sort(hint_keys)
  for _, key in ipairs(hint_keys) do
    table.insert(hint_lines, string.format("- %s: %s", key, opts.hint_features[key] and "on" or "off"))
  end
  if #hint_lines == 0 then
    table.insert(lines, "- none")
  else
    vim.list_extend(lines, hint_lines)
  end

  return lines
end

function M.open_report(opts)
  local lines = build_lines(opts)
  utils.open_scratch_window("gui-keymap.nvim", lines, "gui-keymap-info")
end

function M.open_keymap_list()
  local state = utils.get_state()
  local lines = {}

  for _, mapping in ipairs(state.get_active_maps()) do
    table.insert(lines, string.format("[%s] %s -> %s", mapping.mode, mapping.lhs, mapping.desc))
  end

  if #lines == 0 then
    table.insert(lines, "No active mappings.")
  end

  utils.open_scratch_window("GuiKeymapList", lines, "gui-keymap-info")
end

function M.open_skipped_maps()
  local state = utils.get_state()
  local lines = {}

  for _, mapping in ipairs(state.skipped_maps) do
    table.insert(lines, string.format("[%s] %s -> %s (%s)", mapping.mode, mapping.lhs, mapping.desc, mapping.reason))
  end

  if #lines == 0 then
    table.insert(lines, "No skipped mappings.")
  end

  utils.open_scratch_window("GuiKeymapSkipped", lines, "gui-keymap-info")
end

function M.open_explain(key, item)
  local lines = {
    string.format("Key: %s", key),
    "",
    string.format("GUI mapping: %s", item.gui),
    string.format("Vim equivalent: %s", item.vim),
  }

  utils.open_scratch_window("GuiKeymapExplain", lines, "gui-keymap-info")
end

---@param opts GuiKeymapOptions
function M.show(opts)
  M.open_report(opts)
end

return M
