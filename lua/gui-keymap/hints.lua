local M = {}

local messages = {
  copy = { full = "Tip: Vim copy command is 'y'", short = "Tip: Try using 'y'" },
  paste = { full = "Tip: Vim paste command is 'p'", short = "Tip: Try using 'p'" },
  cut = { full = "Tip: Vim delete command is 'd'", short = "Tip: Try using 'd'" },
  select_all = { full = "Tip: Vim visual selection starts with 'v'", short = "Tip: Try using 'v'" },
  undo = { full = "Tip: Vim undo command is 'u'", short = "Tip: Try using 'u'" },
  redo = { full = "Tip: Vim redo command is '<C-r>'", short = "Tip: Try using '<C-r>'" },
  delete_prev_word = { full = "Tip: Vim previous-word delete is 'db'", short = "Tip: Try using 'db'" },
  delete_next_word = { full = "Tip: Vim next-word delete is 'dw'", short = "Tip: Try using 'dw'" },
}

M.enabled = true
M.max_repeat = 3
M.counts = {}

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

  local use_short
  if M.max_repeat == -1 then
    use_short = count >= 2
  else
    use_short = count >= math.max(1, math.floor(M.max_repeat / 2))
  end

  M.counts[hint_key] = count + 1
  vim.notify(use_short and message.short or message.full, vim.log.levels.INFO, { title = "gui-keymap" })
end

---@param mode string|string[]
---@param rhs string|function
---@param hint_key string|nil
---@return string|function
function M.wrap(mode, rhs, hint_key)
  if not M.enabled or not hint_key then
    return rhs
  end

  if type(rhs) == "function" then
    return function(...)
      rhs(...)
      M.show(hint_key)
    end
  end

  return function()
    local _ = mode
    local keys = vim.api.nvim_replace_termcodes(rhs, true, false, true)
    vim.api.nvim_feedkeys(keys, "n", false)
    M.show(hint_key)
  end
end

---@param opts GuiKeymapOptions
function M.setup(opts)
  M.enabled = opts.hint_enabled == true
  M.max_repeat = tonumber(opts.hint_repeat) or 3
  M.counts = {}
end

function M.reset()
  M.counts = {}
end

return M
