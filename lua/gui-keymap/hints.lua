local state = require("gui-keymap.state")

local M = {}

local templates = {
  copy = {
    visual = {
      "Copied selection. Vim equivalent: y",
      "You can use y in visual mode for the same copy.",
      "Quick practice: try y next time.",
    },
    normal = {
      "Copied line. Vim equivalent: yy",
      "You can use yy to copy the current line.",
      "Quick practice: try yy next time.",
    },
  },
  paste = {
    default = {
      "Pasted. Vim equivalent: p",
      "You can use p for paste in normal mode.",
      "Quick practice: try p next time.",
    },
  },
  cut = {
    visual = {
      "Cut selection. Vim equivalent: d",
      "You can use d in visual mode for the same cut.",
      "Quick practice: try d next time.",
    },
    default = {
      "Cut/Delete action. Vim equivalent: d",
      "You can use d for this action.",
      "Quick practice: try d next time.",
    },
  },
  select_all = {
    default = {
      "Selected all. Vim sequence: ggVG",
      "You can select all with ggVG.",
      "Quick practice: try ggVG next time.",
    },
  },
  undo = {
    default = {
      "Undo complete. Vim equivalent: u",
      "You can use u for undo.",
      "Quick practice: try u next time.",
    },
  },
  redo = {
    default = {
      "Redo complete. Vim equivalent: <C-r>",
      "You can use <C-r> for redo.",
      "Quick practice: try <C-r> next time.",
    },
  },
  delete_prev_word = {
    default = {
      "Deleted previous word. Vim equivalent: db",
      "You can use db to delete the previous word.",
      "Quick practice: try db next time.",
    },
  },
  delete_next_word = {
    default = {
      "Deleted next word. Vim equivalent: dw",
      "You can use dw to delete the next word.",
      "Quick practice: try dw next time.",
    },
  },
}

M.enabled = true
M.max_repeat = 3
M.throttle_ms = 1200

local function now_ms()
  return vim.uv.now()
end

local function normalized_mode(mode)
  if mode == "v" or mode == "V" or mode == "\22" then
    return "visual"
  end
  if mode == "n" then
    return "normal"
  end
  if mode == "i" then
    return "insert"
  end
  return "default"
end

local function stage_for_count(shown)
  if shown <= 0 then
    return 1
  end
  if shown == 1 then
    return 2
  end
  return 3
end

local function cadence_ok(shown)
  if shown <= 2 then
    return true
  end

  if shown <= 6 then
    return shown % 2 == 0
  end

  return shown % 4 == 0
end

local function pick_message(hint_key, mode, shown)
  local bucket = templates[hint_key]
  if not bucket then
    return nil
  end

  local target = bucket[mode] or bucket.default or bucket.normal or bucket.visual
  if not target then
    return nil
  end

  local stage = stage_for_count(shown)
  return target[stage] or target[#target]
end

---@param hint_key string|nil
---@param mode string|nil
function M.show(hint_key, mode)
  if not M.enabled or not hint_key then
    return
  end

  local last_ts = state.hint_last_ts[hint_key] or 0
  local ts = now_ms()
  if ts - last_ts < M.throttle_ms then
    return
  end

  local shown = state.hint_counts[hint_key] or 0
  if M.max_repeat ~= -1 and shown >= M.max_repeat then
    return
  end

  if not cadence_ok(shown) then
    state.hint_counts[hint_key] = shown + 1
    return
  end

  local message = pick_message(hint_key, normalized_mode(mode or vim.api.nvim_get_mode().mode), shown)
  if not message then
    return
  end

  state.hint_last_ts[hint_key] = ts
  state.hint_counts[hint_key] = shown + 1
  vim.notify(message, vim.log.levels.INFO, { title = "gui-keymap" })
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
      M.show(hint_key, type(mode) == "table" and mode[1] or mode)
    end
  end

  return function()
    local keys = vim.api.nvim_replace_termcodes(rhs, true, false, true)
    vim.api.nvim_feedkeys(keys, "n", false)
    M.show(hint_key, type(mode) == "table" and mode[1] or mode)
  end
end

---@param opts GuiKeymapOptions
function M.setup(opts)
  M.enabled = opts.hint_enabled == true
  M.max_repeat = tonumber(opts.hint_repeat) or 3
end

function M.reset()
  state.hint_counts = {}
  state.hint_last_ts = {}
end

return M
