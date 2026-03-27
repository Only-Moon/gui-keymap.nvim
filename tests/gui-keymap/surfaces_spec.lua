local plugin = require("gui-keymap")
local t = require("tests.gui-keymap.helpers")

describe("gui-keymap demo", function()
  before_each(function()
    t.reset_runtime()
  end)

  it("opens scratch demo buffer", function()
    require("gui-keymap.demo").open()

    local buf = vim.api.nvim_get_current_buf()
    assert.are.same("nofile", vim.bo[buf].buftype)
    assert.are.same("wipe", vim.bo[buf].bufhidden)
    assert.are.same(false, vim.bo[buf].swapfile)
    assert.are.same("gui-keymap-demo", vim.bo[buf].filetype)

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    assert.is_true(#lines > 0)
    assert.are.same("gui-keymap.nvim demo", lines[1])
    assert.is_true(vim.tbl_contains(lines, "Ctrl+S  -> :write -> Save"))
    assert.is_true(vim.tbl_contains(lines, "Ctrl+Q  -> :wq -> Save and quit current file"))
    assert.is_true(vim.tbl_contains(lines, "Ctrl+Backspace  -> <C-w> / db -> Delete previous word"))
    assert.is_true(vim.tbl_contains(lines, "Ctrl+Delete  -> dw -> Delete next word"))
  end)
end)

describe("gui-keymap info surfaces", function()
  before_each(function()
    t.reset_runtime()
  end)

  it("opens info in a scratch buffer", function()
    plugin.setup({ show_welcome = false })
    plugin.show_info()

    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    assert.are.same("nofile", vim.bo[buf].buftype)
    assert.are.same("gui-keymap.nvim", lines[1])
  end)

  it("opens explain output in a scratch buffer", function()
    plugin.setup({ show_welcome = false })
    plugin.explain_key("<C-c>")

    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    assert.are.same("nofile", vim.bo[buf].buftype)
    assert.are.same("GuiKeymapExplain", lines[1])
    assert.is_true(vim.tbl_contains(lines, "Vim equivalent: y / yy"))
  end)
end)
