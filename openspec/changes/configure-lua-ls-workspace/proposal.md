## Why

`lua_ls` is registered with no `settings` at all (`lua/config/lsp.lua:84`), so it analyses this configuration as plain Lua with no knowledge of Neovim. Every reference to `vim` is reported as `Undefined global`.

Measured across the tree on 2026-09-11: **661 diagnostics in 62 files, 659 of them `Undefined global`**. That is 99.7% noise, and it is not cosmetic — it is how a genuine `unpack` deprecation nearly went unnoticed on 2026-09-08. A diagnostics list nobody can read is the same as no diagnostics list.

Configuring the workspace drops that to **8 — every one of them a real finding**, six of which were previously buried.

## What Changes

- **Give `lua_ls` a `settings` table** in `lua/config/lsp.lua`: `runtime.version = "LuaJIT"`, `diagnostics.globals = { "vim", "pandoc" }`, `workspace.library = { $VIMRUNTIME }` with `checkThirdParty = false`, and telemetry off.
- **Record the six newly-surfaced findings** in `recommendations/ideas.md` so unburying them is not immediately followed by re-burying them.

Not breaking. No new plugin, no new binary, no change to which servers attach or to any keymap.

Two findings from grounding shaped the settings:

- **`vim` is not the only false positive.** Eighteen `Undefined global` reports survive a `vim`-only fix, and all eighteen are `pandoc`, in `docker/md2pdf/mermaid-filter.lua`, `docker/md2pdf/plantuml-filter.lua` and `scripts/confluence_filter.lua`. Those are Pandoc Lua filters — a different host program with a different injected global. Silencing `vim` alone would leave the tree looking 97% clean instead of clean, which is precisely the state that trains people to ignore the list.
- **`diagnostics.globals` alone would do the job, and is the wrong fix.** Adding `"vim"` to the globals list silences the reports without teaching `lua_ls` anything. Adding `$VIMRUNTIME` to `workspace.library` instead gives it the real API definitions, which is what surfaces deprecations and type errors — the entire point of the exercise. Both are set; the library is the part that earns its place.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `lua-lsp`: gains a requirement that the server is configured for the Neovim runtime, so that Lua diagnostics are usable. The existing requirement about registration, `on_attach` and keymaps is unchanged.

## Impact

| Area | Change |
|---|---|
| `lua/config/lsp.lua` | `lua_ls` registration gains a `settings` table |
| `recommendations/ideas.md` | the six surfaced findings recorded as follow-up |
| `openspec/TEST_PLAN.md` | new `## Change · configure-lua-ls-workspace` section |

**No new dependencies.** `lua-language-server` is already required by this capability and already installed (3.18.2-dev). `$VIMRUNTIME` is supplied by Neovim itself.

**Deliberately out of scope: fixing the six findings this surfaces.** Four are missing nil checks in `lua/config/http_preview.lua`, one is a type mismatch in `lua/config/claude_cli.lua`, one is a `uv_tcp_t`/`uv_stream_t` assignment. They are real, they are unrelated to each other, and bundling them would make this change about six small bugs instead of about the configuration that hid them. They are recorded in `recommendations/ideas.md` instead.

**Runtime behaviour changes, so manual validation in a live session is required** before push. The headless scan is good evidence of the counts but says nothing about how the list reads in a real buffer.
