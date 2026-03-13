# gui-keymap.nvim Implementation Draft

Status: draft  
Purpose: convert the architecture review into an implementation direction without overengineering the plugin.

This draft is intentionally pragmatic.

The goal is not to make `gui-keymap.nvim` look like `lazy.nvim`, `telescope.nvim`, or `gitsigns.nvim`.
The goal is to keep it lightweight, dependable, and ecosystem-compatible while staying easy to maintain.

---

## Core Position

`gui-keymap.nvim` should remain:

- a lightweight Neovim plugin
- focused on GUI-style keybindings and transition UX
- modular enough to stay maintainable
- simple enough that future contributors can understand it quickly

It should not become:

- a full editor framework
- a plugin manager style runtime
- a large event-dispatch system
- a deeply abstracted architecture that solves problems this plugin does not actually have

The standard is:

- keep the architecture clean
- keep runtime cheap
- keep behavior reliable
- keep integrations optional

---

## Current Architectural Position

The current repository already has many production-grade traits:

- standard Neovim plugin layout
- modular Lua organization
- help docs and long-form docs
- config/state separation
- diagnostics and health reporting
- tests and smoke checks
- CI, linting, formatting, and release packaging

This means the plugin is no longer a “personal config extracted into a repo”.
It already behaves like a real ecosystem plugin.

The remaining work is mostly about tightening boundaries and simplifying behavior where complexity has started to accumulate.

---

## Architectural Principles For This Plugin

These principles should guide implementation work.

### 1. Keep the bootstrap thin

The loader layer should do only what is necessary for plugin usability.

That means:

- register user-facing commands
- ensure setup happens in a predictable way
- avoid expensive logic in `plugin/`

This plugin may keep a convenience auto-setup path if needed for local-path and non-Lazy installs, but that path should remain intentionally small and predictable.

### 2. Keep modules responsibility-based

Modules should stay split by behavior, not by arbitrary file size.

Current module boundaries are mostly correct:

- config
- state
- keymaps
- clipboard
- hints
- onboarding
- demo
- diagnostics
- health
- commands

This is the right level of modularity for this plugin class.

### 3. Prefer direct Vim/Neovim equivalents over clever wrappers

For stable core mappings:

- direct mappings are better than extra orchestration
- function wrappers should only exist when side effects are genuinely required

This plugin’s main job is to map GUI-style keys to reliable Neovim actions.
That favors simple, explicit execution paths.

### 4. Prefer capability detection over dependency assumptions

Integrations like Yanky or which-key should remain:

- optional
- capability-driven
- safe when absent
- safe when installed but not loaded yet

The plugin should not assume eager loading or a single plugin manager.

### 5. Event-driven where useful, not everywhere

This plugin does not need a large event system.

Use events only where they solve a real lifecycle problem:

- startup timing
- lazy-load enforcement
- welcome/onboarding timing
- optional refresh points

Do not add event machinery just to resemble larger plugins.

### 6. Diagnostics should expose reality, not guesses

End-user diagnostics should continue to answer:

- what mappings were requested
- what actually got applied
- what was skipped
- what integrations are active
- what fallback behavior is in effect

This is especially important for a plugin that competes with user keymaps, distributions, and lazy-loaded integrations.

---

## What Mature Neovim Plugins Do That Matters Here

Based on the comparative review, the useful patterns to adopt are:

- thin loader, logic under `lua/`
- dedicated config merge/validation
- reusable utility/state layer
- tests that run in headless Neovim
- CI for formatting, linting, and runtime checks
- explicit docs and Vim help
- optional integrations that fail safely

The patterns that are less relevant here are:

- deep manager layers
- async job frameworks
- redraw pipelines
- cache-heavy subsystems
- complex dispatch architecture

Those are appropriate for plugins that manage rendering, git state, search pipelines, or large async workflows.
They are not necessary for `gui-keymap.nvim`.

---

## Implementation Direction

This is the implementation direction implied by the analysis.
It is not a step-by-step patch plan yet.

### A. Preserve the current lightweight shape

The plugin should stay within this structural envelope:

- `plugin/` for bootstrap only
- `lua/gui-keymap/` for all logic
- `doc/` for Vim help
- `docs/` for long-form manual/docs site
- `tests/` for headless runtime verification

No new architectural layer should be added unless it removes repeated complexity rather than adding another abstraction.

### B. Treat core keymaps as the stable contract

The plugin’s core public value is the keymap behavior itself.

That means:

- keymap behavior must stay closest to native Vim equivalents
- regressions in key semantics matter more than internal neatness
- input-mode behavior must be tested like a public interface

Core keymaps are the product.
Everything else supports that.

### C. Treat integrations as optional adapters

Yanky, which-key, and future optional integrations should remain adapters around core behavior.

