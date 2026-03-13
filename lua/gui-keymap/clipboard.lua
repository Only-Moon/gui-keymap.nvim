local utils = require("gui-keymap.utils")

local M = {}

local function termcodes(keys)
  return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

local function feed(keys)
  vim.api.nvim_feedkeys(termcodes(keys), "mx", false)
end

local function feed_visual(keys)
  vim.api.nvim_feedkeys(termcodes(keys), "mx", false)
end

local function run_normal(keys)
  vim.cmd.normal({ args = { keys }, bang = true })
end

local function yanky_mapping_ready(lhs, mode)
  return vim.fn.maparg(lhs, mode) ~= ""
end

local function yanky_ready()
  return package.loaded["yanky"] ~= nil and yanky_mapping_ready("<Plug>(YankyPutAfter)", "n")
end

local function yanky_runtime_installed()
  return #vim.api.nvim_get_runtime_file("lua/yanky.lua", false) > 0
    or #vim.api.nvim_get_runtime_file("lua/yanky/init.lua", false) > 0
    or #vim.api.nvim_get_runtime_file("plugin/yanky.lua", false) > 0
end

local function lazy_yanky_plugin()
  local ok, config = pcall(require, "lazy.core.config")
  if not ok or type(config.plugins) ~= "table" then
    return nil
  end

  for name, plugin in pairs(config.plugins) do
    local haystack = table
      .concat({
        tostring(name or ""),
        tostring(plugin.name or ""),
        tostring(plugin.url or ""),
        tostring(plugin.dir or ""),
        tostring(plugin.main or ""),
      }, " ")
      :lower()

    if haystack:find("yanky.nvim", 1, true) or haystack:find("gbprod/yanky", 1, true) then
      return plugin
    end
  end

  return nil
end

local function detect_yanky_installation()
  if package.loaded["yanky"] ~= nil then
    return true, true, "runtime-loaded"
  end

  local lazy_plugin = lazy_yanky_plugin()
  if lazy_plugin then
    return true, false, "lazy-registry"
  end

  if yanky_runtime_installed() then
    return true, false, "runtime-files"
  end

  return false, false, ""
end

local function update_status(enabled, available, loaded, status, source)
  local state = utils.get_state()
  state.set_yanky_status(available, loaded, enabled, status, source)
end

local function attempt_lazy_load()
  local plugin = lazy_yanky_plugin()
  if not plugin then
    return false
  end

  local ok, lazy = pcall(require, "lazy")
  if not ok or type(lazy.load) ~= "function" then
    return false
  end

  local plugin_name = plugin.name or plugin[1] or "yanky.nvim"
  return pcall(lazy.load, { plugins = { plugin_name }, wait = false })
end

local function attempt_generic_load()
  local candidates = { "yanky.nvim", "yanky" }
  for _, package_name in ipairs(candidates) do
    if pcall(vim.cmd, "silent! packadd " .. package_name) and yanky_runtime_installed() then
      return true
    end
  end

  return false
end

local function probe_yanky(load_if_needed)
  local state = utils.get_state()
  local enabled = state.config.yanky_integration == true

  if not enabled then
    local available, loaded, source = detect_yanky_installation()
    update_status(false, available, loaded, available and (loaded and "ready" or "installed") or "absent", source)
    return false
  end

  if yanky_ready() then
    update_status(true, true, true, "ready", "plug-mapping")
    return true
  end

  local installed, loaded, source = detect_yanky_installation()
  if not installed then
    update_status(true, false, false, "absent", "")
    return false
  end

  if load_if_needed and not state.yanky_probe_attempted then
    state.yanky_probe_attempted = true
    attempt_lazy_load()
    attempt_generic_load()

    if yanky_ready() then
      update_status(true, true, true, "ready", "probe-load")
      return true
    end

    installed, loaded, source = detect_yanky_installation()
  end

  update_status(true, true, loaded, loaded and "loaded-not-ready" or "installed-not-loaded", source)
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

function M.ensure_yanky_loaded()
  return probe_yanky(true)
end

function M.copy_selection()
  if M.ensure_yanky_loaded() then
    feed("<Plug>(YankyYank)")
    sync_plus_from_unnamed()
    return
  end
  feed_visual('"+y')
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
    feed_visual([[<Plug>(YankyYank)gv"_d]])
    sync_plus_from_unnamed()
    return
  end
  feed_visual('"+d')
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
  feed_visual('"_d')
  vim.fn.setreg("+", plus, plus_type)
  vim.fn.setreg("*", star, star_type)
end

function M.detect_status(enabled)
  local state = utils.get_state()
  state.reset_yanky_probe()
  probe_yanky(false)
  if enabled ~= true then
    state.yanky_enabled = false
  end
end

return M
