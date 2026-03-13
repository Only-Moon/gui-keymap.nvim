# Troubleshooting

## `Ctrl+Y` does not redo

Check:

- `:GuiKeymapInfo`
- `:checkhealth gui-keymap`

Possible causes:

- another mapping already owns `Ctrl+Y`
- terminal or distribution remapped it
- `undo_redo = false`

## `Ctrl+S` does not save

Possible causes:

- another plugin already maps `Ctrl+S`
- your terminal intercepts `Ctrl+S` for flow control

On some terminals, `Ctrl+S` and `Ctrl+Q` are affected by XON/XOFF flow
control. Disable that in your terminal if needed.

## `Ctrl+Q` does not close as expected

The plugin treats `Ctrl+Q` as save-and-close, not a raw `:quit`.

Behavior:

1. saves pending changes
2. runs `:confirm wq`

If a terminal intercepts `Ctrl+Q`, the key may never reach Neovim.

## Shift+Arrow is inconsistent

This is the most terminal-sensitive feature in the plugin.

Check:

- `:GuiKeymapInfo`
- `:checkhealth gui-keymap`

Look for:

- terminal-sensitive mappings
- fallback mappings such as `<kL>`, `<kR>`, `<kU>`, `<kD>`

Some terminals, multiplexers, and WSL setups emit different keycodes.

## Clipboard behavior is odd

Possible causes:

- no system clipboard support in Neovim
- terminal/OS clipboard limitations
- Yanky installed but not loaded yet
- another clipboard plugin intercepting the same keys

Check:

- Yanky status in `:GuiKeymapInfo`
- conflict summary in `:GuiKeymapInfo`

## Hints are not appearing

Check:

- `hint_enabled = true`
- `hint_repeat` is not exhausted
- `hint_persist` did not carry forward an already-exhausted count

If needed, run:

```vim
:GuiKeymapHintReset
```

## Mappings are skipped in LazyVim or AstroNvim

Check:

- `force_priority`
- `enforce_on_startup`
- `:GuiKeymapSkipped`
- `:GuiKeymapInfo`

If a distribution claims the same keys after startup, startup enforcement is
what re-applies gui-keymap mappings.

## `:GuiKeymapInfo` shows conflicts but I did not add mappings

Distributions and plugins often register defaults automatically.

That still counts as a real conflict.

Examples:

- built-in defaults
- distribution defaults
- which-key-related setup
- terminal fallback keys
- clipboard plugins

## Hints did not reset after restart

If `hint_persist = true`, counters are stored across restarts.

Run:

```vim
:GuiKeymapHintReset
```

to clear them manually.

## Pure Vim support

This plugin is Neovim-only.

It is not intended for classic Vim.
