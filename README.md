# gui-keymap.nvim

GUI-style keybindings for Neovim.

`gui-keymap.nvim` helps users coming from VSCode, Sublime Text, and JetBrains IDEs keep familiar shortcuts while learning native Vim motions.

## Purpose

Neovim is powerful, but shortcut muscle memory is a common adoption barrier. This plugin provides a configurable compatibility layer so users can transition gradually.

## Features

- GUI-style shortcuts (copy, paste, cut, select all, undo, redo)
- Shift + Arrow GUI-like text selection
- Delete selection mappings (`<BS>`, `<Del>` in visual mode)
- Safe mapping system (does not override existing keymaps)
- Keymap conflict tracking and health reporting
- Optional Vim hints via `vim.notify`
- Optional `yanky.nvim` integration
- Optional `which-key.nvim` registration (no hard dependency)
- Commands for diagnostics and hint reset

## Installation

### lazy.nvim / LazyVim

```lua
{
  "Only-Moon/gui-keymap.nvim",
  opts = {},
}
```

### packer.nvim

```lua
use({
  "Only-Moon/gui-keymap.nvim",
  config = function()
    require("gui-keymap").setup({})
  end,
})
```

### vim-plug

```vim
Plug 'Only-Moon/gui-keymap.nvim'
```

## Configuration

```lua
require("gui-keymap").setup({
  undo_redo = true,
  clipboard = true,
  select_all = true,
  delete_selection = true,
  shift_selection = true,
  yanky_integration = true,
  hint_enabled = true,
  hint_repeat = 3,
  which_key_integration = true,
})
```

Legacy toggles are also accepted for compatibility:
- `copy`
- `paste`
- `cut`
- `undo`
- `redo`

## Keymaps

### Undo / Redo

| Key | Mode | Action |
| --- | --- | --- |
| `<C-z>` | normal | `u` |
| `<C-y>` | normal | `<C-r>` |
| `<C-z>` | insert | `<C-o>u` |
| `<C-y>` | insert | `<C-o><C-r>` |

### Clipboard

| Key | Mode | Action |
| --- | --- | --- |
| `<C-c>` | visual | `"+y` |
| `<C-c>` | normal | `"+yy` |
| `<C-x>` | visual | `"+d` |
| `<C-v>` | normal | `"+p` |
| `<C-v>` | insert | `"+p` |

### Select All

| Key | Mode | Action |
| --- | --- | --- |
| `<C-a>` | normal | `ggVG` |
| `<C-a>` | insert | `<Esc>ggVG` |

### Delete Selection

| Key | Mode | Action |
| --- | --- | --- |
| `<BS>` | visual | `"_d` |
| `<Del>` | visual | `"_d` |

### Shift Selection

| Key | Mode | Action |
| --- | --- | --- |
| `<S-Left>` | normal | `v<Left>` |
| `<S-Right>` | normal | `v<Right>` |
| `<S-Up>` | normal | `v<Up>` |
| `<S-Down>` | normal | `v<Down>` |
| `<S-Left>` | visual | `<Left>` |
| `<S-Right>` | visual | `<Right>` |
| `<S-Up>` | visual | `<Up>` |
| `<S-Down>` | visual | `<Down>` |
| `<S-Left>` | insert | `<Esc>v<Left>` |
| `<S-Right>` | insert | `<Esc>v<Right>` |
| `<S-Up>` | insert | `<Esc>v<Up>` |
| `<S-Down>` | insert | `<Esc>v<Down>` |

## Commands

- `:GuiKeymapInfo` shows active mappings, disabled features, conflicts, and integration status.
- `:GuiKeymapHintReset` resets hint usage counters.
- `:checkhealth gui-keymap` reports health diagnostics.

## Architecture

- `plugin/gui-keymap.lua` loader + command registration + one-time setup
- `lua/gui-keymap/init.lua` entrypoint and module initialization
- `lua/gui-keymap/config.lua` defaults + merge + validation
- `lua/gui-keymap/keymaps.lua` mapping registry + conditional apply
- `lua/gui-keymap/utils.lua` safe_map + conflict/state helpers
- `lua/gui-keymap/hints.lua` hint notification system
- `lua/gui-keymap/health.lua` healthcheck implementation
- `lua/gui-keymap/info.lua` diagnostics output

## Roadmap

- Conflict resolution suggestions
- Additional GUI-like editing helpers
- More progressive Vim learning hints

## License

MIT
