local hints = require("gui-keymap.hints")
local utils = require("gui-keymap.utils")

local M = {}

local function termcodes(keys)
  return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

local function feed(keys)
  vim.api.nvim_feedkeys(termcodes(keys), "m", false)
end

local function run_normal(keys)
  vim.cmd.normal({ args = { keys }, bang = true })
end

local function yanky_runtime_installed()
  return #vim.api.nvim_get_runtime_file("lua/yanky.lua", false) > 0
    or #vim.api.nvim_get_runtime_file("lua/yanky/init.lua", false) > 0
end

local function ensure_yanky_loaded()
  if package.loaded["yanky"] ~= nil then
    return true
  end

  if not yanky_runtime_installed() then
    return false
  end

  pcall(require, "yanky")
  return package.loaded["yanky"] ~= nil
end

local function sync_unnamed_from_plus()
  local plus = vim.fn.getreg("+")
  if plus == "" then
    return
  end
  vim.fn.setreg('"', plus, vim.fn.getregtype("+"))
end

local function sync_plus_from_unnamed()
  local unnamed = vim.fn.getreg('"')
  if unnamed == "" then
    return
  end
  local regtype = vim.fn.getregtype('"')
  vim.fn.setreg("+", unnamed, regtype)
  vim.fn.setreg("*", unnamed, regtype)
end

local function copy_selection()
  if ensure_yanky_loaded() then
    feed("<Plug>(YankyYank)")
    sync_plus_from_unnamed()
    return
  end
  run_normal('"+y')
  sync_unnamed_from_plus()
end

local function copy_line()
  if ensure_yanky_loaded() then
    run_normal("yy")
    sync_plus_from_unnamed()
    return
  end
  run_normal('"+yy')
  sync_unnamed_from_plus()
end

local function cut_selection()
  if ensure_yanky_loaded() then
    feed("<Plug>(YankyYank)")
    run_normal([[gv"_d]])
    sync_plus_from_unnamed()
    return
  end
  run_normal('"+d')
  sync_unnamed_from_plus()
end

local function paste_normal()
  if ensure_yanky_loaded() then
    feed("<Plug>(YankyPutAfter)")
    return
  end
  if vim.fn.getreg("+") ~= "" then
    run_normal('"+p')
    return
  end
  run_normal("p")
end

local function paste_insert()
  if ensure_yanky_loaded() then
    feed("<Esc><Plug>(YankyPutAfter)a")
    return
  end
  local clip = vim.fn.getreg("+")
  if clip == "" then
    clip = vim.fn.getreg('"')
  end
  if clip == "" then
    return
  end
  vim.api.nvim_paste(clip, true, -1)
end

local function delete_selection_blackhole()
  local plus, plus_type = vim.fn.getreg("+"), vim.fn.getregtype("+")
  local star, star_type = vim.fn.getreg("*"), vim.fn.getregtype("*")
  run_normal('"_d')
  vim.fn.setreg("+", plus, plus_type)
  vim.fn.setreg("*", star, star_type)
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
    mode = "x",
    lhs = "<C-c>",
    rhs = copy_selection,
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
    rhs = copy_line,
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
    rhs = cut_selection,
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
    rhs = paste_normal,
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
    rhs = paste_insert,
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
    mode = "i",
    lhs = "<C-a>",
    rhs = "<Esc>ggVG",
    desc = "gui-keymap: Select all",
    hint_key = "select_all",
    preserve_mode = false,
  },

  {
    feature = "delete_selection",
    force = true,
    mode = "x",
    lhs = "<BS>",
    rhs = delete_selection_blackhole,
    desc = "gui-keymap: Delete selection",
    preserve_mode = false,
  },
  {
    feature = "delete_selection",
    force = true,
    mode = "x",
    lhs = "<Del>",
    rhs = delete_selection_blackhole,
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

local function escape_to_normal()
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "n", false)
end

---@param rhs string|function
---@param opts GuiKeymapOptions
---@param item GuiKeymapDefinition
---@return string|function
local function with_mode_restore(rhs, opts, item)
  if not opts.preserve_mode then
    return rhs
  end

  if item.preserve_mode == false then
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
      local rhs = with_mode_restore(item.rhs, opts, item)
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
  local loaded_yanky = package.loaded["yanky"] ~= nil
  local has_yanky = loaded_yanky or yanky_runtime_installed()

  utils.set_yanky_status(has_yanky, loaded_yanky, opts.yanky_integration == true)

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

---@param key string
---@return table|nil
function M.explain_key(key)
  return M.explain[key]
end

return M
