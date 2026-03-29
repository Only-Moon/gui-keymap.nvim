local state = require("gui-keymap.state")

local M = {}

local HINT_STATE_FILE = vim.fn.stdpath("state") .. "/gui-keymap-hints.json"

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
      "Deleted previous word.",
      "Closest Vim equivalents are <C-w> in insert mode or db in normal mode.",
      "Quick practice: try <C-w> in insert mode next time.",
    },
  },
  delete_next_word = {
    default = {
      "Deleted next word. Vim equivalent: dw",
      "You can use dw to delete the next word.",
      "Quick practice: try dw next time.",
    },
  },
  save = {
    default = {
      "Saved file. Vim equivalent: :write",
      "You can save with :write or :w.",
      "Quick practice: try :w next time.",
    },
  },
  quit = {
    default = {
      "Saved and quit. Vim equivalent: :wq",
      "You can save and quit with :wq.",
      "Quick practice: try :wq next time.",
    },
  },
  home = {
    default = {
      "Moved to line start. Vim equivalent: 0",
      "You can jump to line start with 0.",
      "Quick practice: try 0 next time.",
    },
  },
  ["end"] = {
    default = {
      "Moved to line end. Vim equivalent: $",
      "You can jump to line end with $.",
      "Quick practice: try $ next time.",
    },
  },
}

M.enabled = true
M.max_repeat = 3
M.throttle_ms = 1200
M.persist = true

local function now_ms()
  return vim.uv.now()
end

local function normalized_mode(mode)
  if mode == "v" or mode == "V" or mode == "\22" or mode == "s" or mode == "S" or mode == "\19" then
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

local function read_persisted_counts()
  if vim.fn.filereadable(HINT_STATE_FILE) ~= 1 then
    return {}
  end

  local lines = vim.fn.readfile(HINT_STATE_FILE)
  if #lines == 0 then
    return {}
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok or type(decoded) ~= "table" or type(decoded.counts) ~= "table" then
    return {}
  end

  return decoded.counts
end

local function persist_counts()
  if not M.persist then
    return
  end

  vim.fn.mkdir(vim.fn.fnamemodify(HINT_STATE_FILE, ":h"), "p")
  local ok, encoded = pcall(vim.json.encode, { counts = state.hint_counts })
  if not ok then
    return
  end

  vim.fn.writefile({ encoded }, HINT_STATE_FILE)
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
    persist_counts()
    return
  end

  local message = pick_message(hint_key, normalized_mode(mode or vim.api.nvim_get_mode().mode), shown)
  if not message then
    return
  end

  state.hint_last_ts[hint_key] = ts
  state.hint_counts[hint_key] = shown + 1
  persist_counts()
  vim.notify(message, vim.log.levels.INFO, { title = "gui-keymap" })
end

---@param mode string|string[]
---@param rhs string|function
---@param hint_key string|nil
---@return string|function
---@return table|nil
function M.wrap(mode, rhs, hint_key)
  if not M.enabled or not hint_key then
    return rhs, nil
  end

  if type(rhs) == "function" then
    return function(...)
      rhs(...)
      M.show(hint_key, type(mode) == "table" and mode[1] or mode)
    end, nil
  end

  return function()
    vim.schedule(function()
      M.show(hint_key, type(mode) == "table" and mode[1] or mode)
    end)
    return vim.api.nvim_replace_termcodes(rhs, true, false, true)
  end, { expr = true }
end

---@param opts GuiKeymapOptionsStrict
function M.setup(opts)
  M.enabled = opts.hint_enabled == true
  M.max_repeat = tonumber(opts.hint_repeat) or 3
  M.persist = opts.hint_persist == true

  if M.persist then
    state.hint_counts = read_persisted_counts()
  end
end

function M.reset()
  state.hint_counts = {}
  state.hint_last_ts = {}

  if M.persist and vim.fn.filereadable(HINT_STATE_FILE) == 1 then
    vim.fn.delete(HINT_STATE_FILE)
  end
end

return M
