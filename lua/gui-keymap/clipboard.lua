local utils = require("gui-keymap.utils")

local M = {}

local function termcodes(keys)
  return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

local function feed(keys)
  vim.api.nvim_feedkeys(termcodes(keys), "m", false)
end

local function run_normal(keys)
  vim.cmd.normal({ args = { keys }, bang = true })
end

local function yanky_runtime_installed()
  local state = utils.get_state()
  if state.yanky_checked then
    return state.yanky_available
  end

  return #vim.api.nvim_get_runtime_file("lua/yanky.lua", false) > 0
    or #vim.api.nvim_get_runtime_file("lua/yanky/init.lua", false) > 0
end

local function yanky_mapping_ready(lhs, mode)
  return vim.fn.maparg(lhs, mode) ~= ""
end

function M.ensure_yanky_loaded()
  local state = utils.get_state()
  local enabled = state.config.yanky_integration == true

  if package.loaded["yanky"] ~= nil and yanky_mapping_ready("<Plug>(YankyPutAfter)", "n") then
    utils.set_yanky_status(true, true, enabled)
    state.yanky_checked = true
    return true
  end

  if not yanky_runtime_installed() then
    utils.set_yanky_status(false, false, enabled)
    state.yanky_checked = true
    return false
  end

  utils.set_yanky_status(true, false, enabled)
  state.yanky_checked = true
  return false
end

local function sync_unnamed_from_plus()
  local plus = vim.fn.getreg("+")
  if plus == "" then
    return
  end
  vim.fn.setreg('"', plus, vim.fn.getregtype("+"))
end

local function sync_plus_from_unnamed()
  local unnamed = vim.fn.getreg('"')
  if unnamed == "" then
    return
  end
  local regtype = vim.fn.getregtype('"')
  vim.fn.setreg("+", unnamed, regtype)
  vim.fn.setreg("*", unnamed, regtype)
end

function M.copy_selection()
  if M.ensure_yanky_loaded() then
    feed("<Plug>(YankyYank)")
    sync_plus_from_unnamed()
    return
  end
  run_normal('"+y')
  sync_unnamed_from_plus()
end

function M.copy_line()
  if M.ensure_yanky_loaded() then
    run_normal("yy")
    sync_plus_from_unnamed()
    return
  end
  run_normal('"+yy')
  sync_unnamed_from_plus()
end

function M.cut_selection()
  if M.ensure_yanky_loaded() then
    feed("<Plug>(YankyYank)")
    run_normal([[gv"_d]])
    sync_plus_from_unnamed()
    return
  end
  run_normal('"+d')
  sync_unnamed_from_plus()
end

function M.paste_normal()
  if M.ensure_yanky_loaded() then
    feed("<Plug>(YankyPutAfter)")
    return
  end
  if vim.fn.getreg("+") ~= "" then
    run_normal('"+p')
    return
  end
  run_normal("p")
end

function M.paste_insert()
  if M.ensure_yanky_loaded() then
    feed("<Esc><Plug>(YankyPutAfter)a")
    return
  end
  local clip = vim.fn.getreg("+")
  if clip == "" then
    clip = vim.fn.getreg('"')
  end
  if clip == "" then
    return
  end
  vim.api.nvim_paste(clip, true, -1)
end

function M.delete_selection_blackhole()
  local plus, plus_type = vim.fn.getreg("+"), vim.fn.getregtype("+")
  local star, star_type = vim.fn.getreg("*"), vim.fn.getregtype("*")
  run_normal('"_d')
  vim.fn.setreg("+", plus, plus_type)
  vim.fn.setreg("*", star, star_type)
end

function M.detect_status(enabled)
  local loaded_yanky = package.loaded["yanky"] ~= nil
  local has_yanky = loaded_yanky or yanky_runtime_installed()
  local state = utils.get_state()

  utils.set_yanky_status(has_yanky, loaded_yanky, enabled == true)
  state.yanky_checked = true
end

return M
