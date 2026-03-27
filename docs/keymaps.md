# Keymaps and Behavior

## GUI shortcut table

This page follows the same teaching order as `:GuiKeymapDemo`:

`GUI shortcut -> Vim equivalent -> action`

| Shortcut | Mode | Vim equivalent | Action |
|----------|------|----------------|--------|
| `Ctrl+C` | normal | `yy` | Copy line |
| `Ctrl+C` | visual | `y` | Copy selection |
| `Ctrl+V` | normal | `p` | Paste |
| `Ctrl+V` | insert | insert paste | Paste |
| `Ctrl+X` | visual | `d` | Cut selection |
| `Ctrl+A` | normal | `ggVG` | Select all |
| `Ctrl+A` | insert | `<Esc>ggVG` | Select all |
| `Ctrl+Z` | normal | `u` | Undo |
| `Ctrl+Z` | insert | `<C-o>u` | Undo |
| `Ctrl+Y` | normal | `<C-r>` | Redo |
| `Ctrl+Y` | insert | `<C-o><C-r>` | Redo |
| `Ctrl+S` | normal | `:write` | Save buffer |
| `Ctrl+S` | insert | `:write` | Save buffer |
| `Ctrl+S` | visual | `:write` | Save buffer |
| `Ctrl+Q` | normal | `:confirm wq` | Save and close |
| `Ctrl+Q` | insert | `:confirm wq` | Save and close |
| `Home` | normal | `0` | Move to line start |
| `Home` | insert | `<C-o>0` | Move to line start |
| `Home` | visual | `0` | Move to line start |
| `End` | normal | `$` | Move to line end |
| `End` | insert | `<C-o>$` | Move to line end |
| `End` | visual | `$` | Move to line end |
| `Ctrl+Backspace` | normal | GUI-style previous-word delete | Delete previous word |
| `Ctrl+Backspace` | insert | GUI-style previous-word delete | Delete previous word |
| `Ctrl+Delete` | normal | GUI-style next-word delete | Delete next word |
| `Ctrl+Delete` | insert | GUI-style next-word delete | Delete next word |

## Delete-selection mappings

Visual mode:

- `Backspace`
- `Delete`

These use the black-hole register so clipboard contents are preserved.

## Word deletion notes

- `Ctrl+Backspace` and `Ctrl+Delete` are implemented with GUI-style delete behavior, not literal yank-producing Vim motions.
- In some terminals, insert-mode `Ctrl+Backspace` arrives as `<C-h>`. gui-keymap supports that fallback.

## Shift+Arrow selection

### Normal mode

- `Shift+Left`
- `Shift+Right`
- `Shift+Up`
- `Shift+Down`

These start visual selection and move in the requested direction.

### Visual mode

The same keys extend the current selection.

### Insert mode

The same keys leave insert mode, enter visual selection, and move accordingly.

## Clipboard behavior

### Without Yanky

- copy, cut, and paste use Neovim register-based handling
- clipboard state is synchronized as safely as possible with `+` and unnamed
  registers

### With Yanky

- clipboard actions prefer Yanky handlers
- no hard dependency is created
- diagnostics show whether Yanky is installed, loaded, or only available for
  lazy load

## Save and close behavior

### `Ctrl+S`

Saves the current buffer with `:update`.

### `Ctrl+Q`

`Ctrl+Q` is treated as a GUI-style save-and-close action and runs `:confirm wq`.

## Mode preservation

If `preserve_mode = true`, compatible mappings return the user to the original
mode after the action.

Not every mapping preserves mode. Selection-starting mappings intentionally
change mode because that is their behavior.
