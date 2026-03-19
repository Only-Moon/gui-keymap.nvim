local plugin = require("gui-keymap")
local t = require("tests.gui-keymap.helpers")

describe("gui-keymap keycode mappings", function()
  before_each(function()
    t.reset_runtime()
  end)

  it("does not inject literal keycode text for normal-mode shift selection mappings", function()
    plugin.setup({ show_welcome = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "two" })
    vim.api.nvim_win_set_cursor(0, { 1, 1 })

    t.press("<S-Down>")

    assert.are.same({ "one", "two" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
  end)

  it("does not inject literal text for insert-mode shift selection mappings", function()
    plugin.setup({ show_welcome = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "two" })
    vim.api.nvim_win_set_cursor(0, { 1, 1 })
    vim.cmd("startinsert")

    t.press("<S-Down>")

    assert.are.same({ "one", "two" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    assert.is_true(vim.api.nvim_get_mode().mode == "v" or vim.api.nvim_get_mode().mode == "V")
  end)

  it("does not inject literal text for insert-mode delete previous word", function()
    plugin.setup({ show_welcome = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
    vim.api.nvim_win_set_cursor(0, { 1, 11 })
    vim.cmd("startinsert")

    t.press("<C-BS>")

    assert.are.same("hello ", vim.api.nvim_get_current_line())
  end)

  it("supports Ctrl+H as an insert-mode fallback for previous-word delete", function()
    plugin.setup({ show_welcome = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
    vim.api.nvim_win_set_cursor(0, { 1, 11 })
    vim.cmd("startinsert")

    t.execute_map("i", "<C-h>")

    assert.are.same("hello ", vim.api.nvim_get_current_line())
  end)

  it("deletes the next word without polluting unnamed or system clipboard in normal mode", function()
    plugin.setup({ show_welcome = false, yanky_integration = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello cruel world" })
    vim.api.nvim_win_set_cursor(0, { 1, 6 })
    t.seed_clipboard_registers("keep", "v")

    t.execute_map("n", "<C-Del>")

    assert.are.same("hello world", vim.api.nvim_get_current_line())
    assert.are.same("keep", vim.fn.getreg('"'))
    if t.plus_register_available() then
      assert.are.same("keep", vim.fn.getreg("+"))
    end
  end)

  it("deletes the next word without polluting unnamed or system clipboard in insert mode", function()
    plugin.setup({ show_welcome = false, yanky_integration = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello cruel world" })
    vim.api.nvim_win_set_cursor(0, { 1, 6 })
    t.seed_clipboard_registers("keep", "v")
    vim.cmd("startinsert")

    t.execute_map("i", "<C-Del>")

    assert.are.same("hello world", vim.api.nvim_get_current_line())
    assert.are.same("keep", vim.fn.getreg('"'))
    if t.plus_register_available() then
      assert.are.same("keep", vim.fn.getreg("+"))
    end
  end)

  it("copies the selected text from visual mode without corrupting the buffer", function()
    plugin.setup({ show_welcome = false, yanky_integration = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha beta" })
    vim.cmd("normal! 0ve")
    vim.fn.setreg('"', "")
    if t.plus_register_available() then
      vim.fn.setreg("+", "")
    end

    t.execute_map("v", "<C-c>")

    assert.are.same("alpha beta", vim.api.nvim_get_current_line())
    assert.are.same("alpha", vim.fn.getreg('"'))
    if t.plus_register_available() then
      assert.are.same("alpha", vim.fn.getreg("+"))
    end
  end)

  it("cuts only the selected text from visual mode without inserting literal text", function()
    plugin.setup({ show_welcome = false, yanky_integration = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha beta" })
    vim.cmd("normal! 0ve")
    vim.fn.setreg('"', "")
    if t.plus_register_available() then
      vim.fn.setreg("+", "")
    end

    t.press("<C-x>")

    assert.are.same(" beta", vim.api.nvim_get_current_line())
    assert.are.same("alpha", vim.fn.getreg('"'))
    if t.plus_register_available() then
      assert.are.same("alpha", vim.fn.getreg("+"))
    end
  end)

  it("uses yanky-ready visual clipboard mappings without corrupting the selection", function()
    package.loaded["yanky"] = {}
    vim.keymap.set({ "x", "v" }, "<Plug>(YankyYank)", "y")
    vim.keymap.set("n", "<Plug>(YankyPutAfter)", "p")

    plugin.setup({ show_welcome = false, yanky_integration = true })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha beta" })
    vim.cmd("normal! 0ve")
    vim.fn.setreg('"', "")
    if t.plus_register_available() then
      vim.fn.setreg("+", "")
    end

    t.press("<C-c>")

    assert.are.same("alpha beta", vim.api.nvim_get_current_line())
    assert.are.same("alpha", vim.fn.getreg('"'))
    if t.plus_register_available() then
      assert.are.same("alpha", vim.fn.getreg("+"))
    end
  end)

  it("keeps cut synced to unnamed and system clipboard without yanky", function()
    plugin.setup({ show_welcome = false, yanky_integration = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha beta" })
    vim.cmd("normal! 0ve")
    vim.fn.setreg('"', "")
    if t.plus_register_available() then
      vim.fn.setreg("+", "")
    end

    t.press("<C-x>")

    assert.are.same(" beta", vim.api.nvim_get_current_line())
    assert.are.same("alpha", vim.fn.getreg('"'))
    if t.plus_register_available() then
      assert.are.same("alpha", vim.fn.getreg("+"))
    end
  end)

  it("keeps cut synced to unnamed and system clipboard with yanky-ready mappings", function()
    package.loaded["yanky"] = {}
    vim.keymap.set({ "x", "v" }, "<Plug>(YankyYank)", "y")
    vim.keymap.set("n", "<Plug>(YankyPutAfter)", "p")

    plugin.setup({ show_welcome = false, yanky_integration = true })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha beta" })
    vim.cmd("normal! 0ve")
    vim.fn.setreg('"', "")
    if t.plus_register_available() then
      vim.fn.setreg("+", "")
    end

    t.press("<C-x>")

    assert.are.same(" beta", vim.api.nvim_get_current_line())
    assert.are.same("alpha", vim.fn.getreg('"'))
    if t.plus_register_available() then
      assert.are.same("alpha", vim.fn.getreg("+"))
    end
  end)
end)
