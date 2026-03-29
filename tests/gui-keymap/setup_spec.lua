local plugin = require("gui-keymap")
local state = require("gui-keymap.state")
local clipboard = require("gui-keymap.clipboard")
local utils = require("gui-keymap.utils")
local t = require("tests.gui-keymap.helpers")

describe("gui-keymap setup", function()
  before_each(function()
    t.reset_runtime()
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
    assert.are.same(true, opts.enforce_on_startup)
    assert.are.same(true, opts.force_priority)
    assert.are.same(false, opts.show_welcome)
    assert.are.same(true, opts.preserve_mode)
  end)

  it("applies redo mapping", function()
    plugin.setup({ undo_redo = true, show_welcome = false })
    assert.is_true(t.map_present("n", "<C-y>"))
  end)

  it("respects disabled feature", function()
    plugin.setup({ undo_redo = false, show_welcome = false })
    assert.is_false(t.map_present("n", "<C-z>"))
    assert.is_false(t.map_present("n", "<C-y>"))
  end)

  it("applies word delete mappings", function()
    plugin.setup({ word_delete = true, show_welcome = false })

    assert.is_true(t.map_present("n", "<C-BS>"))
    assert.is_true(t.map_present("n", "<C-Del>"))
    assert.is_true(t.map_present("i", "<C-BS>"))
    assert.is_true(t.map_present("i", "<C-Del>"))
    assert.is_true(t.map_present("i", "<C-h>"))
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

    require("gui-keymap.hints").show("copy")
    require("gui-keymap.hints").show("copy")
    require("gui-keymap.hints").show("copy")

    assert.is_true((state.hint_counts.copy or 0) > 0)
  end)

  it("preserves hint progress across refresh", function()
    plugin.setup({ hint_enabled = true, hint_repeat = 5, show_welcome = false })

    state.hint_last_ts.copy = 0
    require("gui-keymap.hints").show("copy")
    local before = state.hint_counts.copy

    plugin.refresh()

    assert.are.same(before, state.hint_counts.copy)
  end)

  it("applies mappings when preserve_mode is enabled", function()
    plugin.setup({ preserve_mode = true, show_welcome = false })
    assert.is_true(t.map_present("n", "<C-a>"))
    assert.is_true(t.map_present("i", "<C-a>"))
  end)

  it("applies save, quit, and home/end mappings", function()
    plugin.setup({ show_welcome = false })

    assert.is_true(t.map_present("n", "<C-s>"))
    assert.is_true(t.map_present("i", "<C-s>"))
    assert.is_true(t.map_present("n", "<C-q>"))
    assert.is_true(t.map_present("i", "<C-q>"))
    assert.is_true(t.map_present("n", "<Home>"))
    assert.is_true(t.map_present("n", "<End>"))
    assert.is_true(t.map_present("v", "<C-a>"))
    assert.is_true(t.map_present("v", "<C-x>"))
    assert.is_true(t.map_present("v", "<C-c>"))
    assert.is_true(t.map_present("v", "<BS>"))
    assert.is_true(t.map_present("v", "<Del>"))
    assert.is_true(t.map_present("i", "<Home>"))
    assert.is_true(t.map_present("i", "<End>"))
  end)

  it("selects all in normal mode via Ctrl+A", function()
    plugin.setup({ show_welcome = false })
    vim.cmd("enew!")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "two", "three" })
    vim.api.nvim_win_set_cursor(0, { 2, 1 })

    t.press("<C-a>")

    assert.are.same("V", vim.api.nvim_get_mode().mode)
    assert.are.same(3, vim.api.nvim_win_get_cursor(0)[1])
  end)

  it("re-selects all when Ctrl+A is pressed from visual mode", function()
    plugin.setup({ show_welcome = false })
    vim.cmd("enew!")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "two", "three" })
    vim.cmd("normal! ggVj")

    t.invoke_map("v", "<C-a>")

    assert.are.same("V", vim.api.nvim_get_mode().mode)
    assert.are.same(3, vim.api.nvim_win_get_cursor(0)[1])
  end)

  it("falls back to built-in clipboard paste when yanky is not ready", function()
    plugin.setup({ show_welcome = false, yanky_integration = true })
    package.loaded["yanky"] = {}
    state.yanky_checked = false

    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha" })
    vim.api.nvim_win_set_cursor(0, { 1, 5 })
    t.seed_clipboard_registers(" beta", "v")

    t.invoke_map("n", "<C-v>")

    assert.are.same("alpha beta", vim.api.nvim_get_current_line())
    package.loaded["yanky"] = nil
  end)

  it("clipboard module pastes without yanky plug mappings", function()
    plugin.setup({ show_welcome = false, yanky_integration = true })
    package.loaded["yanky"] = {}
    state.yanky_checked = false

    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha" })
    vim.api.nvim_win_set_cursor(0, { 1, 5 })
    t.seed_clipboard_registers(" beta", "v")
    clipboard.paste_normal()

    assert.are.same("alpha beta", vim.api.nvim_get_current_line())
    package.loaded["yanky"] = nil
  end)

  it("tracks yanky as installed but not ready when lazy registry knows it", function()
    package.loaded["lazy.core.config"] = {
      plugins = {
        yanky = { name = "yanky.nvim", url = "https://github.com/gbprod/yanky.nvim" },
      },
    }
    package.loaded["lazy"] = {
      load = function()
        package.loaded["yanky"] = {}
        return true
      end,
    }

    plugin.setup({ show_welcome = false, yanky_integration = true })
    clipboard.detect_status(true)

    assert.are.same(true, state.yanky_available)
    assert.are.same("installed-not-loaded", state.yanky_status)

    clipboard.ensure_yanky_loaded()

    assert.are.same("loaded-not-ready", state.yanky_status)
    assert.is_true(state.yanky_source ~= "")
  end)

  it("uses yanky once lazy load makes plug mappings available", function()
    package.loaded["lazy.core.config"] = {
      plugins = {
        yanky = { name = "yanky.nvim", url = "https://github.com/gbprod/yanky.nvim" },
      },
    }
    package.loaded["lazy"] = {
      load = function()
        package.loaded["yanky"] = {}
        vim.keymap.set("n", "<Plug>(YankyPutAfter)", "p")
        vim.keymap.set("n", "<Plug>(YankyYank)", "y")
        return true
      end,
    }

    plugin.setup({ show_welcome = false, yanky_integration = true })

    assert.is_true(clipboard.ensure_yanky_loaded())
    assert.are.same("ready", state.yanky_status)
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
      show_welcome = false,
    })

    assert.are.same(3, opts.hint_repeat)
    assert.are.same(true, opts.force_priority)
    assert.are.same(true, opts.hint_persist)
    assert.are.same(true, opts.save)
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

  it("auto-applies default setup from plugin loader", function()
    local commands = require("gui-keymap.commands")
    local gui_keymap = require("gui-keymap")

    utils.clear_plugin_maps()
    gui_keymap._setup_done = false
    commands._registered = false
    vim.g.loaded_gui_keymap = nil

    vim.cmd("runtime plugin/gui-keymap.lua")
    vim.wait(50, function()
      return require("gui-keymap")._setup_done
    end)

    assert.is_true(t.map_present("n", "<C-a>"))
    assert.is_true(t.map_present("n", "<C-v>"))
  end)

  it("maps Ctrl+Z immediately when the plugin loader runs", function()
    local commands = require("gui-keymap.commands")
    local gui_keymap = require("gui-keymap")

    utils.clear_plugin_maps()
    gui_keymap._setup_done = false
    commands._registered = false
    vim.g.loaded_gui_keymap = nil

    vim.cmd("runtime plugin/gui-keymap.lua")

    assert.is_true(t.map_present("n", "<C-z>"))
    assert.is_true(t.map_present("i", "<C-z>"))
  end)

  it("provides generated explain keys", function()
    plugin.setup({ show_welcome = false })

    local keys = require("gui-keymap.keymaps").explain_keys()
    assert.is_true(vim.tbl_contains(keys, "<C-c>"))
    assert.is_true(vim.tbl_contains(keys, "<C-Del>"))
  end)

  it("has a registry without duplicate key assignments or missing descriptions", function()
    local issues = require("gui-keymap.keymaps").audit_registry()
    assert.are.same({}, issues)
  end)

  it("tracks requested mappings", function()
    plugin.setup({ show_welcome = false })
    assert.is_true(#state.requested_maps >= #state.active_maps)
  end)

  it("loads persisted hint counts when enabled", function()
    local hint_file = require("gui-keymap.utils").path_join(vim.fn.stdpath("state"), "gui-keymap-hints.json")
    vim.fn.delete(hint_file)
    vim.fn.mkdir(vim.fn.fnamemodify(hint_file, ":h"), "p")
    vim.fn.writefile({ vim.json.encode({ counts = { save = 4 } }) }, hint_file)
    state.hint_counts = {}
    state.hint_last_ts = {}

    assert.are.same(1, vim.fn.filereadable(hint_file))

    plugin.setup({ show_welcome = false, hint_persist = true })

    assert.are.same(4, state.hint_counts.save)

    vim.fn.delete(hint_file)
  end)

  it("creates a single enforcement augroup and keeps startup scheduling bounded", function()
    plugin.setup({ show_welcome = false, enforce_on_startup = true })
    local first_group = plugin._enforce_group

    plugin.setup_enforcement_autocmds()

    assert.are.same(first_group, plugin._enforce_group)
    assert.is_not_nil(first_group)
  end)

  it("tracks yanky integration state through state helpers", function()
    state.reset_yanky_probe()
    state.set_yanky_status(true, false, true, "installed-not-loaded", "lazy-registry")

    assert.are.same(true, state.yanky_available)
    assert.are.same(false, state.yanky_loaded)
    assert.are.same(true, state.yanky_enabled)
    assert.are.same("installed-not-loaded", state.yanky_status)
    assert.are.same("lazy-registry", state.yanky_source)
    assert.are.same(true, state.yanky_checked)

    state.reset_yanky_probe()

    assert.are.same(false, state.yanky_checked)
    assert.are.same(false, state.yanky_probe_attempted)
  end)
end)
