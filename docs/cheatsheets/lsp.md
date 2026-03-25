# LSP Cheatsheet

**Leader** = `Space`

→ Back to [main cheatsheet](index.md)

## LSP Keybindings (all LSP-enabled buffers)

These keymaps are active in any buffer where an LSP server has attached
(F#, Markdown, Haskell).

| Keys | Mode | Action |
|---|---|---|
| `gd` | Normal | Go to definition |
| `K` | Normal | Hover documentation |
| `gr` | Normal | Find all references |
| `<leader>rn` | Normal | Rename symbol |
| `<leader>ca` | Normal | Code action |
| `<leader>e` | Normal | Show diagnostic float |
| `[d` | Normal | Jump to previous diagnostic |
| `]d` | Normal | Jump to next diagnostic |

## Configured LSP Servers

| Server | Language | Install |
|---|---|---|
| `fsautocomplete` | F# | `dotnet tool install -g fsautocomplete` |
| `marksman` | Markdown | `sudo apt install marksman` |
| `haskell-language-server` | Haskell | `ghcup install hls` (managed by haskell-tools.nvim) |

---

*Keymaps defined in `lua/config/lsp.lua` via `LspAttach` autocmd.*
