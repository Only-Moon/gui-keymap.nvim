local M = {}

---@class GuiKeymapDefinition
---@field mode string|string[]
---@field lhs string
---@field rhs string|function
---@field opts table|nil

---@type table<string, GuiKeymapDefinition[]>
M.registry = {
  copy = {
    { mode = "n", lhs = "<C-c>", rhs = '"+yy', opts = { desc = "GUI: Copy line", silent = true } },
    { mode = "x", lhs = "<C-c>", rhs = '"+y', opts = { desc = "GUI: Copy selection", silent = true } },
  },
  paste = {
    { mode = "n", lhs = "<C-v>", rhs = '"+p', opts = { desc = "GUI: Paste", silent = true } },
    { mode = "i", lhs = "<C-v>", rhs = '"+p', opts = { desc = "GUI: Paste", silent = true } },
  },
  cut = {
    { mode = "x", lhs = "<C-x>", rhs = '"+d', opts = { desc = "GUI: Cut selection", silent = true } },
  },
  select_all = {
    { mode = "n", lhs = "<C-a>", rhs = "ggVG", opts = { desc = "GUI: Select all", silent = true } },
    { mode = "i", lhs = "<C-a>", rhs = "<Esc>ggVG", opts = { desc = "GUI: Select all", silent = true } },
  },
  undo = {
    { mode = "n", lhs = "<C-z>", rhs = "u", opts = { desc = "GUI: Undo", silent = true } },
    { mode = "i", lhs = "<C-z>", rhs = "<C-o>u", opts = { desc = "GUI: Undo", silent = true } },
  },
  redo = {
    { mode = "n", lhs = "<C-y>", rhs = "<C-r>", opts = { desc = "GUI: Redo", silent = true } },
    { mode = "i", lhs = "<C-y>", rhs = "<C-o><C-r>", opts = { desc = "GUI: Redo", silent = true } },
  },
}

---@type table<string, boolean>
M._applied = {}

---@param feature string
---@param mappings GuiKeymapDefinition[]
local function set_feature_mappings(feature, mappings)
  for _, mapping in ipairs(mappings) do
    vim.keymap.set(mapping.mode, mapping.lhs, mapping.rhs, mapping.opts)
  end

  M._applied[feature] = true
end

---@param feature string
---@param mappings GuiKeymapDefinition[]
local function clear_feature_mappings(feature, mappings)
  if not M._applied[feature] then
    return
  end

  for _, mapping in ipairs(mappings) do
    pcall(vim.keymap.del, mapping.mode, mapping.lhs)
  end

  M._applied[feature] = false
end

---@param opts GuiKeymapOptions
function M.apply(opts)
  for feature, mappings in pairs(M.registry) do
    if opts[feature] then
      set_feature_mappings(feature, mappings)
    else
      clear_feature_mappings(feature, mappings)
    end
  end
end

return M
