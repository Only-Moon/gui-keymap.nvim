local M = {}

local messages = {
  copy = {
    intro = "Tip: You copied text. Native Vim copy is `y`.",
    practice = "Tip: Next time, try `y` for copy.",
    reinforce = "Nice. Native copy is `y`.",
  },
  paste = {
    intro = "Tip: You pasted text. Native Vim paste is `p`.",
    practice = "Tip: Next time, try `p` for paste.",
    reinforce = "Nice. Native paste is `p`.",
  },
  cut = {
    intro = "Tip: You cut text. Native Vim delete is `d`.",
    practice = "Tip: Next time, try `d` for cut/delete.",
    reinforce = "Nice. Native cut/delete is `d`.",
  },
  select_all = {
    intro = "Tip: You selected all. Native Vim sequence is `ggVG`.",
    practice = "Tip: Next time, try `ggVG`.",
    reinforce = "Nice. Native select-all is `ggVG`.",
  },
  undo = {
    intro = "Tip: You undid a change. Native Vim undo is `u`.",
    practice = "Tip: Next time, try `u`.",
    reinforce = "Nice. Native undo is `u`.",
  },
  redo = {
    intro = "Tip: You redid a change. Native Vim redo is `<C-r>`.",
    practice = "Tip: Next time, try `<C-r>`.",
    reinforce = "Nice. Native redo is `<C-r>`.",
  },
  delete_prev_word = {
    intro = "Tip: You deleted the previous word. Native Vim is `db`.",
    practice = "Tip: Next time, try `db`.",
    reinforce = "Nice. Native previous-word delete is `db`.",
  },
  delete_next_word = {
    intro = "Tip: You deleted the next word. Native Vim is `dw`.",
    practice = "Tip: Next time, try `dw`.",
    reinforce = "Nice. Native next-word delete is `dw`.",
  },
}

M.enabled = true
M.max_repeat = 3
M.counts = {}
M.usage_counts = {}

---@param usage number
---@return number
local function usage_stride(usage)
  if usage <= 2 then
    return 1
  end
  if usage <= 6 then
    return 2
  end
  return 3
end

---@param message table
---@param shown_count number
---@return string
local function select_message(message, shown_count)
  if shown_count <= 0 then
    return message.intro
  end
  if shown_count <= 2 then
    return message.practice
  end
  return message.reinforce
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

  local shown_count = M.counts[hint_key] or 0
  local usage_count = (M.usage_counts[hint_key] or 0) + 1
  M.usage_counts[hint_key] = usage_count

  if M.max_repeat ~= -1 and shown_count >= M.max_repeat then
    return
  end

  if M.max_repeat ~= -1 then
    local stride = usage_stride(usage_count)
    if usage_count > 1 and (usage_count - 1) % stride ~= 0 then
      return
    end
  end

  local output = select_message(message, shown_count)
  if output == nil or output == "" then
    return
  end

  M.counts[hint_key] = shown_count + 1
  vim.notify(output, vim.log.levels.INFO, { title = "gui-keymap" })
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
  M.usage_counts = {}
end

function M.reset()
  M.counts = {}
  M.usage_counts = {}
end

return M
