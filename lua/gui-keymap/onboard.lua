local M = {
  shown = false,
}

function M.setup(opts)
  if opts.show_welcome ~= true then
    return
  end

  local group = vim.api.nvim_create_augroup("GuiKeymapOnboard", { clear = true })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    once = true,
    callback = function()
      if M.shown then
        return
      end
      M.shown = true
      vim.notify(
        "Welcome to gui-keymap.nvim\n\nRun :GuiKeymapDemo to try GUI shortcuts safely.",
        vim.log.levels.INFO,
        { title = "gui-keymap" }
      )
    end,
  })
end

return M
