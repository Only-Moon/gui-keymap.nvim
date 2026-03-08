local hints = require("gui-keymap.hints")
local plugin = require("gui-keymap")
local utils = require("gui-keymap.utils")

local function map_present(mode, lhs)
  local mapping = vim.fn.maparg(lhs, mode, false, true)
  return type(mapping) == "table" and next(mapping) ~= nil
end

describe("gui-keymap setup", function()
  before_each(function()
    utils.clear_plugin_maps()
    hints.reset()
  end)

  it("merges defaults", function()
    local opts = plugin.setup({ show_welcome = false })

    assert.are.same(true, opts.undo_redo)
    assert.are.same(true, opts.clipboard)
    assert.are.same(true, opts.select_all)
    assert.are.same(true, opts.delete_selection)
    assert.are.same(true, opts.shift_selection)
    assert.are.same(true, opts.word_delete)
    assert.are.same(true, opts.yanky_integration)
    assert.are.same(true, opts.hint_enabled)
    assert.are.same(3, opts.hint_repeat)
    assert.are.same(true, opts.enforce_on_startup)
    assert.are.same(false, opts.force_priority)
    assert.are.same(false, opts.preserve_mode)
  end)

  it("applies redo mapping", function()
    plugin.setup({ undo_redo = true, show_welcome = false })
    assert.is_true(map_present("n", "<C-y>"))
  end)

  it("respects disabled feature", function()
    plugin.setup({ undo_redo = false, show_welcome = false })
    assert.is_false(map_present("n", "<C-z>"))
    assert.is_false(map_present("n", "<C-y>"))
  end)

  it("applies word delete mappings", function()
    plugin.setup({ word_delete = true, show_welcome = false })

    assert.is_true(map_present("n", "<C-BS>"))
    assert.is_true(map_present("n", "<C-Del>"))
    assert.is_true(map_present("i", "<C-BS>"))
    assert.is_true(map_present("i", "<C-Del>"))
  end)

  it("force-overrides configured keys", function()
    vim.keymap.set("n", "<C-c>", "yy", { desc = "test conflict" })
    plugin.setup({ clipboard = true, force_priority = true, show_welcome = false })

    local rhs = vim.fn.maparg("<C-c>", "n")
    local state = utils.get_state()
    assert.is_true(rhs ~= "")
    assert.are.same(0, #state.conflicts)
  end)

  it("can disable force priority", function()
    vim.keymap.set("n", "<C-c>", "yy", { desc = "test conflict" })
    plugin.setup({ clipboard = true, force_priority = false, show_welcome = false })

    local state = utils.get_state()
    assert.is_true(#state.conflicts > 0)
  end)

  it("does not override user mappings by default", function()
    vim.keymap.set("n", "<C-c>", "yy", { desc = "user map" })
    plugin.setup({ clipboard = true, show_welcome = false })

    local state = utils.get_state()
    assert.is_true(#state.conflicts > 0)
  end)

  it("supports unlimited hints when hint_repeat is -1", function()
    plugin.setup({ hint_enabled = true, hint_repeat = -1, show_welcome = false })

    hints.show("copy")
    hints.show("copy")
    hints.show("copy")

    assert.are.same(3, hints.counts.copy)
  end)

  it("applies mappings when preserve_mode is enabled", function()
    plugin.setup({ preserve_mode = true, show_welcome = false })
    assert.is_true(map_present("n", "<C-a>"))
    assert.is_true(map_present("i", "<C-a>"))
  end)
end)

describe("gui-keymap demo", function()
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
    assert.is_true(vim.tbl_contains(lines, "Ctrl+Backspace -> Delete previous word"))
    assert.is_true(vim.tbl_contains(lines, "Ctrl+Delete -> Delete next word"))
  end)

  it("opens showcase scratch demo buffer", function()
    require("gui-keymap.demo").showcase()

    local buf = vim.api.nvim_get_current_buf()
    assert.are.same("nofile", vim.bo[buf].buftype)
    assert.are.same("gui-keymap-demo", vim.bo[buf].filetype)

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    assert.is_true(vim.tbl_contains(lines, "Interactive showcase: try keys and compare with :GuiKeymapInfo."))
  end)
end)
