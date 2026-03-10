local clipboard = require("gui-keymap.clipboard")
local hints = require("gui-keymap.hints")
local utils = require("gui-keymap.utils")

local M = {}

local function termcodes(keys)
  return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

local function save_buffer()
  vim.cmd("silent! update")
end

local function save_buffer_insert()
  save_buffer()
  vim.cmd("startinsert")
end

local function quit_current()
  if vim.bo.buftype ~= "" then
    pcall(vim.cmd, "confirm quit")
    return
  end

  pcall(vim.cmd, "confirm wq")
end

local function quit_current_insert()
  vim.cmd("stopinsert")
  quit_current()
end

local function select_all_normal()
  vim.cmd.normal({ args = { "ggVG" }, bang = true })
end

local function select_all_insert()
  vim.cmd("stopinsert")
  select_all_normal()
end

local function undo_normal()
  vim.cmd.undo()
end

local function redo_normal()
  vim.cmd.redo()
end

local function undo_insert()
  vim.api.nvim_feedkeys(termcodes("<C-o>u"), "n", false)
end

local function redo_insert()
  vim.api.nvim_feedkeys(termcodes("<C-o><C-r>"), "n", false)
end

---@class GuiKeymapDefinition
---@field feature string
---@field mode string|string[]
---@field lhs string
---@field rhs string|function
---@field desc string
---@field hint_key string|nil
---@field toggle string|nil
---@field force boolean|nil
---@field preserve_mode boolean|nil

