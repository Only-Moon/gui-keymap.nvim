# gui-keymap.nvim

Use familiar GUI shortcuts in Neovim while learning native Vim commands.

## Requirements

- Neovim >= 0.8.0
- Not supported on classic Vim (non-Neovim)

## Demo

Run `:GuiKeymapDemo` to open a safe scratch buffer and test GUI-style shortcuts without touching your files.

On first install/update, the plugin also shows a one-time welcome notification.

## Why this plugin exists

- GUI editors rely on shortcuts like `Ctrl+C`, `Ctrl+V`, and `Ctrl+Z`.
- Vim uses native commands like `y`, `p`, and `u`.
- `gui-keymap.nvim` bridges that gap for a smoother transition.

## Features

- GUI-style shortcuts for copy, paste, cut, select all, undo, redo
- GUI-style save, save-and-close, home, and end mappings
- Shift + Arrow selection behavior
- GUI-style word deletion (`<C-BS>`, `<C-Del>`)
- Context-aware adaptive Vim hints with optional persisted counts
- Safe keymap registration with conflict tracking
- Demo buffer for safe testing
- Runtime enable / disable / refresh controls
- `:GuiKeymapInfo` diagnostics and `:checkhealth gui-keymap`
- Optional `which-key.nvim` integration
- Optional `yanky.nvim` integration (clipboard actions prefer Yanky when available)

## GUI -> Vim Keymap Comparison

| GUI Shortcut | Vim Equivalent | Action |
|--------------|----------------|--------|
| Ctrl+C | `y` / `yy` | Copy |
| Ctrl+V | `p` | Paste |
| Ctrl+X | `d` | Cut |
| Ctrl+A | `ggVG` | Select All |
| Ctrl+Z | `u` | Undo |
| Ctrl+Y | `<C-r>` | Redo |
| Ctrl+S | `:write` | Save |
| Ctrl+Q | `:confirm wq` | Save and close |
| Home | `0` | Move to line start |
| End | `$` | Move to line end |
| Ctrl+Backspace | GUI-style previous-word delete | Delete previous word |
| Ctrl+Delete | GUI-style next-word delete | Delete next word |

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

Then call:

```lua
require("gui-keymap").setup({})
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
  save = true,
  quit = true,
  home_end = true,
  yanky_integration = true,
  hint_enabled = true,
  hint_repeat = 3,
  hint_persist = true,
  which_key_integration = true,
  enforce_on_startup = true,
  force_priority = true,
  show_welcome = true,
  preserve_mode = true,
})
```

If you do not pass `opts`, these defaults are used automatically.

| Option | Default | Purpose |
|--------|---------|---------|
| `undo_redo` | `true` | Enable `Ctrl+Z` undo and `Ctrl+Y` redo mappings. |
| `clipboard.copy` | `true` | Enable GUI-style copy mappings. |
| `clipboard.paste` | `true` | Enable GUI-style paste mappings. |
| `clipboard.cut` | `true` | Enable GUI-style cut mappings. |
| `select_all` | `true` | Enable `Ctrl+A` select-all mappings. |
| `delete_selection` | `true` | Enable visual-mode `<BS>` and `<Del>` black-hole delete mappings. |
| `shift_selection` | `true` | Enable Shift+Arrow selection mappings and terminal fallbacks. |
| `word_delete` | `true` | Enable GUI-style `Ctrl+Backspace` and `Ctrl+Delete` word deletion mappings. |
| `save` | `true` | Enable `Ctrl+S` save mappings. |
| `quit` | `true` | Enable `Ctrl+Q` save-and-close mappings using `:confirm wq`. |
| `home_end` | `true` | Enable `Home` / `End` line movement mappings. |
| `yanky_integration` | `true` | Prefer Yanky-backed clipboard behavior when Yanky is installed. |
| `hint_enabled` | `true` | Show adaptive Vim learning hints for GUI shortcuts. |
| `hint_repeat` | `3` | Maximum hint displays per shortcut in one session. Use `-1` to always show hints. |
| `hint_persist` | `true` | Persist hint counters across Neovim restarts using the Neovim state directory. |
| `which_key_integration` | `true` | Register active mappings with `which-key.nvim` when available. |
| `enforce_on_startup` | `true` | Re-apply mappings during startup to handle lazy-loading race conditions. |
| `force_priority` | `true` | Allow gui-keymap to overwrite conflicting non-user default mappings. |
| `show_welcome` | `true` | Show a one-time welcome notification after a fresh install or plugin version change. |
| `preserve_mode` | `true` | Return to the original mode for mappings that can safely preserve it. |

## Commands

| Command | Description |
|--------|-------------|
| `:GuiKeymapDemo` | Open safe demo buffer |
| `:GuiKeymapInfo` | Open plugin diagnostics in a scratch buffer |
| `:GuiKeymapEnable` | Enable GUI mappings |
| `:GuiKeymapDisable` | Disable GUI mappings |
| `:GuiKeymapList` | Open active mappings in a scratch buffer |
| `:GuiKeymapSkipped` | Open skipped mappings in a scratch buffer |
| `:GuiKeymapExplain <key>` | Open a mapping explanation in a scratch buffer |
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

It also reports:
- conflict counts by feature
- terminal-sensitive mappings
- fallback mappings
- hint persistence state

## Compatibility Notes

- Shift + Arrow mappings depend on your terminal emitting shifted-arrow keycodes. On some terminals the plugin will use fallback codes such as `<kL>` and `<kR>`, but support still varies by terminal emulator and multiplexer.
- `Ctrl+Backspace` and `Ctrl+Delete` are terminal-dependent on Windows Terminal, tmux, WSL shells, and some Linux/macOS terminal defaults. Some terminals send `Ctrl+Backspace` as `<C-h>`, and gui-keymap supports that insert-mode fallback.
- System clipboard behavior depends on Neovim clipboard support and your environment. When `yanky.nvim` is available, clipboard actions prefer Yanky. Otherwise gui-keymap falls back to Neovim register sync.
- If a terminal does not emit the expected keycodes, `:GuiKeymapInfo` and `:checkhealth gui-keymap` will help you confirm which mappings were applied and which fallback mappings are active.

## Local Testing

On Unix-like systems or CI:

```sh
make smoke
```

On Windows PowerShell:

```powershell
pwsh -File .\scripts\cli-smoke.ps1
```

## Who is this plugin for?

- Developers transitioning from VSCode or other GUI editors
- Vim/Neovim beginners
- Users who want GUI shortcuts while learning Vim
- Teams onboarding developers to Neovim

## Roadmap

- Transition mode
- GUI preset profiles (VSCode / JetBrains / Sublime)
- Configurable search and replace hooks for external UI plugins
- Advanced learning hints
- Adaptive teaching system
- Update changelog notification (planned for v2)

## Philosophy

Vim is powerful, but the transition can be steep.
`gui-keymap.nvim` lowers the entry barrier while encouraging users to learn native Vim workflows over time.
