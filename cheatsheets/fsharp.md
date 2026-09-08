# F# / C#

**LocalLeader** = `,`

---

## iron.nvim — REPL

| Key | Action |
|-----|--------|
| `,sl` | Send current line to REPL |
| `,sc` | Send motion or selection to REPL |
| `,sp` | Send current paragraph to REPL |
| `,sf` | Send entire file to REPL |
| `,s<CR>` | Send carriage return to REPL |
| `,si` | Interrupt REPL |
| `,sq` | Quit / exit REPL |
| `,cl` | Clear REPL output |

---

## LSP (fsautocomplete / Roslyn)

Standard LSP keys apply — see core cheatsheet.

> **F#** REPL: `dotnet fsi --stdin` · **C#** REPL: `csharprepl`

---

## Indentation

From the editor (`indent/fsharp.vim`, vendored), **not** the language server — so it works with `fsautocomplete` absent.

| Key | Action |
|-----|--------|
| `<CR>` | Indents the body after `=`, `->`, `then`, `else`, or a `match` arm |
| `==` | Reindent the current line |
| `>>` / `<<` | Shift line right / left by `shiftwidth` (4) |
| `=` (operator) | Reindent a motion or selection |
| `gcc` / `gc` | Comment a line / motion with `//` (was broken — F# had no `commentstring`) |

Whole-file tidying is Fantomas' job, via format-on-save. Note that only works inside a project — a standalone `.fsx` resolves options unreliably.

## GUIDES

- [1] dotnet-fsi — Start F# interactive REPL workflow
