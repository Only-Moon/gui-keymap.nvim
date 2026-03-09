local utils = require("gui-keymap.utils")

local M = {}

---@param opts GuiKeymapOptions
---@return string[]
local function build_lines(opts)
  local state = utils.get_state()
  local lines = {
    "gui-keymap.nvim",
    "",
    "Active GUI keymaps: " .. tostring(#state.active_maps),
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
    "Hints: " .. ((opts.hint_enabled and "enabled") or "disabled") .. string.format(" (repeat: %d)", opts.hint_repeat)
  )

  return lines
end

---@param opts GuiKeymapOptions
function M.show(opts)
  local lines = build_lines(opts)
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "GuiKeymapInfo" })
end

return M