---@type GuiKeymapDefinition[]
M.registry = {
  {
    feature = "undo_redo",
    toggle = "undo",
    force = true,
    mode = "n",
    lhs = "<C-z>",
    rhs = undo_normal,
    desc = "gui-keymap: Undo",
    hint_key = "undo",
    preserve_mode = false,
  },
  {
    feature = "undo_redo",
    toggle = "redo",
    force = true,
    mode = "n",
    lhs = "<C-y>",
    rhs = redo_normal,
    desc = "gui-keymap: Redo",
    hint_key = "redo",
    preserve_mode = false,
  },
  {
    feature = "undo_redo",
    toggle = "undo",
    force = true,
    mode = "i",
    lhs = "<C-z>",
    rhs = undo_insert,
    desc = "gui-keymap: Undo",
    hint_key = "undo",
    preserve_mode = false,
  },
  {
    feature = "undo_redo",
    toggle = "redo",
    force = true,
    mode = "i",
    lhs = "<C-y>",
    rhs = redo_insert,
    desc = "gui-keymap: Redo",
    hint_key = "redo",
    preserve_mode = false,
  },
  {
    feature = "clipboard",
    toggle = "copy",
    force = true,
    mode = "x",
    lhs = "<C-c>",
    rhs = clipboard.copy_selection,
    desc = "gui-keymap: Copy selection",
    hint_key = "copy",
    preserve_mode = true,
  },
  {
    feature = "clipboard",
    toggle = "copy",
    force = true,
    mode = "n",
    lhs = "<C-c>",
    rhs = clipboard.copy_line,
    desc = "gui-keymap: Copy line",
    hint_key = "copy",
    preserve_mode = true,
  },
  {
    feature = "clipboard",
    toggle = "cut",
    force = true,
    mode = "x",
    lhs = "<C-x>",
    rhs = clipboard.cut_selection,
    desc = "gui-keymap: Cut selection",
    hint_key = "cut",
    preserve_mode = true,
  },
  {
    feature = "clipboard",
    toggle = "paste",
    force = true,
    mode = "n",
    lhs = "<C-v>",
    rhs = clipboard.paste_normal,
    desc = "gui-keymap: Paste",
    hint_key = "paste",
    preserve_mode = true,
  },
  {
    feature = "clipboard",
    toggle = "paste",
    force = true,
    mode = "i",
    lhs = "<C-v>",
    rhs = clipboard.paste_insert,
    desc = "gui-keymap: Paste",
    hint_key = "paste",
    preserve_mode = true,
  },
  {
    feature = "select_all",
    force = true,
    mode = "n",
    lhs = "<C-a>",
    rhs = select_all_normal,
    desc = "gui-keymap: Select all",
    hint_key = "select_all",
    preserve_mode = false,
  },
  {
    feature = "select_all",
    force = true,
    mode = "i",
    lhs = "<C-a>",
    rhs = select_all_insert,
    desc = "gui-keymap: Select all",
    hint_key = "select_all",
    preserve_mode = false,
  },
  {
    feature = "delete_selection",
    force = true,
    mode = "x",
    lhs = "<BS>",
    rhs = clipboard.delete_selection_blackhole,
    desc = "gui-keymap: Delete selection",
    preserve_mode = false,
  },
  {
    feature = "delete_selection",
    force = true,
    mode = "x",
    lhs = "<Del>",
    rhs = clipboard.delete_selection_blackhole,
    desc = "gui-keymap: Delete selection",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<S-Left>",
    rhs = "v<Left>",
    desc = "gui-keymap: Select left",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<kL>",
    rhs = "v<Left>",
    desc = "gui-keymap: Select left (terminal fallback)",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<S-Right>",
    rhs = "v<Right>",
    desc = "gui-keymap: Select right",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<kR>",
    rhs = "v<Right>",
    desc = "gui-keymap: Select right (terminal fallback)",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<S-Up>",
    rhs = "v<Up>",
    desc = "gui-keymap: Select up",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<kU>",
    rhs = "v<Up>",
    desc = "gui-keymap: Select up (terminal fallback)",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<S-Down>",
    rhs = "v<Down>",
    desc = "gui-keymap: Select down",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "n",
    lhs = "<kD>",
    rhs = "v<Down>",
    desc = "gui-keymap: Select down (terminal fallback)",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<S-Left>",
    rhs = "<Left>",
    desc = "gui-keymap: Expand selection left",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<kL>",
    rhs = "<Left>",
    desc = "gui-keymap: Expand selection left (terminal fallback)",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<S-Right>",
    rhs = "<Right>",
    desc = "gui-keymap: Expand selection right",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<kR>",
    rhs = "<Right>",
    desc = "gui-keymap: Expand selection right (terminal fallback)",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<S-Up>",
    rhs = "<Up>",
    desc = "gui-keymap: Expand selection up",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<kU>",
    rhs = "<Up>",
    desc = "gui-keymap: Expand selection up (terminal fallback)",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<S-Down>",
    rhs = "<Down>",
    desc = "gui-keymap: Expand selection down",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "x",
    lhs = "<kD>",
    rhs = "<Down>",
    desc = "gui-keymap: Expand selection down (terminal fallback)",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<S-Left>",
    rhs = "<Esc>v<Left>",
    desc = "gui-keymap: Select left",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<kL>",
    rhs = "<Esc>v<Left>",
    desc = "gui-keymap: Select left (terminal fallback)",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<S-Right>",
    rhs = "<Esc>v<Right>",
    desc = "gui-keymap: Select right",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<kR>",
    rhs = "<Esc>v<Right>",
    desc = "gui-keymap: Select right (terminal fallback)",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<S-Up>",
    rhs = "<Esc>v<Up>",
    desc = "gui-keymap: Select up",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<kU>",
    rhs = "<Esc>v<Up>",
    desc = "gui-keymap: Select up (terminal fallback)",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<S-Down>",
    rhs = "<Esc>v<Down>",
    desc = "gui-keymap: Select down",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "i",
    lhs = "<kD>",
    rhs = "<Esc>v<Down>",
    desc = "gui-keymap: Select down (terminal fallback)",
    preserve_mode = false,
  },
  {
    feature = "word_delete",
    force = true,
    mode = "n",
    lhs = "<C-BS>",
    rhs = "db",
    desc = "gui-keymap: Delete previous word",
    hint_key = "delete_prev_word",
    preserve_mode = true,
  },
  {
    feature = "word_delete",
    force = true,
    mode = "n",
    lhs = "<C-Del>",
    rhs = "dw",
    desc = "gui-keymap: Delete next word",
    hint_key = "delete_next_word",
    preserve_mode = true,
  },
  {
    feature = "word_delete",
    force = true,
    mode = "i",
    lhs = "<C-BS>",
    rhs = "<C-o>db",
    desc = "gui-keymap: Delete previous word",
    hint_key = "delete_prev_word",
    preserve_mode = true,
  },
  {
    feature = "word_delete",
    force = true,
    mode = "i",
    lhs = "<C-Del>",
    rhs = "<C-o>dw",
    desc = "gui-keymap: Delete next word",
    hint_key = "delete_next_word",
    preserve_mode = true,
  },
  {
    feature = "save",
    force = true,
    mode = "n",
    lhs = "<C-s>",
    rhs = save_buffer,
    desc = "gui-keymap: Save buffer",
    hint_key = "save",
    preserve_mode = true,
  },
  {
    feature = "save",
    force = true,
    mode = "i",
    lhs = "<C-s>",
    rhs = save_buffer_insert,
    desc = "gui-keymap: Save buffer",
    hint_key = "save",
    preserve_mode = false,
  },
  {
    feature = "save",
    force = true,
    mode = "x",
    lhs = "<C-s>",
    rhs = save_buffer,
    desc = "gui-keymap: Save buffer",
    hint_key = "save",
    preserve_mode = true,
  },
  {
    feature = "quit",
    force = true,
    mode = "n",
    lhs = "<C-q>",
    rhs = quit_current,
    desc = "gui-keymap: Save and quit current file",
    hint_key = "quit",
    preserve_mode = false,
  },
  {
    feature = "quit",
    force = true,
    mode = "i",
    lhs = "<C-q>",
    rhs = quit_current_insert,
    desc = "gui-keymap: Save and quit current file",
    hint_key = "quit",
    preserve_mode = false,
  },
  {
    feature = "home_end",
    force = true,
    mode = "n",
    lhs = "<Home>",
    rhs = "0",
    desc = "gui-keymap: Line start",
    hint_key = "home",
    preserve_mode = true,
  },
  {
    feature = "home_end",
    force = true,
    mode = "n",
    lhs = "<End>",
    rhs = "$",
    desc = "gui-keymap: Line end",
    hint_key = "end",
    preserve_mode = true,
  },
  {
    feature = "home_end",
    force = true,
    mode = "x",
    lhs = "<Home>",
    rhs = "0",
    desc = "gui-keymap: Line start",
    hint_key = "home",
    preserve_mode = false,
  },
  {
    feature = "home_end",
    force = true,
    mode = "x",
    lhs = "<End>",
    rhs = "$",
    desc = "gui-keymap: Line end",
    hint_key = "end",
    preserve_mode = false,
  },
  {
    feature = "home_end",
    force = true,
    mode = "i",
    lhs = "<Home>",
    rhs = "<C-o>0",
    desc = "gui-keymap: Line start",
    hint_key = "home",
    preserve_mode = true,
  },
  {
    feature = "home_end",
    force = true,
    mode = "i",
    lhs = "<End>",
    rhs = "<C-o>$",
    desc = "gui-keymap: Line end",
    hint_key = "end",
    preserve_mode = true,
  },
}