They should never become the core runtime model.

The plugin must still work correctly when:

- Lazy is absent
- Yanky is absent
- which-key is absent
- user config is partial or empty
- plugin is loaded by packer, vim-plug, native packages, or direct `setup()`

### D. Keep startup work intentionally small

The plugin should continue to avoid:

- expensive startup probes
- repeated heavyweight detection on every keypress
- unnecessary re-registration loops
- overuse of notifications during startup

Where state must be discovered, the work should be:

- cached
- explicit
- reset on refresh when needed

### E. Keep documentation source-of-truth boundaries clear

There are three documentation surfaces:

- `README.md`
- `docs/`
- `doc/gui-keymap.txt`

They should remain distinct in role:

- README: discovery and quick-start
- docs: detailed manual and troubleshooting
- doc: `:help` surface

The plugin should not rely on users reverse-engineering behavior from source files.

---

## Specific Technical Refinements

These technical goals should be prioritized during implementation to reduce complexity and improve maintainability.

### 1. Declarative Registry Builder
The current `keymaps.lua` registry is verbose and repetitive. Implementation should move toward a declarative, template-based approach that groups mappings by feature and uses helper functions to generate repetitive mode entries (Normal, Insert, Visual). This will reduce file size and make the registry easier to audit.

### 2. Dedicated Integration Layer
Logic for optional integrations like `yanky.nvim` and `which-key.nvim` should be moved out of core modules (`keymaps.lua`, `clipboard.lua`, `utils.lua`) into a dedicated integration adapter layer. This enforces the "Integrations as Optional Adapters" principle and keeps core logic focused on native Neovim behavior.

### 3. Lifecycle Boundary Tightening
The "deferred enforcement" pattern (multiple `defer_fn` calls) is a workaround for lazy-loading race conditions. Implementation should aim for a more robust, event-driven approach using a focused set of `autocmds` (e.g., `User LazyDone`, `VeryLazy`) to trigger a single, reliable re-application of mappings.

### 4. State/Utility Separation
The boundary between `state.lua` and `utils.lua` should be sharpened. `utils.lua` should remain a library of pure, side-effect-free helper functions. Logic that modifies or manages plugin state (like integration status tracking) should be moved into `state.lua` or the integration adapters.

### 5. Registry Integrity & Integration Testing
- **Integrity:** Add tests to validate the `M.registry` for duplicate `lhs` assignments, invalid modes, or missing descriptions.
- **Mocks:** Use mocks to test optional integration paths, ensuring the plugin fails safely when dependencies are absent or partially loaded.

### 6. Documentation Synchronization
To prevent documentation drift, consider a simple script to automatically generate feature tables in `README.md` and Vim help docs directly from the source-of-truth registry in `keymaps.lua`.

### 7. Extensible Profile Architecture
To support future "GUI Presets" (VSCode, JetBrains, etc.), the registry architecture should allow filtering or extending the core set of mappings via profile modules rather than hardcoding new presets into the main registry.

### 8. Transition Mode Hook
Reserve a place in the mapping execution logic for a "transition interceptor." This will allow future features (like "Transition Mode" hints or confirmations) to be added without modifying every mapping's implementation.

---

## Engineering Risks To Keep In View

These are the risks that matter most for this plugin class.

### 1. Input semantics drift

This plugin is highly sensitive to small changes in:

- mode coverage
- termcode handling
- mapping execution strategy
- selection semantics

The code can remain “clean” and still break real usage if key execution changes subtly.

### 2. Lazy-loading ambiguity

Optional integrations can be:

- not installed
- installed but not loaded
- loaded but not ready
- fully ready

Architecturally, the plugin must continue to distinguish these states cleanly.

### 3. Bootstrap ambiguity

The plugin should behave consistently whether it is loaded:

- by plugin manager automatic `opts`
- by direct `require("gui-keymap").setup()`
- from local path specs
- from startup plugin discovery

This is one of the most important ecosystem-compatibility concerns.

### 4. Documentation workflow drift

The repo currently has both:

- authored documentation
- generated help documentation

This is fine, but only if the source-of-truth boundaries stay explicit.

### 5. Test realism gap

Headless tests are necessary, but for this plugin they are not sufficient by themselves.

The highest-risk failures involve:

- interactive key handling
- selection behavior
- terminal-specific keycodes
- lazy-loaded plugin interaction

The architecture should assume that these areas need stronger contract-style testing than ordinary pure-Lua modules.

---

## Lightweight Standard For Approval

Any future implementation derived from this draft should satisfy all of the following:

- keeps the plugin easy to understand
- does not introduce framework-like architecture without need
- improves reliability or maintainability measurably
- preserves compatibility across common plugin managers
- keeps optional integrations optional
- does not make startup or runtime behavior heavier without clear benefit
- improves the plugin as a user-facing product, not just as internal code structure

