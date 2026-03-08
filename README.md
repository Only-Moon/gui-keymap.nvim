# gui-keymap.nvim

Stop fighting muscle memory.

`gui-keymap.nvim` provides GUI-style shortcuts for Neovim users transitioning from VSCode, JetBrains IDEs, or Sublime while gradually teaching native Vim commands.

## Features

- GUI keymaps: copy/paste/cut/select-all/undo/redo
- Shift+Arrow GUI-style selection
- Word delete shortcuts (`<C-BS>`, `<C-Del>`)
- Safe keymap registration with conflict tracking
- Adaptive, throttled hints (session-only)
- Session onboarding (`VimEnter`) via `onboard.lua`
- Demo + Showcase buffers
- Runtime commands: enable/disable/list/explain
- Health checks and diagnostics
- Optional `which-key.nvim` and `yanky.nvim` integration
- Central runtime state container (`state.lua`)

## Installation

### lazy.nvim / LazyVim

```lua
{
  "Only-Moon/gui-keymap.nvim",
  opts = {},
}
```

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
  show_welcome = false,
  preserve_mode = true,
})
```

### Option reference

- `undo_redo`: toggle `<C-z>` / `<C-y>` mappings.
- `clipboard.copy`: toggle copy mappings.
- `clipboard.paste`: toggle paste mappings.
- `clipboard.cut`: toggle cut mapping.
- `select_all`: toggle `<C-a>` mappings.
- `delete_selection`: toggle visual `<BS>`/`<Del>` delete mappings.
- `shift_selection`: toggle Shift+Arrow mappings.
- `word_delete`: toggle `<C-BS>` / `<C-Del>` mappings.
- `yanky_integration`: enable optional yanky status/mappings handling.
- `hint_enabled`: enable/disable hints.
- `hint_repeat`: max hint count per shortcut (`-1` always).
- `which_key_integration`: register active maps with which-key.
- `enforce_on_startup`: re-apply mappings on lazy startup events.
- `force_priority`: allow gui-keymap to override preexisting mappings.
- `show_welcome`: show onboarding message once per session.
- `preserve_mode`: return to previous mode after mapped action.

Legacy toggles (`copy`, `paste`, `cut`, `undo`, `redo`) are still accepted.

## Commands

- `:GuiKeymapDemo`
- `:GuiKeymapShowcase`
- `:GuiKeymapInfo`
- `:GuiKeymapEnable`
- `:GuiKeymapDisable`
- `:GuiKeymapList`
- `:GuiKeymapExplain <key>`
- `:GuiKeymapRefresh`
- `:GuiKeymapHintReset`
- `:checkhealth gui-keymap`

## Architecture

- `plugin/gui-keymap.lua`
- `lua/gui-keymap/init.lua`
- `lua/gui-keymap/config.lua`
- `lua/gui-keymap/keymaps.lua`
- `lua/gui-keymap/hints.lua`
- `lua/gui-keymap/utils.lua`
- `lua/gui-keymap/state.lua`
- `lua/gui-keymap/demo.lua`
- `lua/gui-keymap/onboard.lua`
- `lua/gui-keymap/info.lua`
- `lua/gui-keymap/health.lua`

## Roadmap

- Transition mode
- GUI preset profiles (VSCode / JetBrains / Sublime)
- Learning mode improvements
- Context-aware advanced teaching
- Adaptive learning engine

## License

MIT