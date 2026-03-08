local plugin = require("gui-keymap")
local utils = require("gui-keymap.utils")
local hints = require("gui-keymap.hints")

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
    local opts = plugin.setup()

    assert.are.same(true, opts.undo_redo)
    assert.are.same(true, opts.clipboard)
    assert.are.same(true, opts.select_all)
    assert.are.same(true, opts.delete_selection)
    assert.are.same(true, opts.shift_selection)
    assert.are.same(true, opts.yanky_integration)
    assert.are.same(true, opts.hint_enabled)
    assert.are.same(3, opts.hint_repeat)
  end)

  it("applies redo mapping", function()
    plugin.setup({ undo_redo = true })
    assert.is_true(map_present("n", "<C-y>"))
  end)

  it("respects disabled feature", function()
    plugin.setup({ undo_redo = false })
    assert.is_false(map_present("n", "<C-z>"))
    assert.is_false(map_present("n", "<C-y>"))
  end)

  it("records conflicts without overriding", function()
    vim.keymap.set("n", "<C-c>", "yy", { desc = "test conflict" })
    plugin.setup({ clipboard = true })

    local state = utils.get_state()
    assert.is_true(#state.conflicts > 0)
  end)

  it("supports unlimited hints when hint_repeat is -1", function()
    plugin.setup({ hint_enabled = true, hint_repeat = -1 })

    hints.show("copy")
    hints.show("copy")
    hints.show("copy")

    assert.are.same(3, hints.counts.copy)
  end)
end)
