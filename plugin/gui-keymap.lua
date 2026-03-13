if vim.g.loaded_gui_keymap == 1 then
  return
end

vim.g.loaded_gui_keymap = 1

require("gui-keymap.commands").setup()

local ok, plugin = pcall(require, "gui-keymap")
if ok and not plugin._setup_done then
  plugin.setup()
end