If a proposed change does not meet that bar, it should not be implemented.

---

## Draft Conclusion

The architectural review does not suggest that `gui-keymap.nvim` needs a large redesign.

It suggests something narrower:

- keep the current modular structure
- protect the lightweight nature of the plugin
- tighten lifecycle boundaries
- keep the loader predictable
- keep integrations capability-based
- keep diagnostics honest
- treat keymap behavior as the main public contract

That is the right direction for a plugin from a new maintainer making strong claims:
not “more architecture”, but architecture disciplined enough that the plugin earns trust.

---

## Implementation Instructions

This section defines how implementation work should be executed after the draft is approved.

The aim is to keep the work controlled, testable, and lightweight.

### 1. Protect the current state before implementation

Before any implementation work begins:

- fetch remote state
- pull the current branch cleanly
- commit the current local state as a checkpoint

This checkpoint exists to make rollback easy if a refactor or behavior change introduces regressions.

### 2. Work in small, isolated changes

Implementation should be split into small logical units, not one large rewrite.

Each unit should target one category only, for example:

- loader/bootstrap behavior
- integration detection
- diagnostics/reporting
- documentation workflow
- tests

This keeps failures attributable and rollback simple.

### 3. Test-first for bug work

If the work is driven by a bug or regression:

- first add or update a test that reproduces it
- then change the implementation
- then prove the fix with the passing test

This is mandatory for behavior-sensitive paths such as:

- keymap execution
- mode transitions
- selection behavior
- clipboard integration
- lazy-loading interactions

### 4. Prefer simplification over abstraction

When touching implementation:

- remove indirection where it is not needed
- keep direct Vim-equivalent mappings where possible
- only use callback wrappers when they are required for real behavior

Do not introduce new layers unless they reduce real duplication or ambiguity.

### 5. Preserve module boundaries

Implementation should stay within the current responsibility model.

Expected ownership:

- `plugin/gui-keymap.lua`
  - bootstrap only
- `lua/gui-keymap/init.lua`
  - lifecycle entrypoint
- `config.lua`
  - option merge and validation
- `state.lua`
  - runtime state only
- `keymaps.lua`
  - keymap registry and application
- `clipboard.lua`
  - clipboard and Yanky integration behavior
- `hints.lua`
  - hint logic
- `info.lua`
  - diagnostics surfaces
- `health.lua`
  - health reporting
- `demo.lua`
  - safe demo buffer
- `onboard.lua`
  - welcome/update onboarding
- `commands.lua`
  - command registration

Implementation should not blur these boundaries unless there is a compelling simplification reason.

### 6. Keep integrations optional and capability-based

For optional plugins such as Yanky and which-key:

- detect capability, not just package presence
- distinguish installed vs loaded vs ready where needed
- fall back safely when unavailable
- avoid repeated heavy probes on hot paths

No implementation should assume:

- Lazy is always installed
- optional plugins are eagerly loaded
- one plugin manager controls all user setups

### 7. Keep runtime cost low

Implementation work should avoid:

- expensive startup probes
- polling loops
- repeated unnecessary remaps
- repeated integration discovery on every keypress

When state must be discovered:

- cache it
- expose it via diagnostics
- invalidate/reset it on explicit refresh where appropriate

### 8. Preserve user-facing contracts

The following are public contracts and should be treated as such:

- supported keymaps and their mode behavior
- setup defaults
- commands
- health output intent
- diagnostics intent
- optional integration fallback behavior

If implementation changes any of these, the change must be deliberate and reflected in:

- tests
- docs
- help text

### 9. Validate in three layers

Every meaningful implementation change should be checked in three layers:

1. static/style checks
   - formatting
   - linting

2. headless runtime checks
   - plenary tests
   - smoke checks

3. targeted real-behavior validation
   - only for paths where headless tests are known to be insufficient
   - especially key input, selection, and lazy integration behavior

The point is to reduce manual validation scope, not eliminate engineering rigor.

### 10. Commit strategy

For implementation work:

- commit after a major feature change
- commit after a major bug fix is proven by tests
- commit after major docs/CI/package changes

Push only after approval.

This keeps the history navigable and makes it easier to bisect regressions.

### 11. Remove the draft after implementation is complete

Once the approved implementation is fully applied and committed:

- remove `IMPLEMENTATION_DRAFT.md`

The draft is a temporary planning artifact, not a permanent repository document.

### 12. Standard for stopping

Implementation should stop when:

- the approved draft items are completed
- tests pass
- docs match behavior
- the working tree is clean except for intended changes

Implementation should not continue into speculative improvements beyond the approved draft.
