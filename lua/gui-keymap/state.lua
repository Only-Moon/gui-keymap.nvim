local M = {
  enabled = true,
  config = {},
  active_maps = {},
  conflicts = {},
  hint_counts = {},
  hint_last_ts = {},
  disabled_features = {},
  yanky_available = false,
  yanky_enabled = false,
  which_key_available = false,
}

local active_index = {}

local function map_key(mode, lhs)
  return mode .. "::" .. lhs
end

function M.set_config(cfg)
  M.config = cfg or {}
end

function M.clear_runtime()
  M.active_maps = {}
  M.conflicts = {}
  M.hint_counts = {}
  M.hint_last_ts = {}
  M.disabled_features = {}
  M.yanky_available = false
  M.yanky_enabled = false
  M.which_key_available = false
  active_index = {}
end

function M.register_map(mode, key, desc, feature)
  local id = map_key(mode, key)
  if active_index[id] then
    return
  end

  active_index[id] = true
  table.insert(M.active_maps, {
    mode = mode,
    lhs = key,
    desc = desc or "",
    feature = feature or "",
  })
end

function M.add_conflict(mode, key, requested_desc, existing)
  table.insert(M.conflicts, {
    mode = mode,
    lhs = key,
    requested_desc = requested_desc or "",
    existing_desc = (existing and existing.desc) or "",
    existing_rhs = (existing and existing.rhs) or "",
  })
end

function M.get_active_maps()
  return M.active_maps
end

function M.get_conflicts()
  return M.conflicts
end

return M
