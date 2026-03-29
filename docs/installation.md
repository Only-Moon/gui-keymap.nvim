# Installation

## Requirements

- Neovim `>= 0.8.0`
- Classic Vim is not supported

## lazy.nvim

```lua
{
  "Only-Moon/gui-keymap.nvim",
  ---@type GuiKeymapOptions
  opts = {},
}
```

## packer.nvim

```lua
use({
  "Only-Moon/gui-keymap.nvim",
  config = function()
    ---@type GuiKeymapOptions
    local opts = {}

    require("gui-keymap").setup(opts)
  end,
})
```

## vim-plug

```vim
Plug 'Only-Moon/gui-keymap.nvim'
```

Then:

```lua
---@type GuiKeymapOptions
local opts = {}

require("gui-keymap").setup(opts)
```

## Native packages

```sh
git clone https://github.com/Only-Moon/gui-keymap.nvim \
  ~/.local/share/nvim/site/pack/gui/start/gui-keymap.nvim
```

Then:

```lua
---@type GuiKeymapOptions
local opts = {}

require("gui-keymap").setup(opts)
```

## First-run flow

If welcome notifications are enabled, the plugin shows a one-time onboarding
message after a fresh install or after the plugin version changes.

## Verify installation

Inside Neovim:

```vim
:GuiKeymapDemo
:GuiKeymapInfo
:checkhealth gui-keymap
```
