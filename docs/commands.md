# Commands and Diagnostics

## User commands

### `:GuiKeymapDemo`

Opens a scratch buffer for safe shortcut testing.

Buffer properties:

- `buftype=nofile`
- `bufhidden=wipe`
- `swapfile=false`
- `filetype=gui-keymap-demo`

### `:GuiKeymapInfo`

Opens a diagnostic report with:

- active mappings
- requested mappings
- skipped mappings
- disabled features
- raw conflicts
- conflict summary by feature
- fallback mappings
- terminal-sensitive mappings
- Yanky status
- which-key status
- hint status

### `:GuiKeymapList`

Shows all active mappings registered by the plugin.

### `:GuiKeymapSkipped`

Shows mappings that were requested but skipped because of conflicts.

### `:GuiKeymapExplain <key>`

Explains one shortcut and shows the Vim equivalent.

Examples:

- `:GuiKeymapExplain <C-c>`
- `:GuiKeymapExplain <C-s>`
- `:GuiKeymapExplain <Home>`

### `:GuiKeymapEnable`

Re-enables gui-keymap mappings and refreshes them.

### `:GuiKeymapDisable`

Removes gui-keymap mappings from the current session.

### `:GuiKeymapRefresh`

Re-applies mappings without requiring a Neovim restart.

### `:GuiKeymapHintReset`

Clears hint counters.

If persistent hints are enabled, this also removes the stored counter file from
Neovim’s state directory.

## Health check

Run:

```vim
:checkhealth gui-keymap
```

Health output covers:

- plugin loaded state
- configuration validity
- requested/applied/skipped counts
- mapping conflicts
- conflict summary by feature
- Yanky status
- which-key status
- fallback mappings
- terminal-sensitive mappings
- hint persistence state

## Conflict reporting

The plugin does not only report raw key conflicts.

It also groups them by feature, so end users can quickly tell whether the
problem is mostly in:

- clipboard
- shift selection
- home/end
- save/quit
- other feature groups

## When diagnostics matter most

Use `:GuiKeymapInfo` or `:checkhealth gui-keymap` when:

- mappings do not apply in LazyVim or AstroNvim
- a terminal does not send Shift+Arrow correctly
- clipboard behavior differs from expectations
- another plugin is claiming the same keys
