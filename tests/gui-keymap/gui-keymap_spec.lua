local hints = require("gui-keymap.hints")
local plugin = require("gui-keymap")
local state = require("gui-keymap.state")
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
    assert.are.same(true, opts.clipboard.copy)
    assert.are.same(true, opts.clipboard.paste)
    assert.are.same(true, opts.clipboard.cut)
    assert.are.same(true, opts.select_all)
    assert.are.same(true, opts.delete_selection)
    assert.are.same(true, opts.shift_selection)
    assert.are.same(true, opts.word_delete)
    assert.are.same(true, opts.save)
    assert.are.same(true, opts.quit)
    assert.are.same(true, opts.home_end)
    assert.are.same(true, opts.yanky_integration)
    assert.are.same(true, opts.hint_enabled)
    assert.are.same(3, opts.hint_repeat)
    assert.are.same(true, opts.hint_persist)
    assert.are.same(true, opts.hint_features.save)
    assert.are.same(false, opts.hint_features.quit)
    assert.are.same(true, opts.enforce_on_startup)
    assert.are.same(true, opts.force_priority)
    assert.are.same(false, opts.show_welcome)
    assert.are.same(true, opts.preserve_mode)
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
    plugin.setup({ force_priority = true, show_welcome = false })

    local rhs = vim.fn.maparg("<C-c>", "n")
    local runtime = utils.get_state()
    assert.is_true(rhs ~= "")
    assert.are.same(0, #runtime.conflicts)
  end)

  it("can disable force priority", function()
    vim.keymap.set("n", "<C-c>", "yy", { desc = "test conflict" })
    plugin.setup({ force_priority = false, show_welcome = false })

    local runtime = utils.get_state()
    assert.is_true(#runtime.conflicts > 0)
    assert.is_true(#runtime.skipped_maps > 0)
  end)

  it("overrides user mappings by default", function()
    vim.keymap.set("n", "<C-c>", "yy", { desc = "user map" })
    plugin.setup({ show_welcome = false })

    local runtime = utils.get_state()
    assert.are.same(0, #runtime.conflicts)
  end)

  it("supports unlimited hints when hint_repeat is -1", function()
    plugin.setup({ hint_enabled = true, hint_repeat = -1, show_welcome = false })

    hints.show("copy")
    hints.show("copy")
    hints.show("copy")

    assert.is_true((state.hint_counts.copy or 0) > 0)
  end)

  it("preserves hint progress across refresh", function()
    plugin.setup({ hint_enabled = true, hint_repeat = 5, show_welcome = false })

    state.hint_last_ts.copy = 0
    hints.show("copy")
    local before = state.hint_counts.copy

    plugin.refresh()

    assert.are.same(before, state.hint_counts.copy)
  end)

  it("applies mappings when preserve_mode is enabled", function()
    plugin.setup({ preserve_mode = true, show_welcome = false })
    assert.is_true(map_present("n", "<C-a>"))
    assert.is_true(map_present("i", "<C-a>"))
  end)

  it("applies save, quit, and home/end mappings", function()
    plugin.setup({ show_welcome = false })

    assert.is_true(map_present("n", "<C-s>"))
    assert.is_true(map_present("i", "<C-s>"))
    assert.is_true(map_present("n", "<C-q>"))
    assert.is_true(map_present("i", "<C-q>"))
    assert.is_true(map_present("n", "<Home>"))
    assert.is_true(map_present("n", "<End>"))
    assert.is_true(map_present("i", "<Home>"))
    assert.is_true(map_present("i", "<End>"))
  end)

  it("keeps default clipboard toggles when config is partial", function()
    local opts = plugin.setup({
      clipboard = { copy = false },
      show_welcome = false,
    })

    assert.are.same(false, opts.clipboard.copy)
    assert.are.same(true, opts.clipboard.paste)
    assert.are.same(true, opts.clipboard.cut)
  end)

  it("sanitizes invalid config types back to defaults", function()
    local opts = plugin.setup({
      hint_repeat = "bad",
      force_priority = "bad",
      hint_persist = "bad",
      save = "bad",
      clipboard = {
        copy = "bad",
        paste = true,
      },
      hint_features = {
        save = "bad",
      },
      show_welcome = false,
    })

    assert.are.same(3, opts.hint_repeat)
    assert.are.same(true, opts.force_priority)
    assert.are.same(true, opts.hint_persist)
    assert.are.same(true, opts.save)
    assert.are.same(true, opts.hint_features.save)
    assert.are.same(true, opts.clipboard.copy)
    assert.are.same(true, opts.clipboard.paste)
    assert.are.same(true, opts.clipboard.cut)
  end)

  it("works when yanky and which-key are absent", function()
    local original_yanky = package.loaded["yanky"]
    local original_which_key = package.loaded["which-key"]
    package.loaded["yanky"] = nil
    package.loaded["which-key"] = nil

    plugin.setup({ show_welcome = false })

    local runtime = state
    assert.are.same(false, runtime.yanky_loaded)
    assert.are.same(false, runtime.which_key_available)

    package.loaded["yanky"] = original_yanky
    package.loaded["which-key"] = original_which_key
  end)

  it("registers end-user commands from plugin loader", function()
    vim.cmd("runtime plugin/gui-keymap.lua")

    assert.are.same(2, vim.fn.exists(":GuiKeymapDemo"))
    assert.are.same(2, vim.fn.exists(":GuiKeymapEnable"))
    assert.are.same(2, vim.fn.exists(":GuiKeymapDisable"))
    assert.are.same(2, vim.fn.exists(":GuiKeymapList"))
    assert.are.same(2, vim.fn.exists(":GuiKeymapExplain"))
  end)

  it("provides generated explain keys", function()
    plugin.setup({ show_welcome = false })

    local keys = require("gui-keymap.keymaps").explain_keys()
    assert.is_true(vim.tbl_contains(keys, "<C-c>"))
    assert.is_true(vim.tbl_contains(keys, "<C-Del>"))
  end)

  it("tracks requested mappings", function()
    plugin.setup({ show_welcome = false })

    assert.is_true(#state.requested_maps >= #state.active_maps)
  end)

  it("loads persisted hint counts when enabled", function()
    local hint_file = vim.fn.stdpath("state") .. "/gui-keymap-hints.json"
    vim.fn.mkdir(vim.fn.fnamemodify(hint_file, ":h"), "p")
    vim.fn.writefile({ vim.json.encode({ counts = { save = 4 } }) }, hint_file)

    plugin.setup({ show_welcome = false, hint_persist = true })

    assert.are.same(4, state.hint_counts.save)

    vim.fn.delete(hint_file)
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
    assert.is_true(vim.tbl_contains(lines, "Ctrl+S  -> Save"))
    assert.is_true(vim.tbl_contains(lines, "Ctrl+Q  -> Close window or buffer"))
    assert.is_true(vim.tbl_contains(lines, "Ctrl+Backspace -> Delete previous word"))
    assert.is_true(vim.tbl_contains(lines, "Ctrl+Delete -> Delete next word"))
  end)
end)

describe("gui-keymap info surfaces", function()
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
