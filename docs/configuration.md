# Configuration Reference

## Default configuration

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

If you pass no options, these defaults are used automatically.

## Option reference

### `undo_redo`

Enables `Ctrl+Z` and `Ctrl+Y` mappings in normal and insert mode.

### `clipboard.copy`

Enables GUI-style copy mappings:

- visual `Ctrl+C`
- normal `Ctrl+C`

### `clipboard.paste`

Enables GUI-style paste mappings:

- normal `Ctrl+V`
- insert `Ctrl+V`

### `clipboard.cut`

Enables GUI-style cut mapping in visual mode with `Ctrl+X`.

### `select_all`

Enables `Ctrl+A` select-all behavior.

### `delete_selection`

Enables visual-mode deletion using:

- `Backspace`
- `Delete`

These use the black-hole register to avoid overwriting clipboard content.

### `shift_selection`

Enables GUI-style selection growth using Shift+Arrow keys in normal, visual,
and insert mode.

This feature is terminal-sensitive. Some terminals emit fallback keycodes such
as `<kL>` or `<kR>` instead of literal Shift+Arrow sequences.

### `word_delete`

Enables:

- `Ctrl+Backspace`
- `Ctrl+Delete`

Mapped to GUI-style word deletion behavior that avoids polluting clipboard state.

### `save`

Enables `Ctrl+S` to save the current buffer.

Modes:

- normal
- insert
- visual

### `quit`

Enables `Ctrl+Q` to save and close the current file.

Behavior:

1. saves pending changes
2. runs `:confirm wq`

### `home_end`

Enables `Home` and `End` mappings in normal, insert, and visual mode.

Behavior:

- `Home` -> line start
- `End` -> line end

### `yanky_integration`

If `yanky.nvim` is installed, clipboard actions prefer Yanky-backed handlers.

If Yanky is not installed, gui-keymap falls back to Neovim register-based
clipboard handling.

### `hint_enabled`

Turns hints on or off globally.

### `hint_repeat`

Controls how many times a hint can appear for a given shortcut.

- `0` disables display after zero uses
- positive number limits how many times a hint can show
- `-1` means always show

### `hint_persist`

Stores hint counters in Neovim’s state directory so the learning progress does
not reset every time Neovim restarts.

### `which_key_integration`

If `which-key.nvim` is available, active mappings are registered with
descriptions.

### `enforce_on_startup`

Re-applies mappings during startup to handle lazy-loading races from plugin
managers and distributions.

### `force_priority`

When enabled, gui-keymap can replace conflicting default/editor mappings.

When disabled, conflicting mappings are skipped and reported in diagnostics.

### `show_welcome`

Controls the welcome notification shown after first install or after plugin
version changes.

### `preserve_mode`

For compatible mappings, returns the user to their original mode after the
mapped action finishes.

## Recommended minimal setup

```lua
require("gui-keymap").setup({
  show_welcome = true,
})
```

## Conservative setup

```lua
require("gui-keymap").setup({
  shift_selection = false,
  force_priority = false,
  hint_enabled = false,
})
```
