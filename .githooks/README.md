# Git Hooks

This repo ships a lightweight `pre-commit` hook under `.githooks/`.

It checks:

- `npx @johnnymorganz/stylua-bin --check lua plugin tests`
- `luacheck lua plugin tests`

On Windows, the hook prefers `luacheck` through WSL when `wsl` is available.

Enable it once per clone:

```bash
git config core.hooksPath .githooks
```
