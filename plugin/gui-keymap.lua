if vim.g.loaded_gui_keymap == 1 then
  return
end

vim.g.loaded_gui_keymap = 1

require("gui-keymap.commands").setup()

vim.schedule(function()
  local ok, plugin = pcall(require, "gui-keymap")
  if not ok or plugin._setup_done then
    return
  end

  plugin.setup()
end)
