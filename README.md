# gui-keymap.nvim

Use familiar GUI shortcuts in Neovim while learning native Vim commands.

## Demo

Run `:GuiKeymapDemo` to open a safe scratch buffer and test GUI-style shortcuts without touching your files.

On first install/update, the plugin also shows a one-time welcome notification.

## Why this plugin exists

- GUI editors rely on shortcuts like `Ctrl+C`, `Ctrl+V`, and `Ctrl+Z`.
- Vim uses native commands like `y`, `p`, and `u`.
- `gui-keymap.nvim` bridges that gap for a smoother transition.

## Features

- GUI-style shortcuts for copy, paste, cut, select all, undo, redo
- Shift + Arrow selection behavior
- GUI-style word deletion (`<C-BS>`, `<C-Del>`)
- Context-aware adaptive Vim hints (session-only)
- Safe keymap registration with conflict tracking
- Demo and showcase buffers
- Runtime enable / disable / refresh controls
- `:GuiKeymapInfo` diagnostics and `:checkhealth gui-keymap`
- Optional `which-key.nvim` integration
- Optional `yanky.nvim` integration (clipboard actions prefer Yanky when available)

## GUI -> Vim Keymap Comparison

| GUI Shortcut | Action | Vim Equivalent |
|--------------|--------|----------------|
| Ctrl+C | Copy | `y` / `yy` |
| Ctrl+V | Paste | `p` |
| Ctrl+X | Cut | `d` |
| Ctrl+A | Select All | `ggVG` |
| Ctrl+Z | Undo | `u` |
| Ctrl+Y | Redo | `<C-r>` |
| Ctrl+Backspace | Delete previous word | `db` |
| Ctrl+Delete | Delete next word | `dw` |

## Installation

### lazy.nvim

```lua
{
  "Only-Moon/gui-keymap.nvim",
  opts = {},
}
```

If `lazy.nvim` is not installed, use one of the methods below and call:

```lua
require("gui-keymap").setup({})
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

```lua
require("gui-keymap").setup({})
```

### Native packages

```sh
git clone https://github.com/Only-Moon/gui-keymap.nvim \
  ~/.local/share/nvim/site/pack/gui/start/gui-keymap.nvim
```

## Quick Start

1. Install the plugin with your plugin manager.
2. Start Neovim.
3. Run `:GuiKeymapDemo`.
4. Try the shortcuts in the demo buffer.

## Configuration

```lua
require("gui-keymap").setup({
  undo_redo = true,
  clipboard = {
    copy = true,
    paste = true,
    cut = true,
  },
  select_all = true,
  delete_selection = true,
  shift_selection = true,
  word_delete = true,
  yanky_integration = true,
  hint_enabled = true,
  hint_repeat = 3,
  which_key_integration = true,
  enforce_on_startup = true,
  force_priority = true,
  show_welcome = true,
  preserve_mode = true,
})
```

## Commands

| Command | Description |
|--------|-------------|
| `:GuiKeymapDemo` | Open safe demo buffer |
| `:GuiKeymapShowcase` | Open demo showcase with recording tips |
| `:GuiKeymapInfo` | Show plugin diagnostics summary |
| `:GuiKeymapEnable` | Enable GUI mappings |
| `:GuiKeymapDisable` | Disable GUI mappings |
| `:GuiKeymapList` | List active mappings |
| `:GuiKeymapExplain <key>` | Explain one mapped key |
| `:GuiKeymapRefresh` | Re-apply mappings |
| `:GuiKeymapHintReset` | Reset in-session hint counters |

## Health Check

Run:

`:checkhealth gui-keymap`

It reports plugin load status, config validity, keymap conflicts, and optional integration status.

For Yanky it distinguishes:
- not installed
- installed but lazy-not-loaded
- loaded in current session

## Who is this plugin for?

- Developers transitioning from VSCode or other GUI editors
- Vim/Neovim beginners
- Users who want GUI shortcuts while learning Vim
- Teams onboarding developers to Neovim

## Roadmap

- Transition mode
- GUI preset profiles (VSCode / JetBrains / Sublime)
- Advanced learning hints
- Adaptive teaching system
- Update changelog notification (planned for v2)

## Philosophy

Vim is powerful, but the transition can be steep.
`gui-keymap.nvim` lowers the entry barrier while encouraging users to learn native Vim workflows over time.
