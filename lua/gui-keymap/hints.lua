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

M.enabled = true
M.max_repeat = 3
M.counts = {}

local function build_key_lookup()
  hint_for_key = {
    [vim.api.nvim_replace_termcodes("<C-c>", true, true, true)] = "copy",
    [vim.api.nvim_replace_termcodes("<C-v>", true, true, true)] = "paste",
    [vim.api.nvim_replace_termcodes("<C-x>", true, true, true)] = "cut",
    [vim.api.nvim_replace_termcodes("<C-a>", true, true, true)] = "select_all",
    [vim.api.nvim_replace_termcodes("<C-z>", true, true, true)] = "undo",
    [vim.api.nvim_replace_termcodes("<C-y>", true, true, true)] = "redo",
  }
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
  if count >= M.max_repeat then
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
    local hint_key = hint_for_key[ch]
    if hint_key then
      M.show(hint_key)
    end
  end, ns_id)
end

---@param opts GuiKeymapOptions
function M.setup(opts)
  M.enabled = opts.hint_enabled == true
  M.max_repeat = tonumber(opts.hint_repeat) or 3
  M.counts = {}

  build_key_lookup()
  register_on_key_listener()
end

---@param rhs string|function
---@param _hint_key string|nil
---@return string|function
function M.wrap(rhs, _hint_key)
  return rhs
end

function M.reset()
  M.counts = {}
end

return M
