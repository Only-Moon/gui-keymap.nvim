local M = {}

local shortcuts = {
  { "Ctrl+C", "y / yy", "Copy" },
  { "Ctrl+V", "p", "Paste" },
  { "Ctrl+X", "d", "Cut" },
  { "Ctrl+A", "ggVG", "Select all" },
  { "Ctrl+Z", "u", "Undo" },
  { "Ctrl+Y", "<C-r>", "Redo" },
  { "Ctrl+S", ":write", "Save" },
  { "Ctrl+Q", ":wq", "Save and quit current file" },
  { "Ctrl+Backspace", "<C-w> / db", "Delete previous word" },
  { "Ctrl+Delete", "dw", "Delete next word" },
  { "Home / End", "0 / $", "Move to line start / line end" },
  { "Backspace/Delete in Visual", '"_d', "Delete selection" },
  { "Shift + Arrow keys", "v + movement", "GUI-style selection" },
}

local function build_demo_lines()
  local lines = {
    "gui-keymap.nvim demo",
    "",
    "This buffer allows you to try all gui-keymap.nvim shortcuts.",
    "",
    "Try these shortcuts:",
    "",
  }

  for _, shortcut in ipairs(shortcuts) do
    table.insert(lines, string.format("%s  -> %s -> %s", shortcut[1], shortcut[2], shortcut[3]))
  end

  vim.list_extend(lines, {
    "",
    "Optional: set preserve_mode=true to return to your original mode",
    "after mapped actions.",
    "",
    "Nothing in this buffer will affect your files.",
    "",
    "Press :q to close the demo.",
  })

  return lines
end

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
  open_with_lines(build_demo_lines())
end

return M
