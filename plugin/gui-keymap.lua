if vim.g.loaded_gui_keymap == 1 then
  return
end

vim.g.loaded_gui_keymap = 1

local plugin = require("gui-keymap")

vim.api.nvim_create_user_command("GuiKeymapInfo", function()
  plugin.show_info()
end, { desc = "Show gui-keymap diagnostics" })

vim.api.nvim_create_user_command("GuiKeymapHintReset", function()
  plugin.reset_hints()
end, { desc = "Reset gui-keymap hint counters" })

vim.api.nvim_create_user_command("GuiKeymapRefresh", function()
  plugin.refresh()
end, { desc = "Re-apply gui-keymap mappings" })

vim.api.nvim_create_user_command("GuiKeymapDemo", function()
  require("gui-keymap.demo").open()
end, { desc = "Open gui-keymap demo buffer" })

vim.api.nvim_create_user_command("GuiKeymapShowcase", function()
  require("gui-keymap.demo").showcase()
end, { desc = "Open gui-keymap showcase buffer" })

vim.schedule(function()
  plugin.setup()
end)
