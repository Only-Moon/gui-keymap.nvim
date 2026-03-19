local hints = require("gui-keymap.hints")
local plugin = require("gui-keymap")
local state = require("gui-keymap.state")
local t = require("tests.gui-keymap.helpers")

describe("gui-keymap hints", function()
  local original_notify

  before_each(function()
    original_notify = vim.notify
    t.reset_runtime()
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

  for _, item in ipairs(require("gui-keymap.keymaps").registry) do
    if item.hint_key then
      local label = string.format(
        "%s %s emits a hint",
        type(item.mode) == "table" and table.concat(item.mode, ",") or item.mode,
        item.lhs
      )
      it(label, function()
        t.prepare_for_mapping(item.mode, item.lhs)

        local messages = with_notify_capture(function()
          local result = t.invoke_map_with_result(item.mode, item.lhs)
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
