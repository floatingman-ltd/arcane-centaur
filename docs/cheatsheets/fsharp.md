# F# Cheatsheet (iron.nvim)

**LocalLeader** = `,` in F# buffers

→ Back to [main cheatsheet](index.md) · Full guide: [../guides/fsharp.md](../guides/fsharp.md)

## REPL Interaction (dotnet fsi)

The REPL opens as a horizontal split at the bottom (40% height).

| Keys | Mode | Action |
|---|---|---|
| `,sl` | Normal | Send current line to REPL |
| `,sc` | Normal / Visual | Send motion or visual selection to REPL |
| `,sp` | Normal | Send current paragraph to REPL |
| `,sf` | Normal | Send entire file to REPL |
| `,s<CR>` | Normal | Send a carriage return to REPL |
| `,si` | Normal | Interrupt the REPL |
| `,sq` | Normal | Quit / exit the REPL |
| `,cl` | Normal | Clear the REPL output buffer |

## LSP (fsautocomplete)

Standard LSP keys are active in F# buffers — see [lsp.md](lsp.md).
Format-on-save is handled by conform.nvim — see [formatting.md](formatting.md).

---

*REPL keymaps configured in `lua/plugins/fsharp.lua`. LocalLeader set in `after/ftplugin/fsharp.lua`.*
