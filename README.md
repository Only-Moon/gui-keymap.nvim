# gui-keymap.nvim

GUI-style keybindings for Neovim.

## Installation

### lazy.nvim / LazyVim

```lua
{
  "Only-Moon/gui-keymap.nvim",
  opts = {
    copy = true,
    paste = true,
    cut = true,
    select_all = true,
    undo = true,
    redo = true,
  },
}
```

## Configuration

```lua
require("gui-keymap").setup({
  copy = true,
  paste = true,
  cut = true,
  select_all = true,
  undo = true,
  redo = true,
})
```

## Keymaps

- `<C-c>` copy
- `<C-v>` paste
- `<C-x>` cut
- `<C-a>` select all
- `<C-z>` undo
- `<C-y>` redo
