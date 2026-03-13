local hints = require("gui-keymap.hints")
local plugin = require("gui-keymap")
local state = require("gui-keymap.state")
local clipboard = require("gui-keymap.clipboard")
local utils = require("gui-keymap.utils")

local function map_present(mode, lhs)
  local mapping = vim.fn.maparg(lhs, mode, false, true)
  return type(mapping) == "table" and next(mapping) ~= nil
end

local function invoke_map(mode, lhs)
  local mapping = vim.fn.maparg(lhs, mode, false, true)
  assert.is_truthy(mapping.callback)
  mapping.callback()
end

local function invoke_map_with_result(mode, lhs)
  local mapping = vim.fn.maparg(lhs, mode, false, true)
  assert.is_truthy(mapping.callback)
  return mapping.callback()
end

local function termcodes(keys)
  return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

local function press(keys, mode)
  vim.api.nvim_feedkeys(termcodes(keys), mode or "mx", false)
end

local function execute_map(mode, lhs)
  local result = invoke_map_with_result(mode, lhs)
  if type(result) == "string" and result ~= "" then
    press(result, mode == "i" and "i" or "mx")
    vim.cmd("redraw")
  end
end

local function plus_register_available()
  local probe = "gui-keymap-test-probe"
  local old_value = vim.fn.getreg("+")
  local old_type = vim.fn.getregtype("+")
  local ok = pcall(vim.fn.setreg, "+", probe, "v")
  local available = ok and vim.fn.getreg("+") == probe
  pcall(vim.fn.setreg, "+", old_value, old_type)
  return available
end

local function seed_clipboard_registers(value, regtype)
  vim.fn.setreg('"', value, regtype or "v")
  if plus_register_available() then
    vim.fn.setreg("+", value, regtype or "v")
  end
end

