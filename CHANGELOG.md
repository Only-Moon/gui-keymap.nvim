# Changelog

All notable user-facing changes to this project will be documented in this file.

## Unreleased

Changes since `v1.2` (2026-03-08).

### Added

- Added GUI-style save, save-and-close, Home, and End mappings so common desktop editor shortcuts work out of the box.
- Added adaptive, coaching-style hints with optional persistent counts to help users learn the native Vim motions behind each GUI shortcut.
- Added richer diagnostics through `:GuiKeymapInfo` and `:checkhealth gui-keymap`, including clearer integration and mapping state reporting.
- Added optional `preserve_mode` support so visual and selection workflows can stay consistent while using GUI-style shortcuts.
- Added LuaRocks packaging and smoke-test tooling to make installation and release validation easier.
- Added a fuller documentation site covering installation, configuration, commands, keymaps, and troubleshooting.

### Improved

- Improved onboarding so the welcome flow is better timed, less noisy, and more useful after install or plugin updates.
- Improved `yanky.nvim` integration by preferring Yanky handlers when available, reporting integration state more clearly, and handling lazy-loaded setups more reliably.
- Improved runtime safety with stronger keymap registration, conflict tracking, and refresh behavior.
- Improved the demo experience and command feedback so supported shortcuts are easier to discover and verify safely.
- Improved plugin defaults so common setups require less manual configuration.

### Fixed

- Fixed several false-positive keymap conflict reports, including common Shift+Arrow overlaps.
- Fixed clipboard and delete mappings to behave more deterministically across supported modes.
- Fixed core GUI mappings so they initialize more reliably and handle keycode mappings correctly.
- Fixed visual and select mode alignment for selection mappings.
- Fixed hint behavior edge cases, including support for `hint_repeat = -1`.
- Fixed welcome notifications so they wait for the UI when needed and ignore unrelated helptags output.

