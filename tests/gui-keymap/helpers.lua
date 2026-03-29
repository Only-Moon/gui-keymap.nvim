local M = {}

local hints = require("gui-keymap.hints")
local plugin = require("gui-keymap")
local utils = require("gui-keymap.utils")

function M.map_present(mode, lhs)
  local mapping = vim.fn.maparg(lhs, mode, false, true)
  return type(mapping) == "table" and next(mapping) ~= nil
end

function M.invoke_map(mode, lhs)
  local mapping = vim.fn.maparg(lhs, mode, false, true)
  assert(mapping.callback ~= nil)
  mapping.callback()
end

function M.invoke_map_with_result(mode, lhs)
  local mapping = vim.fn.maparg(lhs, mode, false, true)
  assert(mapping.callback ~= nil)
  return mapping.callback()
end

function M.termcodes(keys)
  return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

function M.press(keys, mode)
  vim.api.nvim_feedkeys(M.termcodes(keys), mode or "mx", false)
end

function M.execute_map(mode, lhs)
  local result = M.invoke_map_with_result(mode, lhs)
  if type(result) == "string" and result ~= "" then
    M.press(result, mode == "i" and "i" or "mx")
    vim.cmd("redraw")
  end
end

function M.plus_register_available()
  local probe = "gui-keymap-test-probe"
  local old_value = vim.fn.getreg("+")
  local old_type = vim.fn.getregtype("+")
  local ok = pcall(vim.fn.setreg, "+", probe, "v")
  local available = ok and vim.fn.getreg("+") == probe
  pcall(vim.fn.setreg, "+", old_value, old_type)
  return available
end

function M.seed_clipboard_registers(value, regtype)
  vim.fn.setreg('"', value, regtype or "v")
  if M.plus_register_available() then
    vim.fn.setreg("+", value, regtype or "v")
  end
end

function M.reset_runtime()
  utils.clear_plugin_maps()
  local state = require("gui-keymap.state")
  state.hint_counts = {}
  state.hint_last_ts = {}
  hints.enabled = false
  hints.persist = false
  hints.max_repeat = 3
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
end

function M.prepare_for_mapping(mode, lhs)
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

  if lhs == "<C-v>" and (mode == "n" or mode == "i") then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha" })
    vim.api.nvim_win_set_cursor(0, { 1, 5 })
    M.seed_clipboard_registers(" beta", "v")
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

return M
