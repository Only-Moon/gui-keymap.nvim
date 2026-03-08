local hints = require("gui-keymap.hints")
local utils = require("gui-keymap.utils")

local M = {}

---@class GuiKeymapDefinition
---@field feature string
---@field mode string|string[]
---@field lhs string
---@field rhs string|function
---@field desc string
---@field hint_key string|nil
---@field toggle string|nil
---@field force boolean|nil

---@type GuiKeymapDefinition[]
M.registry = {
  {
    feature = "undo_redo",
    toggle = "undo",
    force = true,
    mode = "n",
    lhs = "<C-z>",
    rhs = "u",
    desc = "gui-keymap: Undo",
    hint_key = "undo",
  },
  {
    feature = "undo_redo",
    toggle = "redo",
    force = true,
    mode = "n",
    lhs = "<C-y>",
    rhs = "<C-r>",
    desc = "gui-keymap: Redo",
    hint_key = "redo",
  },
  {
    feature = "undo_redo",
    toggle = "undo",
    force = true,
    mode = "i",
    lhs = "<C-z>",
    rhs = "<C-o>u",
    desc = "gui-keymap: Undo",
    hint_key = "undo",
  },
  {
    feature = "undo_redo",
    toggle = "redo",
    force = true,
    mode = "i",
    lhs = "<C-y>",
    rhs = "<C-o><C-r>",
    desc = "gui-keymap: Redo",
    hint_key = "redo",
  },

  {
    feature = "clipboard",
    toggle = "copy",
    force = true,
    mode = "x",
    lhs = "<C-c>",
    rhs = '"+y',
    desc = "gui-keymap: Copy selection",
    hint_key = "copy",
  },
  {
    feature = "clipboard",
    toggle = "copy",
    force = true,
    mode = "n",
    lhs = "<C-c>",
    rhs = '"+yy',
    desc = "gui-keymap: Copy line",
    hint_key = "copy",
  },
  {
    feature = "clipboard",
    toggle = "cut",
    force = true,
    mode = "x",
    lhs = "<C-x>",
    rhs = '"+d',
    desc = "gui-keymap: Cut selection",
    hint_key = "cut",
  },
  {
    feature = "clipboard",
    toggle = "paste",
    force = true,
    mode = "n",
    lhs = "<C-v>",
    rhs = '"+p',
    desc = "gui-keymap: Paste",
    hint_key = "paste",
  },
  {
    feature = "clipboard",
    toggle = "paste",
    force = true,
    mode = "i",
    lhs = "<C-v>",
    rhs = '"+p',
    desc = "gui-keymap: Paste",
    hint_key = "paste",
  },

  {
    feature = "select_all",
    force = true,
    mode = "n",
    lhs = "<C-a>",
    rhs = "ggVG",
    desc = "gui-keymap: Select all",
    hint_key = "select_all",
  },
  {
    feature = "select_all",
    force = true,
    mode = "i",
    lhs = "<C-a>",
    rhs = "<Esc>ggVG",
    desc = "gui-keymap: Select all",
    hint_key = "select_all",
  },

  {
    feature = "delete_selection",
    force = true,
    mode = "x",
    lhs = "<BS>",
    rhs = '"_d',
    desc = "gui-keymap: Delete selection",
  },
  {
    feature = "delete_selection",
    force = true,
    mode = "x",
    lhs = "<Del>",
    rhs = '"_d',
    desc = "gui-keymap: Delete selection",
  },

  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<S-Left>",
    rhs = "v<Left>",
    desc = "gui-keymap: Select left",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<kL>",
    rhs = "v<Left>",
    desc = "gui-keymap: Select left (terminal fallback)",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<S-Right>",
    rhs = "v<Right>",
    desc = "gui-keymap: Select right",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<kR>",
    rhs = "v<Right>",
    desc = "gui-keymap: Select right (terminal fallback)",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<S-Up>",
    rhs = "v<Up>",
    desc = "gui-keymap: Select up",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<kU>",
    rhs = "v<Up>",
    desc = "gui-keymap: Select up (terminal fallback)",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<S-Down>",
    rhs = "v<Down>",
    desc = "gui-keymap: Select down",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<kD>",
    rhs = "v<Down>",
    desc = "gui-keymap: Select down (terminal fallback)",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<S-Left>",
    rhs = "<Left>",
    desc = "gui-keymap: Expand selection left",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<kL>",
    rhs = "<Left>",
    desc = "gui-keymap: Expand selection left (terminal fallback)",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<S-Right>",
    rhs = "<Right>",
    desc = "gui-keymap: Expand selection right",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<kR>",
    rhs = "<Right>",
    desc = "gui-keymap: Expand selection right (terminal fallback)",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<S-Up>",
    rhs = "<Up>",
    desc = "gui-keymap: Expand selection up",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<kU>",
    rhs = "<Up>",
    desc = "gui-keymap: Expand selection up (terminal fallback)",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<S-Down>",
    rhs = "<Down>",
    desc = "gui-keymap: Expand selection down",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<kD>",
    rhs = "<Down>",
    desc = "gui-keymap: Expand selection down (terminal fallback)",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<S-Left>",
    rhs = "<Esc>v<Left>",
    desc = "gui-keymap: Select left",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<kL>",
    rhs = "<Esc>v<Left>",
    desc = "gui-keymap: Select left (terminal fallback)",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<S-Right>",
    rhs = "<Esc>v<Right>",
    desc = "gui-keymap: Select right",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<kR>",
    rhs = "<Esc>v<Right>",
    desc = "gui-keymap: Select right (terminal fallback)",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<S-Up>",
    rhs = "<Esc>v<Up>",
    desc = "gui-keymap: Select up",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<kU>",
    rhs = "<Esc>v<Up>",
    desc = "gui-keymap: Select up (terminal fallback)",
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<S-Down>",
    rhs = "<Esc>v<Down>",
    desc = "gui-keymap: Select down",
  },

  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<kD>",
    rhs = "<Esc>v<Down>",
    desc = "gui-keymap: Select down (terminal fallback)",
  },
  {
    feature = "word_delete",
    force = true,
    mode = "n",
    lhs = "<C-BS>",
    rhs = "db",
    desc = "gui-keymap: Delete previous word",
    hint_key = "delete_prev_word",
  },
  {
    feature = "word_delete",
    force = true,
    mode = "n",
    lhs = "<C-Del>",
    rhs = "dw",
    desc = "gui-keymap: Delete next word",
    hint_key = "delete_next_word",
  },
  {
    feature = "word_delete",
    force = true,
    mode = "i",
    lhs = "<C-BS>",
    rhs = "<C-o>db",
    desc = "gui-keymap: Delete previous word",
    hint_key = "delete_prev_word",
  },
  {
    feature = "word_delete",
    force = true,
    mode = "i",
    lhs = "<C-Del>",
    rhs = "<C-o>dw",
    desc = "gui-keymap: Delete next word",
    hint_key = "delete_next_word",
  },
}

