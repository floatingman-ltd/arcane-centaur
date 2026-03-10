# Navigation & Terminal Cheatsheet

**Leader** = `Space`

→ Back to [main cheatsheet](index.md)

## Window / Split Navigation

| Keys | Mode | Action |
|---|---|---|
| `Ctrl-h` | Normal | Move to left split |
| `Ctrl-j` | Normal | Move to split below |
| `Ctrl-k` | Normal | Move to split above |
| `Ctrl-l` | Normal | Move to right split |
| `Ctrl-↑` | Normal | Shrink split height |
| `Ctrl-↓` | Normal | Grow split height |
| `Ctrl-←` | Normal | Shrink split width |
| `Ctrl-→` | Normal | Grow split width |

## Terminal

| Keys | Mode | Action |
|---|---|---|
| `<leader>t` | Normal | Toggle terminal split (15-line split at bottom) |
| `Esc` | Terminal | Exit terminal insert mode |

The terminal toggle reuses the same terminal buffer across open/close cycles.
Press `<C-k>` after `Esc` to jump back to the editor window.

---

*Defined in `lua/keymaps.lua`.*
