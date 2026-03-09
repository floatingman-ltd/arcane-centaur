# Neovim Keybinding Cheat Sheet

**Leader** = `Space` · **LocalLeader** = `,` (in all language buffers)

---

## Navigation & Splits

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

---

## File Tree (nvim-tree)

| Keys | Mode | Action |
|---|---|---|
| `<leader>n` or `Ctrl-n` | Normal | Open file tree |
| `Ctrl-t` | Normal | Toggle file tree |
| `Ctrl-f` | Normal | Reveal current file in tree |

---

## Terminal

| Keys | Mode | Action |
|---|---|---|
| `<leader>t` | Normal | Toggle terminal split |
| `Esc` | Terminal | Exit terminal insert mode |

---

## Editing (Visual / Cross-mode)

| Keys | Mode | Action |
|---|---|---|
| `<` | Visual | Outdent selection and reselect |
| `>` | Visual | Indent selection and reselect |
| `<Tab>` | Visual | Indent selection |
| `<S-Tab>` | Visual | Outdent selection |
| `Shift-↓` | Visual | Move selected block down |
| `Shift-↑` | Visual | Move selected block up |
| `<leader>p` | Visual | Paste without overwriting clipboard |

---

## Comments (vim-commentary)

| Keys | Mode | Action |
|---|---|---|
| `gcc` | Normal | Toggle line comment |
| `gc` | Visual | Toggle comment on selection |
| `Ctrl-/` | Normal | Toggle comment (`:Commentary`) |

---

## Formatting (conform.nvim)

| Keys | Mode | Action |
|---|---|---|
| `<leader>f` | Normal / Visual | Format buffer or selection (LSP-preferred) |

*Format-on-save is enabled automatically for Lisp, Clojure, Scheme, Fennel, and F# buffers.*

---

## Copilot (Insert / Normal)

| Keys | Mode | Action |
|---|---|---|
| `Ctrl-j` | Insert | Accept full inline suggestion |
| `Alt-f` | Insert | Accept next word of suggestion |
| `<leader>c` | Normal | Focus CopilotChat window |

---

## LSP (all LSP-enabled buffers)

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

## Auto-Completion (nvim-cmp)

| Keys | Mode | Action |
|---|---|---|
| `Alt-Space` | Insert | Open completion menu |
| `j` | Insert | Select next suggestion (menu open) |
| `k` | Insert | Select previous suggestion (menu open) |
| `Enter` | Insert | Confirm highlighted suggestion |
| `Ctrl-e` | Insert | Dismiss completion menu |
| `Ctrl-f` | Insert | Scroll docs preview down |
| `Ctrl-b` | Insert | Scroll docs preview up |

---

## Haskell (haskell-tools · `after/ftplugin/haskell.lua`)

| Keys | Mode | Action |
|---|---|---|
| `<leader>rr` | Normal | Toggle GHCi REPL for package |
| `<leader>rf` | Normal | Toggle GHCi REPL for current file |
| `<leader>rq` | Normal | Quit GHCi REPL |
| `Space-cl` | Normal | Run code lenses |
| `Space-hs` | Normal | Hoogle search for type under cursor |
| `Space-ea` | Normal | Evaluate all code snippets |

---

## F# REPL — iron.nvim (`lua/plugins/fsharp.lua`)

LocalLeader is `,` in F# buffers.

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

## Lisp / Clojure / Scheme — Conjure (`lua/plugins/lisp.lua`)

LocalLeader is `,` in Lisp/Clojure/Scheme/Fennel buffers.

### Evaluation

| Keys | Action |
|---|---|
| `,ee` | Evaluate form under cursor |
| `,er` | Evaluate root (outermost) form |
| `,eb` | Evaluate entire buffer |
| `,e!` | Replace form with its evaluated result |
| `,cc` | Connect to REPL manually |

### REPL Log

| Keys | Action |
|---|---|
| `,lv` | Open REPL log in vertical split |
| `,ls` | Open REPL log in horizontal split |
| `,lq` | Close REPL log window |

---

## Structural Editing — vim-sexp (Lisp / Clojure / Scheme)

| Keys | Action |
|---|---|
| `>)` | Slurp forward — pull next element into form |
| `<)` | Barf forward — push last element out of form |
| `<(` | Slurp backward |
| `>(` | Barf backward |
| `>f` | Move current form right among siblings |
| `<f` | Move current form left among siblings |
| `>e` | Move current element right |
| `<e` | Move current element left |
| `cse(` or `cse)` | Surround element with `()` |
| `cse[` or `cse]` | Surround element with `[]` |
| `dsf` | Delete surrounding function call (splice) |

---

## Markdown (`after/ftplugin/markdown.lua`)

LocalLeader is `,` in Markdown buffers.

| Keys | Action |
|---|---|
| `,p` | Toggle Markdown browser preview |
| `,mp` | MARP: open slide in preview server |
| `,mx` | MARP: export to PowerPoint (`.pptx`) |
| `,mh` | MARP: export to HTML |
| `,md` | MARP: export to PDF |

---

## PlantUML (`after/ftplugin/plantuml.lua`)

LocalLeader is `,` in PlantUML buffers.

| Keys | Action |
|---|---|
| `,p` | Preview diagram in browser (via Docker server) |
