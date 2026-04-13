# .NET / C# Cheatsheet (Roslyn + iron.nvim)

**LocalLeader** = `,` in `.cs` and `.fsx`/`.fs` buffers.

---

## C# REPL — iron.nvim + csharprepl

| Keys | Mode | Action |
|---|---|---|
| `,sl` | Normal | Send current line to REPL |
| `,sc` | Normal / Visual | Send motion or selection to REPL |
| `,sp` | Normal | Send current paragraph to REPL |
| `,sf` | Normal | Send entire file to REPL |
| `,s<CR>` | Normal | Send carriage return to REPL |
| `,si` | Normal | Interrupt REPL |
| `,sq` | Normal | Quit / exit REPL |
| `,cl` | Normal | Clear REPL output |

---

## F# REPL — iron.nvim + dotnet fsi

| Keys | Mode | Action |
|---|---|---|
| `,sl` | Normal | Send current line to REPL |
| `,sc` | Normal / Visual | Send motion or selection to REPL |
| `,sp` | Normal | Send current paragraph to REPL |
| `,sf` | Normal | Send entire file to REPL |
| `,s<CR>` | Normal | Send carriage return to REPL |
| `,si` | Normal | Interrupt REPL |
| `,sq` | Normal | Quit / exit REPL |
| `,cl` | Normal | Clear REPL output |

---

## LSP (Roslyn — C# buffers only)

| Keys | Mode | Action |
|---|---|---|
| `gd` | Normal | Go to definition |
| `K` | Normal | Hover documentation |
| `gr` | Normal | Find references |
| `<leader>rn` | Normal | Rename symbol |
| `<leader>ca` | Normal | Code action |
| `<leader>e` | Normal | Show diagnostic float |
| `[d` | Normal | Previous diagnostic |
| `]d` | Normal | Next diagnostic |

---

## Roslyn Commands

| Command | Action |
|---|---|
| `:Roslyn target` | Switch solution target (when multiple `.sln` files exist) |

→ [Full guide](../guides/dotnet.md)
