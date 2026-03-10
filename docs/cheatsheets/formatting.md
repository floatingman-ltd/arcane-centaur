# Formatting Cheatsheet (conform.nvim)

**Leader** = `Space`

→ Back to [main cheatsheet](index.md)

## Format Keybinding

| Keys | Mode | Action |
|---|---|---|
| `<leader>f` | Normal / Visual | Format buffer or selection (LSP-preferred) |

## Format-on-Save

Format-on-save is enabled automatically for the following filetypes:

| Filetype | Formatter |
|---|---|
| Lisp | LSP (`cl_lsp`) |
| Clojure | LSP |
| Scheme | LSP |
| Fennel | LSP |
| F# | LSP (`fsautocomplete`) |

The formatter runs with a 2-second timeout on save. To disable format-on-save
for a session, use `:ConformDisable`.

---

*Configured in `lua/plugins/conform.lua`.*
