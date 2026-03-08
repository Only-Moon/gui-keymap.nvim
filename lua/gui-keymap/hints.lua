local M = {}

local messages = {
  copy = "Tip: Vim copy command is 'y'",
  paste = "Tip: Vim paste command is 'p'",
  cut = "Tip: Vim delete command is 'd'",
  select_all = "Tip: Vim visual selection starts with 'v'",
  undo = "Tip: Vim undo command is 'u'",
  redo = "Tip: Vim redo command is '<C-r>'",
}

local hint_for_key = {}
local ns_id = nil
local active_by_mode = {}

M.enabled = true
M.max_repeat = 3
M.counts = {}

local function normalize_mode(mode)
  if mode == "v" or mode == "V" or mode == "\22" then
    return "x"
  end

  return mode
end

local function build_key_lookup()
  hint_for_key = {
    [vim.api.nvim_replace_termcodes("<C-c>", true, true, true)] = { hint_key = "copy", lhs = "<C-c>" },
    [vim.api.nvim_replace_termcodes("<C-v>", true, true, true)] = { hint_key = "paste", lhs = "<C-v>" },
    [vim.api.nvim_replace_termcodes("<C-x>", true, true, true)] = { hint_key = "cut", lhs = "<C-x>" },
    [vim.api.nvim_replace_termcodes("<C-a>", true, true, true)] = { hint_key = "select_all", lhs = "<C-a>" },
    [vim.api.nvim_replace_termcodes("<C-z>", true, true, true)] = { hint_key = "undo", lhs = "<C-z>" },
    [vim.api.nvim_replace_termcodes("<C-y>", true, true, true)] = { hint_key = "redo", lhs = "<C-y>" },
  }
end

---@param active_maps GuiKeymapActive[]
local function build_active_lookup(active_maps)
  active_by_mode = {}

  for _, mapping in ipairs(active_maps or {}) do
    active_by_mode[mapping.mode] = active_by_mode[mapping.mode] or {}
    active_by_mode[mapping.mode][mapping.lhs] = true
  end
end

---@param lhs string
---@param mode string
---@return boolean
local function hint_is_active(lhs, mode)
  local normalized = normalize_mode(mode)
  return active_by_mode[normalized] and active_by_mode[normalized][lhs] == true
end

---@param hint_key string|nil
function M.show(hint_key)
  if not M.enabled or not hint_key then
    return
  end

  local message = messages[hint_key]
  if not message then
    return
  end

  local count = M.counts[hint_key] or 0
  if M.max_repeat ~= -1 and count >= M.max_repeat then
    return
  end

  M.counts[hint_key] = count + 1
  vim.notify(message, vim.log.levels.INFO, { title = "gui-keymap" })
end

local function register_on_key_listener()
  if ns_id then
    vim.on_key(nil, ns_id)
    ns_id = nil
  end

  if not M.enabled then
    return
  end

  ns_id = vim.api.nvim_create_namespace("gui-keymap-hints")
  vim.on_key(function(ch)
    local item = hint_for_key[ch]
    if not item then
      return
    end

    local current_mode = vim.api.nvim_get_mode().mode
    if hint_is_active(item.lhs, current_mode) then
      M.show(item.hint_key)
    end
  end, ns_id)
end

---@param opts GuiKeymapOptions
---@param active_maps GuiKeymapActive[]
function M.setup(opts, active_maps)
  M.enabled = opts.hint_enabled == true
  M.max_repeat = tonumber(opts.hint_repeat) or 3
  M.counts = {}

  build_key_lookup()
  build_active_lookup(active_maps)
  register_on_key_listener()
end

function M.reset()
  M.counts = {}
end

return M
