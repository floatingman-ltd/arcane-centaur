# Haskell Cheatsheet (haskell-tools.nvim)

**Leader** = `Space`

→ Back to [main cheatsheet](index.md) · Full guide: [../guides/haskell.md](../guides/haskell.md)

## GHCi REPL

| Keys | Mode | Action |
|---|---|---|
| `<leader>rr` | Normal | Toggle GHCi REPL for the current package |
| `<leader>rf` | Normal | Toggle GHCi REPL for the current file |
| `<leader>rq` | Normal | Quit the GHCi REPL |

## haskell-tools Extras

| Keys | Mode | Action |
|---|---|---|
| `Space-cl` | Normal | Run code lenses (haskell-language-server) |
| `Space-hs` | Normal | Hoogle search for type under cursor |
| `Space-ea` | Normal | Evaluate all code snippets in the buffer |

## LSP (haskell-language-server)

haskell-tools manages the HLS connection automatically. The standard LSP keys
(`gd`, `K`, `gr`, `<leader>rn`, `<leader>ca`, `<leader>e`, `[d`/`]d`) are
active in Haskell buffers — see [lsp.md](lsp.md).

---

*Keymaps defined in `after/ftplugin/haskell.lua`. Plugin configured in `lua/plugins/` (haskell-tools.nvim).*
