## Context

`lua/plugins/markdown.lua` uses two mutually exclusive `cond` functions to load exactly one preview plugin depending on the environment:

```
is_console (no $DISPLAY / $WAYLAND_DISPLAY)
  → glow.nvim loads,         markdown-preview.nvim blocked
  
not is_console (display available)
  → markdown-preview.nvim loads, glow.nvim blocked
```

`after/ftplugin/markdown.lua` routes `,p` through the same `is_console` check at keymap-execution time. The result: in GUI-capable terminals (GNOME Terminal, WSL Terminal with WSLg), glow.nvim is never loaded and `:Glow` is unavailable — even though it is a terminal popup that works perfectly in those environments.

## Goals / Non-Goals

**Goals:**
- Allow `glow.nvim` to load in GUI-capable terminals so `:Glow` is always available
- Add `,pp` keymap that unconditionally calls `Glow` with an executable guard
- Leave `,p` smart-routing completely unchanged

**Non-Goals:**
- Session-level mode toggling or persistent preview preference
- Auto-detecting window fullscreen state
- Changing how `markdown-preview.nvim` loads or behaves
- Supporting `,pp` in pure headless/TTY environments (glow is already the only option there; `,pp` is redundant but harmless)

## Decisions

### Remove `cond` from `glow.nvim` entirely
`glow.nvim` is a terminal floating-window plugin — it has no dependency on a graphical display. The `cond = is_console` restriction was added to keep the two plugins exclusive, but exclusivity is not a technical requirement. Removing the condition lets lazy.nvim load glow in all environments.

*Alternative considered*: Change `cond` to `true` (explicit always-load). Equivalent outcome; removing `cond` is cleaner.

*Alternative considered*: Load glow with `lazy = true` and trigger via command. Not needed — lazy.nvim's `ft = { "markdown" }` already provides filetype-based deferred loading without a cond gate.

### Keep `markdown-preview.nvim` cond unchanged
`markdown-preview.nvim` genuinely requires a browser and a local WebSocket server. It is meaningless (and will error) in a headless environment. The `cond = not is_console` guard stays.

### `,pp` as the forced-popup keymap
`,p` is the existing preview root. Doubling the `p` (`,pp`) is ergonomic, easy to remember ("popup preview"), and doesn't conflict with any existing binding in `after/ftplugin/markdown.lua`. The keymap reuses the existing `executable("glow")` guard pattern already present in the `,p` handler.

### `,p` smart-routing is untouched
The current routing — browser in GUI mode, glow in console mode — continues to serve the common case. No behaviour change means no documentation confusion for existing users.

## Risks / Trade-offs

- **glow loads in GUI mode adding a small startup cost** → negligible; `ft = { "markdown" }` defers load until a markdown buffer is opened
- **Two popup-adjacent keymaps in GUI mode** (`,p` goes to browser, `,pp` goes to glow) → mitigated by clear cheatsheet descriptions; this is the intended design
- **glow binary absent in GUI environment** → guarded by `vim.fn.executable("glow")` check with a `vim.notify` warning, same pattern as existing `,p` handler
