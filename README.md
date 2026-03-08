# gui-keymap.nvim

Stop fighting muscle memory.

`gui-keymap.nvim` lets you use familiar GUI shortcuts (`Ctrl+C`, `Ctrl+V`, `Ctrl+Z`, `Shift+Arrows`) while gradually learning native Vim commands.

## Why this plugin exists

Users moving from VSCode, Sublime, or JetBrains often hit friction on day one because default Vim shortcuts behave differently. This plugin adds a lightweight compatibility layer so onboarding into Neovim is smoother.

## Features

- GUI-style keymaps for copy, paste, cut, select-all, undo, redo
- Shift+Arrow selection in normal/visual/insert modes
- GUI-style word delete (`Ctrl+Backspace`, `Ctrl+Delete`)
- Optional adaptive Vim hints (`vim.notify`) with per-session counters only
- First-run session welcome message with demo prompt
- Safe-map conflict tracking + `:checkhealth gui-keymap`
- `:GuiKeymapInfo`, `:GuiKeymapRefresh`, `:GuiKeymapHintReset`, `:GuiKeymapDemo`, `:GuiKeymapShowcase`
- Optional `which-key.nvim` registration (no dependency)
- Optional `yanky.nvim` status integration (does not override yanky mappings)

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
  word_delete = true,
  yanky_integration = true,
  hint_enabled = true,
  hint_repeat = 3, -- set -1 to always show hints
  which_key_integration = true,
  enforce_on_startup = true,
  force_priority = true, -- registers keymaps on top of all plugins
  show_welcome = false, -- set true to show onboarding once per plugin version
  preserve_mode = true, -- return to the current mode after using keymap
})
```

Legacy toggles are still supported: `copy`, `paste`, `cut`, `undo`, `redo`.

Option reference:

- `undo_redo`: enable/disable `<C-z>` and `<C-y>` mappings.
- `clipboard`: enable/disable copy/cut/paste GUI mappings.
- `select_all`: enable/disable `<C-a>` select-all mappings.
- `delete_selection`: enable/disable visual delete on `<BS>`/`<Del>`.
- `shift_selection`: enable/disable Shift+Arrow selection mappings.
- `word_delete`: enable/disable `<C-BS>`/`<C-Del>` word delete mappings.
- `yanky_integration`: detect `yanky.nvim` and report status in info/health.
- `hint_enabled`: show learning hints via `vim.notify`.
- `hint_repeat`: number of times to show each hint (`-1` means always).
- `which_key_integration`: register active mappings with `which-key` when installed.
- `enforce_on_startup`: re-apply mappings during startup/lazy events.
- `force_priority`: registers keymaps on top of all plugins.
- `show_welcome`: show onboarding message (once per plugin version when enabled).
- `preserve_mode`: return to the current mode after using keymap.

## GUI to Vim Comparison

| GUI Shortcut | Vim Equivalent |
| --- | --- |
| `Ctrl+C` | `y` |
| `Ctrl+V` | `p` |
| `Ctrl+X` | `d` |
| `Ctrl+A` | `ggVG` |
| `Ctrl+Z` | `u` |
| `Ctrl+Y` | `<C-r>` |

## Keymaps

| Key | Mode | Action |
| --- | --- | --- |
| `<C-z>` | `n` | `u` |
| `<C-y>` | `n` | `<C-r>` |
| `<C-z>` | `i` | `<C-o>u` |
| `<C-y>` | `i` | `<C-o><C-r>` |
| `<C-c>` | `x` | `"+y` |
| `<C-c>` | `n` | `"+yy` |
| `<C-x>` | `x` | `"+d` |
| `<C-v>` | `n,i` | `"+p` |
| `<C-a>` | `n` | `ggVG` |
| `<C-a>` | `i` | `<Esc>ggVG` |
| `<BS>` / `<Del>` | `x` | `"_d` |
| `<S-Left/Right/Up/Down>` | `n` | start selection |
| `<S-Left/Right/Up/Down>` | `x` | expand selection |
| `<S-Left/Right/Up/Down>` | `i` | enter visual + select |
| `<C-BS>` | `n` | `db` |
| `<C-Del>` | `n` | `dw` |
| `<C-BS>` | `i` | `<C-o>db` |
| `<C-Del>` | `i` | `<C-o>dw` |

## Demo

Run:

```vim
:GuiKeymapDemo
```

This opens a temporary scratch buffer where you can safely test mappings without touching project files.

## Who is this plugin for?

- Developers switching from VSCode/Sublime/JetBrains
- Vim beginners
- Users who want GUI shortcuts temporarily
- Teams teaching Vim to newcomers

## Commands

- `:GuiKeymapInfo`
- `:GuiKeymapRefresh`
- `:GuiKeymapHintReset`
- `:GuiKeymapDemo`
- `:GuiKeymapShowcase`
- `:checkhealth gui-keymap`

## Architecture

- `plugin/gui-keymap.lua`
- `lua/gui-keymap/init.lua`
- `lua/gui-keymap/config.lua`
- `lua/gui-keymap/keymaps.lua`
- `lua/gui-keymap/utils.lua`
- `lua/gui-keymap/hints.lua`
- `lua/gui-keymap/demo.lua`
- `lua/gui-keymap/health.lua`
- `lua/gui-keymap/info.lua`

## License

MIT
