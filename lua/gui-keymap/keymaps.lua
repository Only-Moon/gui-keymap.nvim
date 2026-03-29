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

local function select_all_with_feedkeys()
  vim.api.nvim_feedkeys(termcodes("<Esc>ggVG"), "nx", false)
end

local keyword_pattern = vim.regex([[\k]])

local function is_space(char)
  return char ~= "" and char:match("%s") ~= nil
end

local function is_keyword(char)
  return char ~= "" and keyword_pattern:match_str(char) ~= nil
end

local function str_char_at(text, idx)
  return vim.fn.strcharpart(text, idx, 1)
end

local function str_char_count(text)
  return vim.fn.strchars(text)
end

local function char_to_byte(text, idx)
  return vim.str_byteindex(text, idx)
end

local function byte_to_char(text, idx)
  return vim.str_utfindex(text, idx)
end

local function apply_line_edit(start_char, finish_char, target_mode)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  local before = vim.fn.strcharpart(line, 0, start_char)
  local after = vim.fn.strcharpart(line, finish_char)
  local updated = before .. after

  vim.api.nvim_set_current_line(updated)

  local cursor_byte = char_to_byte(updated, start_char)
  if target_mode == "n" then
    local max_col = math.max(str_char_count(updated) - 1, 0)
    cursor_byte = char_to_byte(updated, math.min(start_char, max_col))
  end

  vim.api.nvim_win_set_cursor(0, { row, cursor_byte })
end

local function delete_previous_word_gui(target_mode)
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local caret_char = byte_to_char(line, col)

  if (target_mode == "n" or target_mode == "i") and str_char_count(line) > 0 then
    caret_char = math.min(caret_char + 1, str_char_count(line))
  end

  if caret_char <= 0 then
    return
  end

  local start_char = caret_char

  while start_char > 0 and is_space(str_char_at(line, start_char - 1)) do
    start_char = start_char - 1
  end

  while start_char > 0 and is_keyword(str_char_at(line, start_char - 1)) do
    start_char = start_char - 1
  end

  while start_char > 0 do
    local char = str_char_at(line, start_char - 1)
    if is_space(char) or is_keyword(char) then
      break
    end
    start_char = start_char - 1
  end

  if start_char == caret_char then
    return
  end

  apply_line_edit(start_char, caret_char, target_mode)
end

local function delete_prev_word_normal()
  delete_previous_word_gui("n")
end

local function delete_prev_word_insert()
  delete_previous_word_gui("i")
end

local function delete_next_word_gui(target_mode)
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local caret_char = byte_to_char(line, col)
  local total_chars = str_char_count(line)

  if caret_char >= total_chars then
    return
  end

  local finish_char = caret_char

  if is_space(str_char_at(line, finish_char)) then
    while finish_char < total_chars and is_space(str_char_at(line, finish_char)) do
      finish_char = finish_char + 1
    end
  elseif is_keyword(str_char_at(line, finish_char)) then
    while finish_char < total_chars and is_keyword(str_char_at(line, finish_char)) do
      finish_char = finish_char + 1
    end
  else
    while finish_char < total_chars do
      local char = str_char_at(line, finish_char)
      if is_space(char) or is_keyword(char) then
        break
      end
      finish_char = finish_char + 1
    end
  end

  while finish_char < total_chars and is_space(str_char_at(line, finish_char)) do
    finish_char = finish_char + 1
  end

  if finish_char == caret_char then
    return
  end

  apply_line_edit(caret_char, finish_char, target_mode)
end

local function delete_next_word_normal()
  delete_next_word_gui("n")
end

