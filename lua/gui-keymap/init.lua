local config = require("gui-keymap.config")
local hints = require("gui-keymap.hints")
local keymaps = require("gui-keymap.keymaps")
local info = require("gui-keymap.info")

local M = {}

---@type GuiKeymapOptions
M.options = config.merge()
M._enforce_group = nil
M._welcome_shown = false
M._setup_done = false

function M.apply()
  hints.setup(M.options)
  keymaps.apply(M.options)
end

local function schedule_enforcement_passes()
  if not M.options.enforce_on_startup then
    return
  end

  for _, delay in ipairs({ 30, 180, 600 }) do
    vim.defer_fn(function()
      M.apply()
    end, delay)
  end
end

function M.setup_enforcement_autocmds()
  if M._enforce_group then
    return
  end

  M._enforce_group = vim.api.nvim_create_augroup("GuiKeymapEnforce", { clear = true })

  vim.api.nvim_create_autocmd("User", {
    group = M._enforce_group,
    pattern = { "VeryLazy", "LazyDone" },
    callback = function()
      M.apply()
    end,
  })
end

local function maybe_show_welcome()
  if M._welcome_shown or not M.options.show_welcome then
    return
  end

  M._welcome_shown = true
  vim.notify(
    "Welcome to gui-keymap.nvim\n\nRun :GuiKeymapDemo to test GUI shortcuts safely.",
    vim.log.levels.INFO,
    { title = "gui-keymap" }
  )
end

---@param user_opts GuiKeymapOptions|nil
---@return GuiKeymapOptions
function M.setup(user_opts)
  if M._setup_done and user_opts == nil then
    return M.options
  end

  M.options = config.merge(user_opts)

  local errors = config.validate(M.options)
  if #errors > 0 then
    vim.notify("gui-keymap: invalid configuration: " .. table.concat(errors, ", "), vim.log.levels.WARN)
  end

  M.apply()
  M.setup_enforcement_autocmds()
  schedule_enforcement_passes()
  maybe_show_welcome()
  M._setup_done = true

  return M.options
end

function M.show_info()
  info.show(M.options)
end

function M.reset_hints()
  hints.reset()
end

function M.refresh()
  M.apply()
end

return M
