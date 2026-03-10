local state = require("gui-keymap.state")

local M = {}

local function normalize_modes(mode)
  if type(mode) == "table" then
    return mode
  end
  return { mode }
end

local function is_builtin_default(existing)
  if type(existing) ~= "table" or next(existing) == nil then
    return false
  end

  local desc = existing.desc or ""
  return desc == "Increment" or desc == "Decrement" or desc == "Abort"
end

---@param mode string
---@param lhs string
---@return table
function M.inspect_mapping(mode, lhs)
  return vim.fn.maparg(lhs, mode, false, true)
end

---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts table|nil
---@param feature string
---@param force boolean|nil
---@return boolean
function M.safe_map(mode, lhs, rhs, opts, feature, force)
  local modes = normalize_modes(mode)
  local final_opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  local desc = final_opts.desc or ("gui-keymap: " .. lhs)
  local applied = false

  for _, current_mode in ipairs(modes) do
    state.register_requested_map(current_mode, lhs, desc, feature)
    local existing = M.inspect_mapping(current_mode, lhs)
    local has_existing = type(existing) == "table" and next(existing) ~= nil

    if has_existing and not is_builtin_default(existing) and not force then
      state.add_conflict(current_mode, lhs, desc, existing, feature)
      state.register_skipped_map(current_mode, lhs, desc, "conflict", feature)
    else
      vim.keymap.set(current_mode, lhs, rhs, final_opts)
      state.register_map(current_mode, lhs, desc, feature)
      applied = true
    end
  end

  return applied
end

function M.clear_plugin_maps()
  for _, mapping in ipairs(state.get_active_maps()) do
    pcall(vim.keymap.del, mapping.mode, mapping.lhs)
  end
  state.clear_maps()
end

function M.mark_feature_disabled(feature)
  state.disabled_features[feature] = true
end

function M.set_yanky_status(available, loaded, enabled, status, source)
  state.yanky_available = available
  state.yanky_loaded = loaded
  state.yanky_enabled = available and enabled
  state.yanky_status = status or (available and (loaded and "ready" or "installed") or "absent")
  state.yanky_source = source or ""
end

function M.set_which_key_status(available)
  state.which_key_available = available
end

function M.get_state()
  return state
end

function M.mark_fallback_map(mode, lhs)
  state.register_fallback_map(mode, lhs)
end

function M.mark_terminal_sensitive(mode, lhs)
  state.register_terminal_sensitive(mode, lhs)
end

---@param title string
---@param lines string[]
---@param filetype string|nil
function M.open_scratch_window(title, lines, filetype)
  vim.cmd("enew")

  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true
  vim.bo[buf].filetype = filetype or "gui-keymap-info"

  local content = { title, "" }
  vim.list_extend(content, lines)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.bo[buf].modifiable = false

  return buf
end

function M.get_conflicts()
  local fallback_by_shift = {
    ["<S-Left>"] = "<kL>",
    ["<S-Right>"] = "<kR>",
    ["<S-Up>"] = "<kU>",
    ["<S-Down>"] = "<kD>",
  }

  local active_index = {}
  for _, mapping in ipairs(state.get_active_maps()) do
    active_index[mapping.mode .. "::" .. mapping.lhs] = true
  end

  local filtered = {}
  for _, conflict in ipairs(state.get_conflicts()) do
    local fallback = fallback_by_shift[conflict.lhs]
    if fallback and active_index[conflict.mode .. "::" .. fallback] then
      goto continue
    end
    table.insert(filtered, conflict)
    ::continue::
  end

  return filtered
end

function M.get_conflict_summary()
  local summary = {}

  for _, conflict in ipairs(M.get_conflicts()) do
    local feature = conflict.feature ~= "" and conflict.feature or "unknown"
    summary[feature] = (summary[feature] or 0) + 1
  end

  return summary
end

return M
