# Keymaps and Behavior

## GUI shortcut table

| Shortcut | Mode | Behavior | Vim equivalent |
|----------|------|----------|----------------|
| `Ctrl+C` | normal | copy line | `yy` |
| `Ctrl+C` | visual | copy selection | `y` |
| `Ctrl+V` | normal | paste | `p` |
| `Ctrl+V` | insert | paste | insert paste |
| `Ctrl+X` | visual | cut selection | `d` |
| `Ctrl+A` | normal | select all | `ggVG` |
| `Ctrl+A` | insert | select all | `<Esc>ggVG` |
| `Ctrl+Z` | normal | undo | `u` |
| `Ctrl+Z` | insert | undo | `<C-o>u` |
| `Ctrl+Y` | normal | redo | `<C-r>` |
| `Ctrl+Y` | insert | redo | `<C-o><C-r>` |
| `Ctrl+S` | normal | save buffer | `:write` |
| `Ctrl+S` | insert | save buffer | `:write` |
| `Ctrl+S` | visual | save buffer | `:write` |
| `Ctrl+Q` | normal | save and close | `:confirm wq` |
| `Ctrl+Q` | insert | save and close | `:confirm wq` |
| `Home` | normal | line start | `0` |
| `Home` | insert | line start | `<C-o>0` |
| `Home` | visual | line start | `0` |
| `End` | normal | line end | `$` |
| `End` | insert | line end | `<C-o>$` |
| `End` | visual | line end | `$` |
| `Ctrl+Backspace` | normal | delete previous word | GUI-style previous-word delete |
| `Ctrl+Backspace` | insert | delete previous word | GUI-style previous-word delete |
| `Ctrl+Delete` | normal | delete next word | GUI-style next-word delete |
| `Ctrl+Delete` | insert | delete next word | GUI-style next-word delete |

## Delete-selection mappings

Visual mode:

- `Backspace`
- `Delete`

These use the black-hole register so clipboard contents are preserved.

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
