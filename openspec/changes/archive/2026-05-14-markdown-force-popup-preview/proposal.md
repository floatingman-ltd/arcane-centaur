## Why

In GUI-capable terminals (GNOME Terminal, WSL Terminal), `glow.nvim` is currently blocked from loading because the config treats display availability as an exclusive switch between browser and popup preview. Users who work full-screen in a terminal — without wanting to context-switch to a browser — have no way to access the in-editor popup preview. Adding an explicit `,pp` keymap and relaxing the `glow.nvim` load condition gives users direct control without changing existing smart-routing behaviour.

## What Changes

- Remove the `cond = is_console` restriction on `glow.nvim` so it loads in all environments (not just headless/console)
- Keep `markdown-preview.nvim` load condition unchanged (`cond = not is_console`)
- Add a `,pp` keymap in `after/ftplugin/markdown.lua` that always invokes `Glow`, regardless of environment
- `,p` smart-routing behaviour is unchanged — browser in GUI mode, glow in console mode
- Document `,pp` in `docs/cheatsheets/markdown.md` and `docs/guides/markdown.md`

## Capabilities

### New Capabilities

- `markdown-popup-preview`: A dedicated keymap (`,pp`) that unconditionally opens the glow.nvim floating popup preview, available in any terminal environment including GUI-capable ones.

### Modified Capabilities

<!-- none — the smart ,p routing behaviour is not changing at the requirement level -->

## Impact

- **`lua/plugins/markdown.lua`**: `glow.nvim` `cond` changed from `is_console` to always-load (or removed)
- **`after/ftplugin/markdown.lua`**: new `,pp` keymap added alongside existing `,p`
- **`docs/cheatsheets/markdown.md`**: new row in the preview keybindings table
- **`docs/guides/markdown.md`**: `,pp` added to keybindings summary and "Choosing the Right Preview Tool" table
- **No breaking changes** — `,p` routing is unchanged; existing muscle memory is preserved
- **Dependency**: `glow` binary must be installed; the keymap already guards against this with `vim.fn.executable("glow")`
