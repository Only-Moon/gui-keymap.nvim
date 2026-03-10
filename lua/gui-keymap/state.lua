local M = {
  enabled = true,
  config = {},
  active_maps = {},
  conflicts = {},
  requested_maps = {},
  skipped_maps = {},
  fallback_maps = {},
  terminal_sensitive = {},
  hint_counts = {},
  hint_last_ts = {},
  disabled_features = {},
  yanky_available = false,
  yanky_loaded = false,
  yanky_enabled = false,
  yanky_checked = false,
  which_key_available = false,
  which_key_signature = nil,
}

local active_index = {}

local function map_key(mode, lhs)
  return mode .. "::" .. lhs
end

function M.set_config(cfg)
  M.config = cfg or {}
end

function M.clear_session()
  M.active_maps = {}
  M.conflicts = {}
  M.requested_maps = {}
  M.skipped_maps = {}
  M.fallback_maps = {}
  M.terminal_sensitive = {}
  M.hint_counts = {}
  M.hint_last_ts = {}
  M.disabled_features = {}
  M.yanky_available = false
  M.yanky_loaded = false
  M.yanky_enabled = false
  M.yanky_checked = false
  M.which_key_available = false
  M.which_key_signature = nil
  active_index = {}
end

function M.clear_maps()
  M.active_maps = {}
  M.conflicts = {}
  M.requested_maps = {}
  M.skipped_maps = {}
  M.fallback_maps = {}
  M.terminal_sensitive = {}
  M.disabled_features = {}
  active_index = {}
end

function M.register_requested_map(mode, key, desc, feature)
  table.insert(M.requested_maps, {
    mode = mode,
    lhs = key,
    desc = desc or "",
    feature = feature or "",
  })
end

function M.register_skipped_map(mode, key, desc, reason)
  table.insert(M.skipped_maps, {
    mode = mode,
    lhs = key,
    desc = desc or "",
    reason = reason or "conflict",
  })
end

function M.register_fallback_map(mode, key)
  table.insert(M.fallback_maps, {
    mode = mode,
    lhs = key,
  })
end

function M.register_terminal_sensitive(mode, key)
  table.insert(M.terminal_sensitive, {
    mode = mode,
    lhs = key,
  })
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
