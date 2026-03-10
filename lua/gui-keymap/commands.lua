local M = {
  _registered = false,
}

function M.setup()
  if M._registered then
    return
  end

  local plugin = require("gui-keymap")

  vim.api.nvim_create_user_command("GuiKeymapDemo", function()
    require("gui-keymap.demo").open()
  end, { desc = "Open gui-keymap demo buffer" })

  vim.api.nvim_create_user_command("GuiKeymapInfo", function()
    plugin.show_info()
  end, { desc = "Show gui-keymap diagnostics" })

  vim.api.nvim_create_user_command("GuiKeymapEnable", function()
    plugin.enable()
  end, { desc = "Enable gui-keymap mappings" })

  vim.api.nvim_create_user_command("GuiKeymapDisable", function()
    plugin.disable()
  end, { desc = "Disable gui-keymap mappings" })

  vim.api.nvim_create_user_command("GuiKeymapList", function()
    plugin.list_keymaps()
  end, { desc = "List active gui-keymap mappings" })

  vim.api.nvim_create_user_command("GuiKeymapSkipped", function()
    plugin.list_skipped_keymaps()
  end, { desc = "List skipped gui-keymap mappings" })

  vim.api.nvim_create_user_command("GuiKeymapExplain", function(args)
    plugin.explain_key(args.args)
  end, {
    desc = "Explain a gui-keymap key",
    nargs = 1,
    complete = function()
      return require("gui-keymap.keymaps").explain_keys()
    end,
  })

  vim.api.nvim_create_user_command("GuiKeymapHintReset", function()
    plugin.reset_hints()
  end, { desc = "Reset gui-keymap hint counters" })

  vim.api.nvim_create_user_command("GuiKeymapRefresh", function()
    plugin.refresh()
  end, { desc = "Re-apply gui-keymap mappings" })

  M._registered = true
end

return M
