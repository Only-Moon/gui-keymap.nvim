if vim.g.loaded_gui_keymap == 1 then
  return
end

vim.g.loaded_gui_keymap = 1

require("gui-keymap.commands").setup()
