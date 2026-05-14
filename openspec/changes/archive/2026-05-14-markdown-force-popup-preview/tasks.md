## 1. Plugin Configuration

- [x] 1.1 Remove the `cond` from `glow.nvim` in `lua/plugins/markdown.lua` so it loads in all environments

## 2. Keymap

- [x] 2.1 Add `,pp` keymap to `after/ftplugin/markdown.lua` that unconditionally calls `Glow` with a `vim.fn.executable("glow")` guard and a warning notify if absent

## 3. Validation

- [x] 3.1 Run Lua syntax check: `find . -name '*.lua' -print0 | xargs -0 luac -p`
- [x] 3.2 In a GUI terminal, open a `.md` file and confirm `:Glow` is available (glow.nvim loaded)
- [x] 3.3 Press `,pp` — confirm glow popup opens
- [x] 3.4 Press `,p` — confirm browser preview still opens (smart routing unchanged)

## 4. Documentation

- [x] 4.1 Add `,pp` row to the preview table in `docs/cheatsheets/markdown.md`
- [x] 4.2 Add `,pp` to the keybindings summary and "Choosing the Right Preview Tool" table in `docs/guides/markdown.md`