M.explain = {
  ["<C-c>"] = { gui = '"+y / "+yy', vim = "y / yy" },
  ["<C-v>"] = { gui = '"+p', vim = "p" },
  ["<C-x>"] = { gui = '"+d', vim = "d" },
  ["<C-a>"] = { gui = "ggVG", vim = "ggVG" },
  ["<C-z>"] = { gui = "u", vim = "u" },
  ["<C-y>"] = { gui = "<C-r>", vim = "<C-r>" },
  ["<C-BS>"] = { gui = "db", vim = "db" },
  ["<C-Del>"] = { gui = "dw", vim = "dw" },
  ["<C-s>"] = { gui = ":write", vim = ":write / :w" },
  ["<C-q>"] = { gui = ":confirm wq", vim = ":wq" },
  ["<Home>"] = { gui = "0", vim = "0" },
  ["<End>"] = { gui = "$", vim = "$" },
}

---@param opts GuiKeymapOptions
---@param item GuiKeymapDefinition
---@return boolean
local function item_enabled(opts, item)
  if item.feature == "clipboard" then
    if type(opts.clipboard) == "table" then
      if item.toggle then
        return opts.clipboard[item.toggle] == true
      end
      return true
    end

    if opts.clipboard ~= true then
      return false
    end

    if item.toggle and opts[item.toggle] ~= nil then
      return opts[item.toggle] == true
    end

    return true
  end

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

---@param mode string|string[]
---@param rhs string|function
---@return string|function
local function materialize_rhs(mode, rhs)
  if type(rhs) == "function" then
    return rhs
  end

  local current_mode = type(mode) == "table" and mode[1] or mode
  current_mode = normalize_mode(current_mode)

  return function()
    if current_mode == "n" then
      vim.cmd.normal({ args = { rhs }, bang = true })
      return
    end

    vim.api.nvim_feedkeys(termcodes(rhs), "n", false)
  end
end

---@param opts GuiKeymapOptions
local function apply_main_registry(opts)
  for _, item in ipairs(M.registry) do
    if item_enabled(opts, item) then
      if item.lhs:match("^<k[LRUD]>$") then
        utils.mark_fallback_map(item.mode, item.lhs)
      end
      if item.feature == "shift_selection" or item.lhs:match("^<S%-") or item.lhs:match("^<k[LRUD]>$") then
        utils.mark_terminal_sensitive(item.mode, item.lhs)
      end

      local rhs = materialize_rhs(item.mode, item.rhs)
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
  clipboard.detect_status(opts.yanky_integration)

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

  local state = utils.get_state()
  local signature_parts = {}
  for _, entry in ipairs(entries) do
    table.insert(signature_parts, string.format("%s:%s:%s", entry.mode, entry[1], entry.desc))
  end
  table.sort(signature_parts)

  local signature = table.concat(signature_parts, "|")
  if state.which_key_signature == signature then
    return
  end

  if type(wk.add) == "function" then
    wk.add(entries)
    state.which_key_signature = signature
    return
  end

  if type(wk.register) == "function" then
    local grouped = {}
    for _, entry in ipairs(entries) do
      grouped[entry[1]] = entry.desc
    end
    wk.register(grouped)
    state.which_key_signature = signature
  end
end

---@param opts GuiKeymapOptions
function M.apply(opts)
  utils.clear_plugin_maps()
  apply_main_registry(opts)
  apply_yanky_registry(opts)
  register_with_which_key(opts)
end

---@param key string
---@return table|nil
function M.explain_key(key)
  return M.explain[key]
end

function M.explain_keys()
  local keys = vim.tbl_keys(M.explain)
  table.sort(keys)
  return keys
end

return M
