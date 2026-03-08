local M = {}

---@class GuiKeymapConflict
---@field mode string
---@field lhs string
---@field requested_desc string
---@field existing_desc string
---@field existing_rhs string

---@class GuiKeymapActive
---@field mode string
---@field lhs string
---@field desc string
---@field feature string

---@class GuiKeymapState
---@field conflicts GuiKeymapConflict[]
---@field active_maps GuiKeymapActive[]
---@field disabled_features table<string, boolean>
---@field yanky_available boolean
---@field yanky_enabled boolean
---@field which_key_available boolean

---@type GuiKeymapState
M.state = {
  conflicts = {},
  active_maps = {},
  disabled_features = {},
  yanky_available = false,
  yanky_enabled = false,
  which_key_available = false,
}

local applied_index = {}

---@param mode string|string[]
---@return string[]
local function normalize_modes(mode)
  if type(mode) == "table" then
    return mode
  end

  return { mode }
end

---@param mapping table
---@return string
local function map_key(mapping)
  return mapping.mode .. "::" .. mapping.lhs
end

---@param mode string
---@param lhs string
---@return table
function M.inspect_mapping(mode, lhs)
  return vim.fn.maparg(lhs, mode, false, true)
end

---@param mode string
---@param lhs string
---@return boolean
function M.mapping_exists(mode, lhs)
  local existing = M.inspect_mapping(mode, lhs)
  return type(existing) == "table" and next(existing) ~= nil
end

function M.reset_state()
  M.state.conflicts = {}
  M.state.active_maps = {}
  M.state.disabled_features = {}
  M.state.yanky_available = false
  M.state.yanky_enabled = false
  M.state.which_key_available = false
  applied_index = {}
end

function M.clear_plugin_maps()
  for _, mapping in ipairs(M.state.active_maps) do
    pcall(vim.keymap.del, mapping.mode, mapping.lhs)
  end

  M.reset_state()
end

---@param feature string
function M.mark_feature_disabled(feature)
  M.state.disabled_features[feature] = true
end

---@param mode string
---@param lhs string
---@param requested_desc string
---@param existing table
function M.record_conflict(mode, lhs, requested_desc, existing)
  table.insert(M.state.conflicts, {
    mode = mode,
    lhs = lhs,
    requested_desc = requested_desc,
    existing_desc = existing.desc or "",
    existing_rhs = existing.rhs or "",
  })
end

---@param mapping GuiKeymapActive
function M.record_active(mapping)
  local key = map_key(mapping)
  if applied_index[key] then
    return
  end

  applied_index[key] = true
  table.insert(M.state.active_maps, mapping)
end

---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts table|nil
---@param feature string
---@return boolean
function M.safe_map(mode, lhs, rhs, opts, feature)
  local modes = normalize_modes(mode)
  local final_opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  local desc = final_opts.desc or ("gui-keymap: " .. lhs)

  for _, current_mode in ipairs(modes) do
    local existing = M.inspect_mapping(current_mode, lhs)
    if type(existing) == "table" and next(existing) ~= nil then
      M.record_conflict(current_mode, lhs, desc, existing)
    else
      vim.keymap.set(current_mode, lhs, rhs, final_opts)
      M.record_active({
        mode = current_mode,
        lhs = lhs,
        desc = desc,
        feature = feature,
      })
    end
  end

  return true
end

---@param available boolean
---@param enabled boolean
function M.set_yanky_status(available, enabled)
  M.state.yanky_available = available
  M.state.yanky_enabled = available and enabled
end

---@param available boolean
function M.set_which_key_status(available)
  M.state.which_key_available = available
end

---@return GuiKeymapState
function M.get_state()
  return M.state
end

return M
