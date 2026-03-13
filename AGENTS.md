# Repository Guidelines

## Accuracy & Bug Workflow
Do not default to agreeing with the user. Prioritize accuracy over agreement. If a user statement is incorrect, misleading, or incomplete, challenge it directly and explain why using evidence, research, and clear reasoning. Verify claims when needed and aim for the most accurate conclusion rather than validation.

When a user reports a bug, do not start by patching the implementation. Start by writing or updating a test that reproduces the reported behavior. Once the failing test exists, use available parallel investigation/fix workflows where helpful, then prove the fix with a passing test before considering the bug resolved.

## Project Structure & Module Organization
`lua/gui-keymap/` contains the plugin modules: setup, commands, mappings, health checks, hints, and state management. `plugin/gui-keymap.lua` is the runtime entrypoint that registers commands and applies default setup. Tests live under `tests/`, with `tests/minimal_init.lua` bootstrapping Plenary and `tests/gui-keymap/*_spec.lua` holding behavior specs. User docs are split between `README.md`, Neovim help in `doc/gui-keymap.txt`, and supplemental Markdown in `docs/`. Utility scripts, including Windows smoke checks, live in `scripts/`.

## Build, Test, and Development Commands
Run `make test` to execute the Plenary test suite headlessly in Neovim. Run `make smoke` on Unix-like systems for plugin load, command registration, demo buffer, and healthcheck smoke coverage. On Windows, use `pwsh -File .\scripts\cli-smoke.ps1` for the equivalent smoke-and-test flow. Validate packaging with `luarocks make gui-keymap.nvim-scm-1.rockspec`.

## Coding Style & Naming Conventions
This repository uses Lua with Stylua and Luacheck. Format with 2-space indentation and keep lines within the configured 120-column width. Prefer double quotes where Stylua selects them automatically. Use snake_case for module filenames and local helpers, and keep public API names aligned with existing command and option names such as `show_welcome` or `GuiKeymapInfo`. Lint the same paths CI checks: `luacheck lua plugin tests` and `stylua --check lua plugin tests`.

## Testing Guidelines
Add or update Plenary specs for every user-visible behavior change, especially mappings, command registration, and integration fallbacks. Name new test files `*_spec.lua` and keep scenarios isolated with explicit setup and teardown, following `tests/gui-keymap/gui-keymap_spec.lua`. Prefer assertions that verify observable Neovim state over internal implementation details.

## Commit & Pull Request Guidelines
Recent history follows Conventional Commit prefixes such as `feat:`, `fix:`, `refactor:`, and scoped chores like `chore(ci):`. Keep commit subjects short and imperative. Pull requests should explain the user-facing change, list test coverage (`make test`, `make smoke`, or `scripts/cli-smoke.ps1`), and include screenshots or terminal output when the change affects docs, health output, or interactive UI surfaces.

## Documentation & Release Notes
When changing commands, options, or behavior, update `README.md` and the relevant files in `docs/`. The docs workflow regenerates `doc/gui-keymap.txt`, so keep Markdown source authoritative and avoid hand-editing generated help unless you are syncing it intentionally.
