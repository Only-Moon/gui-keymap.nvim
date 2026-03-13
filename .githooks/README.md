# Git Hooks

This repo ships a lightweight `pre-commit` hook under `.githooks/`.

It checks:

- `npx @johnnymorganz/stylua-bin --check lua plugin tests`
- `luacheck lua plugin tests`

The hook runs `luacheck` in the first available environment.

Enable it once per clone:

```bash
git config core.hooksPath .githooks
```
