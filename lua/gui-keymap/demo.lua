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
  "Ctrl+Backspace -> Delete previous word",
  "Ctrl+Delete -> Delete next word",
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

function M.showcase()
  local lines = vim.deepcopy(demo_lines)
  table.insert(lines, 2, "Interactive showcase: try keys and compare with :GuiKeymapInfo.")
  table.insert(lines, "")
  table.insert(lines, "Record demo GIF workflow:")
  table.insert(lines, "1. asciinema rec demo.cast")
  table.insert(lines, "2. Run :GuiKeymapDemo and test mappings")
  table.insert(lines, "3. Stop recording with Ctrl+D")
  table.insert(lines, "4. Convert cast to GIF (agg/asciicast2gif)")
  open_with_lines(lines)
end

return M