describe("gui-keymap setup", function()
  before_each(function()
    utils.clear_plugin_maps()
    hints.reset()
    if plugin._enforce_group then
      pcall(vim.api.nvim_del_augroup_by_id, plugin._enforce_group)
    end
    plugin._enforce_group = nil
    plugin._apply_scheduled = false
    package.loaded["yanky"] = nil
    package.loaded["lazy"] = nil
    package.loaded["lazy.core.config"] = nil
    pcall(vim.keymap.del, "n", "<Plug>(YankyPutAfter)")
    pcall(vim.keymap.del, "n", "<Plug>(YankyYank)")
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
    assert.is_true(map_present("i", "<C-h>"))
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
    assert.is_true(map_present("v", "<C-a>"))
    assert.is_true(map_present("v", "<C-x>"))
    assert.is_true(map_present("v", "<C-c>"))
    assert.is_true(map_present("v", "<BS>"))
    assert.is_true(map_present("v", "<Del>"))
    assert.is_true(map_present("i", "<Home>"))
    assert.is_true(map_present("i", "<End>"))
  end)

  it("selects all in normal mode via Ctrl+A", function()
    plugin.setup({ show_welcome = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "two", "three" })
    vim.api.nvim_win_set_cursor(0, { 2, 1 })

    press("<C-a>")

    assert.are.same("V", vim.api.nvim_get_mode().mode)
    assert.are.same(3, vim.api.nvim_win_get_cursor(0)[1])
  end)

  it("re-selects all when Ctrl+A is pressed from visual mode", function()
    plugin.setup({ show_welcome = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "two", "three" })
    vim.cmd("normal! ggVj")

    invoke_map("v", "<C-a>")

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
    seed_clipboard_registers(" beta", "v")

    invoke_map("n", "<C-v>")

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
    seed_clipboard_registers(" beta", "v")
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

    assert.is_true(map_present("n", "<C-a>"))
    assert.is_true(map_present("n", "<C-v>"))
  end)

  it("maps Ctrl+Z immediately when the plugin loader runs", function()
    local commands = require("gui-keymap.commands")
    local gui_keymap = require("gui-keymap")

    utils.clear_plugin_maps()
    gui_keymap._setup_done = false
    commands._registered = false
    vim.g.loaded_gui_keymap = nil

    vim.cmd("runtime plugin/gui-keymap.lua")

    assert.is_true(map_present("n", "<C-z>"))
    assert.is_true(map_present("i", "<C-z>"))
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
    local hint_file = vim.fn.stdpath("state") .. "/gui-keymap-hints.json"
    vim.fn.mkdir(vim.fn.fnamemodify(hint_file, ":h"), "p")
    vim.fn.writefile({ vim.json.encode({ counts = { save = 4 } }) }, hint_file)

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
    assert.is_true(vim.tbl_contains(lines, "Ctrl+Q  -> Save and quit current file"))
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

describe("gui-keymap keycode mappings", function()
  before_each(function()
    utils.clear_plugin_maps()
    hints.reset()
  end)

  it("does not inject literal keycode text for normal-mode shift selection mappings", function()
    plugin.setup({ show_welcome = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "two" })
    vim.api.nvim_win_set_cursor(0, { 1, 1 })

    press("<S-Down>")

    assert.are.same({ "one", "two" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
  end)

  it("does not inject literal text for insert-mode shift selection mappings", function()
    plugin.setup({ show_welcome = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "two" })
    vim.api.nvim_win_set_cursor(0, { 1, 1 })
    vim.cmd("startinsert")

    press("<S-Down>")

    assert.are.same({ "one", "two" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    assert.is_true(vim.api.nvim_get_mode().mode == "v" or vim.api.nvim_get_mode().mode == "V")
  end)

  it("does not inject literal text for insert-mode delete previous word", function()
    plugin.setup({ show_welcome = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
    vim.api.nvim_win_set_cursor(0, { 1, 11 })
    vim.cmd("startinsert")

    press("<C-BS>")

    assert.are.same("hello ", vim.api.nvim_get_current_line())
  end)

  it("supports Ctrl+H as an insert-mode fallback for previous-word delete", function()
    plugin.setup({ show_welcome = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
    vim.api.nvim_win_set_cursor(0, { 1, 11 })
    vim.cmd("startinsert")

    execute_map("i", "<C-h>")

    assert.are.same("hello ", vim.api.nvim_get_current_line())
  end)

  it("deletes the next word without polluting unnamed or system clipboard in normal mode", function()
    plugin.setup({ show_welcome = false, yanky_integration = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello cruel world" })
    vim.api.nvim_win_set_cursor(0, { 1, 6 })
    seed_clipboard_registers("keep", "v")

    execute_map("n", "<C-Del>")

    assert.are.same("hello world", vim.api.nvim_get_current_line())
    assert.are.same("keep", vim.fn.getreg('"'))
    if plus_register_available() then
      assert.are.same("keep", vim.fn.getreg("+"))
    end
  end)

  it("deletes the next word without polluting unnamed or system clipboard in insert mode", function()
    plugin.setup({ show_welcome = false, yanky_integration = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello cruel world" })
    vim.api.nvim_win_set_cursor(0, { 1, 6 })
    seed_clipboard_registers("keep", "v")
    vim.cmd("startinsert")

    execute_map("i", "<C-Del>")

    assert.are.same("hello world", vim.api.nvim_get_current_line())
    assert.are.same("keep", vim.fn.getreg('"'))
    if plus_register_available() then
      assert.are.same("keep", vim.fn.getreg("+"))
    end
  end)

  it("copies the selected text from visual mode without corrupting the buffer", function()
    plugin.setup({ show_welcome = false, yanky_integration = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha beta" })
    vim.cmd("normal! 0ve")
    vim.fn.setreg('"', "")
    if plus_register_available() then
      vim.fn.setreg("+", "")
    end

    execute_map("v", "<C-c>")

    assert.are.same("alpha beta", vim.api.nvim_get_current_line())
    assert.are.same("alpha", vim.fn.getreg('"'))
    if plus_register_available() then
      assert.are.same("alpha", vim.fn.getreg("+"))
    end
  end)

  it("cuts only the selected text from visual mode without inserting literal text", function()
    plugin.setup({ show_welcome = false, yanky_integration = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha beta" })
    vim.cmd("normal! 0ve")
    vim.fn.setreg('"', "")
    if plus_register_available() then
      vim.fn.setreg("+", "")
    end

    press("<C-x>")

    assert.are.same(" beta", vim.api.nvim_get_current_line())
    assert.are.same("alpha", vim.fn.getreg('"'))
    if plus_register_available() then
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
    if plus_register_available() then
      vim.fn.setreg("+", "")
    end

    press("<C-c>")

    assert.are.same("alpha beta", vim.api.nvim_get_current_line())
    assert.are.same("alpha", vim.fn.getreg('"'))
    if plus_register_available() then
      assert.are.same("alpha", vim.fn.getreg("+"))
    end
  end)

  it("keeps cut synced to unnamed and system clipboard without yanky", function()
    plugin.setup({ show_welcome = false, yanky_integration = false })
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha beta" })
    vim.cmd("normal! 0ve")
    vim.fn.setreg('"', "")
    if plus_register_available() then
      vim.fn.setreg("+", "")
    end

    press("<C-x>")

    assert.are.same(" beta", vim.api.nvim_get_current_line())
    assert.are.same("alpha", vim.fn.getreg('"'))
    if plus_register_available() then
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
    if plus_register_available() then
      vim.fn.setreg("+", "")
    end

    press("<C-x>")

    assert.are.same(" beta", vim.api.nvim_get_current_line())
    assert.are.same("alpha", vim.fn.getreg('"'))
    if plus_register_available() then
      assert.are.same("alpha", vim.fn.getreg("+"))
    end
  end)
end)

describe("gui-keymap hints", function()
  local original_notify

  before_each(function()
    original_notify = vim.notify
    utils.clear_plugin_maps()
    hints.reset()
    state.hint_counts = {}
    state.hint_last_ts = {}
    plugin.setup({
      show_welcome = false,
      hint_enabled = true,
      hint_repeat = -1,
      hint_persist = false,
      yanky_integration = false,
    })
  end)

  after_each(function()
    vim.notify = original_notify
  end)

  local function with_notify_capture(fn)
    local messages = {}
    vim.notify = function(msg, level, opts)
      table.insert(messages, {
        msg = msg,
        level = level,
        title = opts and opts.title or nil,
      })
    end

    fn(messages)
    vim.wait(50, function()
      return #messages > 0
    end)
    return messages
  end

  local function prepare_for_mapping(mode, lhs)
    vim.cmd("enew!")
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.swapfile = false
    vim.bo.modified = false

    if lhs == "<C-c>" and mode == "v" then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha beta" })
      vim.cmd("normal! 0ve")
      return
    end

    if lhs == "<C-x>" and mode == "v" then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha beta" })
      vim.cmd("normal! 0ve")
      return
    end

    if lhs == "<C-v>" and mode == "n" then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha" })
      vim.api.nvim_win_set_cursor(0, { 1, 5 })
      seed_clipboard_registers(" beta", "v")
      return
    end

    if lhs == "<C-v>" and mode == "i" then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha" })
      vim.api.nvim_win_set_cursor(0, { 1, 5 })
      seed_clipboard_registers(" beta", "v")
      return
    end

    if lhs == "<C-BS>" then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
      vim.api.nvim_win_set_cursor(0, { 1, 11 })
      return
    end

    if lhs == "<C-Del>" then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello cruel world" })
      vim.api.nvim_win_set_cursor(0, { 1, 6 })
      return
    end

    if lhs == "<C-a>" and mode == "v" then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "two" })
      vim.cmd("normal! v")
      return
    end

    if lhs == "<C-s>" and mode == "v" then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one" })
      vim.cmd("normal! v")
      return
    end

    if lhs == "<Home>" and mode == "v" then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "abc" })
      vim.cmd("normal! lv")
      return
    end

    if lhs == "<End>" and mode == "v" then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "abc" })
      vim.cmd("normal! v")
      return
    end

    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "two" })
  end

  for _, item in ipairs(require("gui-keymap.keymaps").registry) do
    if item.hint_key then
      local label = string.format(
        "%s %s emits a hint",
        type(item.mode) == "table" and table.concat(item.mode, ",") or item.mode,
        item.lhs
      )
      it(label, function()
        prepare_for_mapping(item.mode, item.lhs)

        local messages = with_notify_capture(function()
          local result = invoke_map_with_result(item.mode, item.lhs)
          if type(result) == "string" and result ~= "" then
            assert.is_true(#result > 0)
          end
        end)

        assert.is_true(#messages > 0)
        assert.are.same("gui-keymap", messages[1].title)
        assert.is_true(type(messages[1].msg) == "string" and messages[1].msg ~= "")
      end)
    end
  end
end)
