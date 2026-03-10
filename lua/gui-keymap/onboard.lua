local M = {}

local version = require("gui-keymap.version")
local STATE_FILE = vim.fn.stdpath("state") .. "/gui-keymap-onboard.json"

local function current_identity()
  return version.identity()
end

local function read_state()
  if vim.fn.filereadable(STATE_FILE) ~= 1 then
    return {}
  end

  local lines = vim.fn.readfile(STATE_FILE)
  if #lines == 0 then
    return {}
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok or type(decoded) ~= "table" then
    return {}
  end

  return decoded
end

local function write_state(data)
  vim.fn.mkdir(vim.fn.fnamemodify(STATE_FILE, ":h"), "p")
  local ok, encoded = pcall(vim.json.encode, data)
  if not ok then
    return
  end

  vim.fn.writefile({ encoded }, STATE_FILE)
end

local function should_show_welcome()
  local state = read_state()
  return state.version ~= current_identity()
end

local function show_and_persist()
  vim.notify(
    "Welcome to gui-keymap.nvim\n\nRun :GuiKeymapDemo to try GUI shortcuts safely.",
    vim.log.levels.INFO,
    { title = "gui-keymap" }
  )
  write_state({ version = current_identity(), shown_at = os.time() })
end

function M.setup(opts)
  if opts.show_welcome ~= true then
    return
  end

  if not should_show_welcome() then
    return
  end

  local shown = false
  local function once_show()
    if shown then
      return
    end
    shown = true
    show_and_persist()
  end

  if vim.v.vim_did_enter == 1 then
    if package.loaded["notify"] ~= nil or package.loaded["snacks"] ~= nil then
      vim.schedule(once_show)
    else
      vim.defer_fn(once_show, 400)
    end
    return
  end

  local group = vim.api.nvim_create_augroup("GuiKeymapOnboard", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = { "VeryLazy", "LazyDone" },
    once = true,
    callback = once_show,
  })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    once = true,
    callback = function()
      vim.defer_fn(once_show, 400)
    end,
  })
end

return M
