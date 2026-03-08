local utils = require("gui-keymap.utils")

local M = {}

---@class GuiKeymapDefinition
---@field feature string
---@field mode string|string[]
---@field lhs string
---@field rhs string|function
---@field desc string
---@field toggle string|nil

---@type GuiKeymapDefinition[]
M.registry = {
  { feature = "undo_redo", toggle = "undo", mode = "n", lhs = "<C-z>", rhs = "u", desc = "gui-keymap: Undo" },
  { feature = "undo_redo", toggle = "redo", mode = "n", lhs = "<C-y>", rhs = "<C-r>", desc = "gui-keymap: Redo" },
  { feature = "undo_redo", toggle = "undo", mode = "i", lhs = "<C-z>", rhs = "<C-o>u", desc = "gui-keymap: Undo" },
  { feature = "undo_redo", toggle = "redo", mode = "i", lhs = "<C-y>", rhs = "<C-o><C-r>", desc = "gui-keymap: Redo" },

  { feature = "clipboard", toggle = "copy", mode = "x", lhs = "<C-c>", rhs = '"+y', desc = "gui-keymap: Copy selection" },
  { feature = "clipboard", toggle = "copy", mode = "n", lhs = "<C-c>", rhs = '"+yy', desc = "gui-keymap: Copy line" },
  { feature = "clipboard", toggle = "cut", mode = "x", lhs = "<C-x>", rhs = '"+d', desc = "gui-keymap: Cut selection" },
  { feature = "clipboard", toggle = "paste", mode = "n", lhs = "<C-v>", rhs = '"+p', desc = "gui-keymap: Paste" },
  { feature = "clipboard", toggle = "paste", mode = "i", lhs = "<C-v>", rhs = '"+p', desc = "gui-keymap: Paste" },

  { feature = "select_all", mode = "n", lhs = "<C-a>", rhs = "ggVG", desc = "gui-keymap: Select all" },
  { feature = "select_all", mode = "i", lhs = "<C-a>", rhs = "<Esc>ggVG", desc = "gui-keymap: Select all" },

  { feature = "delete_selection", mode = "x", lhs = "<BS>", rhs = '"_d', desc = "gui-keymap: Delete selection" },
  { feature = "delete_selection", mode = "x", lhs = "<Del>", rhs = '"_d', desc = "gui-keymap: Delete selection" },

  { feature = "shift_selection", mode = "n", lhs = "<S-Left>", rhs = "v<Left>", desc = "gui-keymap: Select left" },
  { feature = "shift_selection", mode = "n", lhs = "<S-Right>", rhs = "v<Right>", desc = "gui-keymap: Select right" },
  { feature = "shift_selection", mode = "n", lhs = "<S-Up>", rhs = "v<Up>", desc = "gui-keymap: Select up" },
  { feature = "shift_selection", mode = "n", lhs = "<S-Down>", rhs = "v<Down>", desc = "gui-keymap: Select down" },

  { feature = "shift_selection", mode = "x", lhs = "<S-Left>", rhs = "<Left>", desc = "gui-keymap: Expand selection left" },
  { feature = "shift_selection", mode = "x", lhs = "<S-Right>", rhs = "<Right>", desc = "gui-keymap: Expand selection right" },
  { feature = "shift_selection", mode = "x", lhs = "<S-Up>", rhs = "<Up>", desc = "gui-keymap: Expand selection up" },
  { feature = "shift_selection", mode = "x", lhs = "<S-Down>", rhs = "<Down>", desc = "gui-keymap: Expand selection down" },

  { feature = "shift_selection", mode = "i", lhs = "<S-Left>", rhs = "<Esc>v<Left>", desc = "gui-keymap: Select left" },
  { feature = "shift_selection", mode = "i", lhs = "<S-Right>", rhs = "<Esc>v<Right>", desc = "gui-keymap: Select right" },
  { feature = "shift_selection", mode = "i", lhs = "<S-Up>", rhs = "<Esc>v<Up>", desc = "gui-keymap: Select up" },
  { feature = "shift_selection", mode = "i", lhs = "<S-Down>", rhs = "<Esc>v<Down>", desc = "gui-keymap: Select down" },
}

local yanky_registry = {
  { mode = "n", lhs = "]p", rhs = "<Plug>(YankyPutIndentAfterLinewise)", desc = "gui-keymap: Yanky ]p" },
  { mode = "n", lhs = "[p", rhs = "<Plug>(YankyPutIndentBeforeLinewise)", desc = "gui-keymap: Yanky [p" },
  { mode = "n", lhs = "]P", rhs = "<Plug>(YankyPutIndentAfterLinewise)", desc = "gui-keymap: Yanky ]P" },
  { mode = "n", lhs = "[P", rhs = "<Plug>(YankyPutIndentBeforeLinewise)", desc = "gui-keymap: Yanky [P" },
  { mode = "n", lhs = ">p", rhs = "<Plug>(YankyPutIndentAfterShiftRight)", desc = "gui-keymap: Yanky >p" },
  { mode = "n", lhs = "<p", rhs = "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "gui-keymap: Yanky <p" },
  { mode = "n", lhs = ">P", rhs = "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "gui-keymap: Yanky >P" },
  { mode = "n", lhs = "<P", rhs = "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "gui-keymap: Yanky <P" },
  { mode = "n", lhs = "=p", rhs = "<Plug>(YankyPutAfterFilter)", desc = "gui-keymap: Yanky =p" },
  { mode = "n", lhs = "=P", rhs = "<Plug>(YankyPutBeforeFilter)", desc = "gui-keymap: Yanky =P" },
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

---@param opts GuiKeymapOptions
local function apply_main_registry(opts)
  for _, item in ipairs(M.registry) do
    if item_enabled(opts, item) then
      utils.safe_map(item.mode, item.lhs, item.rhs, { desc = item.desc, silent = true, noremap = true }, item.feature)
    else
      utils.mark_feature_disabled(item.feature)
    end
  end
end

---@param opts GuiKeymapOptions
local function apply_yanky_registry(opts)
  local has_yanky = pcall(require, "yanky")
  utils.set_yanky_status(has_yanky, opts.yanky_integration == true)

  if not has_yanky or opts.yanky_integration ~= true then
    if opts.yanky_integration ~= true then
      utils.mark_feature_disabled("yanky_integration")
    end
    return
  end

  for _, item in ipairs(yanky_registry) do
    utils.safe_map(item.mode, item.lhs, item.rhs, { desc = item.desc, silent = true, noremap = true }, "yanky_integration")
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
