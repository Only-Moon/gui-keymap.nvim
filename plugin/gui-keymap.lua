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

plugin.setup()