local function delete_next_word_insert()
  delete_next_word_gui("i")
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
    rhs = "u",
    desc = "gui-keymap: Undo",
    hint_key = "undo",
    preserve_mode = true,
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
    preserve_mode = true,
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
    preserve_mode = true,
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
    preserve_mode = true,
  },
  {
    feature = "clipboard",
    toggle = "copy",
    force = true,
    mode = "v",
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
    mode = "v",
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
    rhs = "ggVG",
    desc = "gui-keymap: Select all",
    hint_key = "select_all",
    preserve_mode = false,
  },
  {
    feature = "select_all",
    force = true,
    mode = "v",
    lhs = "<C-a>",
    rhs = select_all_with_feedkeys,
    desc = "gui-keymap: Select all",
    hint_key = "select_all",
    preserve_mode = false,
  },
  {
    feature = "select_all",
    force = true,
    mode = "i",
    lhs = "<C-a>",
    rhs = select_all_with_feedkeys,
    desc = "gui-keymap: Select all",
    hint_key = "select_all",
    preserve_mode = false,
  },
  {
    feature = "delete_selection",
    force = true,
    mode = "v",
    lhs = "<BS>",
    rhs = clipboard.delete_selection_blackhole,
    desc = "gui-keymap: Delete selection",
    preserve_mode = false,
  },
  {
    feature = "delete_selection",
    force = true,
    mode = "v",
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
    mode = "v",
    lhs = "<S-Left>",
    rhs = "<Left>",
    desc = "gui-keymap: Expand selection left",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "v",
    lhs = "<kL>",
    rhs = "<Left>",
    desc = "gui-keymap: Expand selection left (terminal fallback)",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "v",
    lhs = "<S-Right>",
    rhs = "<Right>",
    desc = "gui-keymap: Expand selection right",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "v",
    lhs = "<kR>",
    rhs = "<Right>",
    desc = "gui-keymap: Expand selection right (terminal fallback)",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "v",
    lhs = "<S-Up>",
    rhs = "<Up>",
    desc = "gui-keymap: Expand selection up",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "v",
    lhs = "<kU>",
    rhs = "<Up>",
    desc = "gui-keymap: Expand selection up (terminal fallback)",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "v",
    lhs = "<S-Down>",
    rhs = "<Down>",
    desc = "gui-keymap: Expand selection down",
    preserve_mode = false,
  },
  {
    feature = "shift_selection",
    force = true,
    mode = "v",
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
    rhs = delete_prev_word_normal,
    desc = "gui-keymap: Delete previous word",
    hint_key = "delete_prev_word",
    preserve_mode = true,
  },
  {
    feature = "word_delete",
    force = true,
    mode = "n",
    lhs = "<C-Del>",
    rhs = delete_next_word_normal,
    desc = "gui-keymap: Delete next word",
    hint_key = "delete_next_word",
    preserve_mode = true,
  },
  {
    feature = "word_delete",
    force = true,
    mode = "i",
    lhs = "<C-BS>",
    rhs = delete_prev_word_insert,
    desc = "gui-keymap: Delete previous word",
    hint_key = "delete_prev_word",
    preserve_mode = true,
  },
  {
    feature = "word_delete",
    force = true,
    mode = "i",
    lhs = "<C-h>",
    rhs = delete_prev_word_insert,
    desc = "gui-keymap: Delete previous word (terminal fallback)",
    hint_key = "delete_prev_word",
    preserve_mode = true,
  },
  {
    feature = "word_delete",
    force = true,
    mode = "i",
    lhs = "<C-Del>",
    rhs = delete_next_word_insert,
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
    mode = "v",
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
    mode = "v",
    lhs = "<Home>",
    rhs = "0",
    desc = "gui-keymap: Line start",
    hint_key = "home",
    preserve_mode = false,
  },
  {
    feature = "home_end",
    force = true,
    mode = "v",
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
  ["<C-BS>"] = { gui = "delete previous word", vim = "closest: <C-w> (insert) / db (normal)" },
  ["<C-Del>"] = { gui = "delete next word", vim = "closest: dw (GUI delete does not yank)" },
  ["<C-s>"] = { gui = ":write", vim = ":write / :w" },
  ["<C-q>"] = { gui = ":confirm wq", vim = ":wq" },
  ["<Home>"] = { gui = "0", vim = "0" },
  ["<End>"] = { gui = "$", vim = "$" },
}

---@param opts GuiKeymapOptionsStrict
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

local function expand_modes(mode)
  if type(mode) == "table" then
    return mode
  end
  return { mode }
end

---@param lhs string
---@return boolean
local function is_fallback_shift_key(lhs)
  return lhs:match("^<k[LRUD]>$") ~= nil
end

---@param feature string
---@param lhs string
---@return boolean
local function is_terminal_sensitive_map(feature, lhs)
  if feature == "shift_selection" then
    return true
  end

  if lhs:match("^<S%-") then
    return true
  end

  return is_fallback_shift_key(lhs)
end

---@param item GuiKeymapDefinition
local function track_map_characteristics(item)
  if is_fallback_shift_key(item.lhs) then
    utils.mark_fallback_map(item.mode, item.lhs)
  end

  if is_terminal_sensitive_map(item.feature, item.lhs) then
    utils.mark_terminal_sensitive(item.mode, item.lhs)
  end
end

---@param item GuiKeymapDefinition
---@param opts GuiKeymapOptionsStrict
local function apply_registry_item(item, opts)
  track_map_characteristics(item)

  local rhs, hint_opts = hints.wrap(item.mode, item.rhs, item.hint_key)
  local map_opts = vim.tbl_extend("force", { desc = item.desc, silent = true, noremap = true }, hint_opts or {})
  utils.safe_map(item.mode, item.lhs, rhs, map_opts, item.feature, item.force and opts.force_priority)
end

---@param opts GuiKeymapOptionsStrict
local function apply_main_registry(opts)
  for _, item in ipairs(M.registry) do
    if not item_enabled(opts, item) then
      utils.mark_feature_disabled(item.feature)
      goto continue
    end

    apply_registry_item(item, opts)
    ::continue::
  end
end

---@param opts GuiKeymapOptionsStrict
local function apply_yanky_registry(opts)
  clipboard.detect_status(opts.yanky_integration)

  if opts.yanky_integration ~= true then
    utils.mark_feature_disabled("yanky_integration")
  end
end

local function register_with_which_key(opts)
  local ok, wk = pcall(require, "which-key")
  utils.get_state().set_which_key_status(ok)

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

---@param opts GuiKeymapOptionsStrict
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

function M.audit_registry()
  local issues = {}
  local seen = {}

  for index, item in ipairs(M.registry) do
    if type(item.desc) ~= "string" or item.desc == "" then
      table.insert(issues, string.format("entry %d is missing a description", index))
    end

    if type(item.feature) ~= "string" or item.feature == "" then
      table.insert(issues, string.format("entry %d is missing a feature name", index))
    end

    if type(item.lhs) ~= "string" or item.lhs == "" then
      table.insert(issues, string.format("entry %d is missing a left-hand side", index))
    end

    for _, mode in ipairs(expand_modes(item.mode)) do
      local key = string.format("%s::%s", mode, item.lhs)
      if seen[key] then
        table.insert(
          issues,
          string.format(
            "duplicate key assignment for %s in mode %s (entries %d and %d)",
            item.lhs,
            mode,
            seen[key],
            index
          )
        )
      else
        seen[key] = index
      end
    end
  end

  return issues
end

return M
