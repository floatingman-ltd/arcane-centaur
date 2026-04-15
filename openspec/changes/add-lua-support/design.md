## Context

The config currently supports Lua via Treesitter (syntax highlighting + indentation) but has no LSP integration, no formatter, and no filetype-specific editor settings. Lua is the primary language used to write and extend this Neovim configuration. The existing language support pattern — used for F#, Haskell, Common Lisp, and others — consists of an LSP entry in `lua/config/lsp.lua`, a formatter entry in `lua/plugins/conform.lua`, and a filetype plugin at `after/ftplugin/<lang>.lua`.

## Goals / Non-Goals

**Goals:**
- Add `lua_ls` LSP configuration following the same pattern as all other servers in `lua/config/lsp.lua`
- Add `stylua` format-on-save via `conform.nvim`, consistent with other filetypes
- Add `after/ftplugin/lua.lua` with 2-space indent settings matching Neovim's own Lua style

**Non-Goals:**
- Adding a Lua REPL (no clear lightweight option integrates with the current iron.nvim / Conjure approach for Lua)
- Adding snippets or a dedicated debugging adapter
- Configuring `lua_ls` to understand the Neovim runtime API (that requires a more complex `settings` block and is a separate change)

## Decisions

### `lua_ls` as the LSP server
`lua_ls` (formerly sumneko/lua-language-server) is the only actively maintained, full-featured Lua language server. No viable alternatives exist.

### `stylua` as the formatter
`stylua` is the de-facto standard Lua formatter (opinionated, fast, zero-config). Alternatives like `luafmt` are unmaintained. `lsp_format = "prefer"` is not viable because `lua_ls` formatting is rarely enabled. Using `{ "stylua" }` directly is the right choice.

### Extend `conform.nvim`'s `ft` guard for lazy loading
Adding `"lua"` to the `ft` list ensures conform is loaded for Lua files without changing the loader structure.

### No `localleader` keymaps in `after/ftplugin/lua.lua`
Other filetypes define `<localleader>` REPL and eval keymaps. Since no REPL is being added, the ftplugin only sets indent options. A comment placeholder will indicate where to add keymaps if a REPL is added later.

## Risks / Trade-offs

- [Risk] `lua-language-server` binary not on `$PATH` → LSP silently does nothing; no crash. Mitigation: document the prerequisite in `docs/guides/lua.md`.
- [Risk] `stylua` not on `$PATH` → conform logs a warning on save. Mitigation: document in the same guide.
- [Trade-off] No `lua_ls` Neovim API awareness means diagnostics may flag Neovim globals (`vim.*`). Mitigation: acceptable for now; a follow-up change can add `settings.Lua.workspace.library`.