---@param opts GuiKeymapOptions
---@param item GuiKeymapDefinition
---@return boolean
local function item_enabled(opts, item)
  if opts[item.feature] ~= true then
    return false
  end

  if item.toggle and opts[item.toggle] ~= nil then
    return opts[item.toggle] == true
  end

  return true
end

---@param mode string
---@return string
local function normalize_mode(mode)
  if mode == "v" or mode == "V" or mode == "\22" then
    return "x"
  end
  return mode
end

local function escape_to_normal()
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "n", false)
end

---@param rhs string|function
---@param opts GuiKeymapOptions
---@return string|function
local function with_mode_restore(rhs, opts)
  if not opts.preserve_mode then
    return rhs
  end

  return function(...)
    local original_mode = normalize_mode(vim.api.nvim_get_mode().mode)

    if type(rhs) == "function" then
      rhs(...)
    else
      local keys = vim.api.nvim_replace_termcodes(rhs, true, false, true)
      vim.api.nvim_feedkeys(keys, "n", false)
    end

    vim.schedule(function()
      if original_mode == "i" then
        vim.cmd("startinsert")
      elseif original_mode == "n" then
        escape_to_normal()
      elseif original_mode == "x" then
        vim.cmd("normal! gv")
      end
    end)
  end
end

---@param opts GuiKeymapOptions
local function apply_main_registry(opts)
  for _, item in ipairs(M.registry) do
    if item_enabled(opts, item) then
      local rhs = with_mode_restore(item.rhs, opts)
      rhs = hints.wrap(item.mode, rhs, item.hint_key)
      utils.safe_map(
        item.mode,
        item.lhs,
        rhs,
        { desc = item.desc, silent = true, noremap = true },
        item.feature,
        item.force and opts.force_priority
      )
    else
      utils.mark_feature_disabled(item.feature)
    end
  end
end

---@param opts GuiKeymapOptions
local function apply_yanky_registry(opts)
  local has_yanky = pcall(require, "yanky")
  utils.set_yanky_status(has_yanky, opts.yanky_integration == true)

  if opts.yanky_integration ~= true then
    utils.mark_feature_disabled("yanky_integration")
  end
end

local function register_with_which_key(opts)
  local ok, wk = pcall(require, "which-key")
  utils.set_which_key_status(ok)

  if not ok or opts.which_key_integration == false then
    return
  end

  local entries = {}
  for _, mapping in ipairs(utils.get_state().active_maps) do
    table.insert(entries, {
      mapping.lhs,
      desc = mapping.desc,
      mode = mapping.mode,
    })
  end

  if #entries == 0 then
    return
  end

  if type(wk.add) == "function" then
    wk.add(entries)
    return
  end

  if type(wk.register) == "function" then
    local grouped = {}
    for _, entry in ipairs(entries) do
      grouped[entry[1]] = entry.desc
    end
    wk.register(grouped)
  end
end

---@param opts GuiKeymapOptions
function M.apply(opts)
  utils.clear_plugin_maps()
  apply_main_registry(opts)
  apply_yanky_registry(opts)
  register_with_which_key(opts)
end

return M
