local M = {}

local demo_lines = {
  "gui-keymap.nvim demo",
  "",
  "This buffer allows you to try GUI-style shortcuts.",
  "",
  "Try these shortcuts:",
  "",
  "Ctrl+C  -> Copy",
  "Ctrl+V  -> Paste",
  "Ctrl+X  -> Cut",
  "Ctrl+A  -> Select all",
  "Ctrl+Z  -> Undo",
  "Ctrl+Y  -> Redo",
  "",
  "Shift + Arrow keys -> GUI-style selection",
  "",
  "Nothing in this buffer will affect your files.",
  "",
  "Press :q to close the demo.",
}

function M.open()
  vim.cmd("enew")

  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true
  vim.bo[buf].filetype = "gui-keymap-demo"

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, demo_lines)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

return M
