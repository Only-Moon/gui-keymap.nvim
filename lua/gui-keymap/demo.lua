local M = {}

local demo_lines = {
  "gui-keymap.nvim demo",
  "",
  "This buffer allows you to try all gui-keymap.nvim shortcuts.",
  "",
  "Try these shortcuts:",
  "",
  "Ctrl+C  -> Copy",
  "Ctrl+V  -> Paste",
  "Ctrl+X  -> Cut",
  "Ctrl+A  -> Select all",
  "Ctrl+Z  -> Undo",
  "Ctrl+Y  -> Redo",
  "Ctrl+S  -> Save",
  "Ctrl+Q  -> Save and quit current file",
  "Ctrl+Backspace -> Delete previous word",
  "Ctrl+Delete -> Delete next word",
  "Home / End -> Move to line start / line end",
  "Backspace/Delete in Visual -> Delete selection",
  "",
  "Shift + Arrow keys -> GUI-style selection",
  "",
  "Optional: set preserve_mode=true to return to your original mode",
  "after mapped actions.",
  "",
  "Nothing in this buffer will affect your files.",
  "",
  "Press :q to close the demo.",
}

local function open_with_lines(lines)
  vim.cmd("enew")

  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true
  vim.bo[buf].filetype = "gui-keymap-demo"

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

function M.open()
  open_with_lines(demo_lines)
end

return M
