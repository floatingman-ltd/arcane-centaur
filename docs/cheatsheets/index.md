# Neovim Keybinding Cheat Sheet

**Leader** = `Space` · **LocalLeader** = `,` (in all language buffers)

## Plugin Cheatsheets

| Plugin / Area | Cheatsheet |
|---|---|
| Auto-Completion (nvim-cmp) | [completion.md](completion.md) |
| Comments (vim-commentary) | [comments.md](comments.md) |
| F# REPL (iron.nvim) | [fsharp.md](fsharp.md) |
| File Tree (nvim-tree) | [file-tree.md](file-tree.md) |
| Formatting (conform.nvim) | [formatting.md](formatting.md) |
| Fuzzy Finder (fzf-lua) | [fzf.md](fzf.md) |
| Git (vim-fugitive + gitsigns) | [git.md](git.md) |
| GitHub Copilot | [copilot.md](copilot.md) |
| Haskell (haskell-tools) | [haskell.md](haskell.md) |
| HTML Live Preview (Bracey) | [html.md](html.md) |
| Lisp / Clojure / Scheme (Conjure + vim-sexp) | [lisp.md](lisp.md) |
| LSP | [lsp.md](lsp.md) |
| Markdown Preview + MARP | [markdown.md](markdown.md) |
| Navigation & Splits | [navigation.md](navigation.md) |
| PlantUML Preview | [plantuml.md](plantuml.md) |
| Visual Editing | [editing.md](editing.md) |

---

## Quick Reference

### Navigation & Splits

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

→ [Full reference](navigation.md)

---

### File Tree (nvim-tree)

| Keys | Mode | Action |
|---|---|---|
| `<leader>n` or `Ctrl-n` | Normal | Open file tree |
| `Ctrl-t` | Normal | Toggle file tree |
| `Ctrl-f` | Normal | Reveal current file in tree |

→ [Full reference](file-tree.md)

---

### Terminal

| Keys | Mode | Action |
|---|---|---|
| `<leader>t` | Normal | Toggle terminal split |
| `Esc` | Terminal | Exit terminal insert mode |

→ [Full reference](navigation.md)

---

### Editing (Visual Mode)

| Keys | Mode | Action |
|---|---|---|
| `<` | Visual | Outdent selection and reselect |
| `>` | Visual | Indent selection and reselect |
| `<Tab>` | Visual | Indent selection |
| `<S-Tab>` | Visual | Outdent selection |
| `Shift-↓` | Visual | Move selected block down |
| `Shift-↑` | Visual | Move selected block up |
| `<leader>p` | Visual | Paste without overwriting clipboard |

→ [Full reference](editing.md)

---

### Comments (vim-commentary)

| Keys | Mode | Action |
|---|---|---|
| `gcc` | Normal | Toggle line comment |
| `gc` | Visual | Toggle comment on selection |
| `Ctrl-_` | Normal | Toggle comment (most terminals) |
| `Ctrl-/` | Normal | Toggle comment (Kitty / WezTerm) |

→ [Full reference](comments.md)

---

### Formatting (conform.nvim)

| Keys | Mode | Action |
|---|---|---|
| `<leader>f` | Normal / Visual | Format buffer or selection (LSP-preferred) |

*Format-on-save is enabled for Lisp, Clojure, Scheme, Fennel, and F# buffers.*

→ [Full reference](formatting.md)

---

### Copilot

| Keys | Mode | Action |
|---|---|---|
| `Ctrl-j` | Insert | Accept full inline suggestion |
| `Alt-f` | Insert | Accept next word of suggestion |

→ [Full reference](copilot.md)

---

### LSP (all LSP-enabled buffers)

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

→ [Full reference](lsp.md)

---

### Auto-Completion (nvim-cmp)

| Keys | Mode | Action |
|---|---|---|
| `Alt-Space` | Insert | Open completion menu |
| `Ctrl-n` | Insert | Select next suggestion (menu open) |
| `Ctrl-p` | Insert | Select previous suggestion (menu open) |
| `Enter` | Insert | Confirm highlighted suggestion |
| `Ctrl-e` | Insert | Dismiss completion menu |
| `Ctrl-f` | Insert | Scroll docs preview down |
| `Ctrl-b` | Insert | Scroll docs preview up |

→ [Full reference](completion.md)

---

### Git — vim-fugitive + gitsigns

| Keys | Mode | Action |
|---|---|---|
| `<leader>gs` | Normal | Git status (`:Git`) |
| `<leader>gb` | Normal | Git blame |
| `<leader>gl` | Normal | Git log |
| `<leader>gd` | Normal | Git diff (unstaged) |
| `<leader>gp` | Normal | Git push |
| `]h` | Normal | Next hunk |
| `[h` | Normal | Previous hunk |
| `<leader>hs` | Normal / Visual | Stage hunk |
| `<leader>hr` | Normal / Visual | Reset hunk |
| `<leader>hu` | Normal | Undo stage |
| `<leader>hb` | Normal | Blame line |

→ [Full reference](git.md)

---

### Haskell (haskell-tools)

Leader is `Space`; no LocalLeader bindings are used in Haskell buffers.

| Keys | Mode | Action |
|---|---|---|
| `<leader>rr` | Normal | Toggle GHCi REPL for package |
| `<leader>rf` | Normal | Toggle GHCi REPL for current file |
| `<leader>rq` | Normal | Quit GHCi REPL |
| `Space-cl` | Normal | Run code lenses |
| `Space-hs` | Normal | Hoogle search for type under cursor |
| `Space-ea` | Normal | Evaluate all code snippets |

→ [Full reference](haskell.md) · [Guide](../guides/haskell.md)

---

### F# REPL — iron.nvim

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

→ [Full reference](fsharp.md) · [Guide](../guides/fsharp.md)

---

### Lisp / Clojure / Scheme — Conjure

LocalLeader is `,` in Lisp/Clojure/Scheme/Fennel buffers.

#### Evaluation

| Keys | Action |
|---|---|
| `,ee` | Evaluate form under cursor |
| `,er` | Evaluate root (outermost) form |
| `,eb` | Evaluate entire buffer |
| `,e!` | Replace form with its evaluated result |
| `,cc` | Connect to REPL manually |

#### REPL Log

| Keys | Action |
|---|---|
| `,lv` | Open REPL log in vertical split |
| `,ls` | Open REPL log in horizontal split |
| `,lq` | Close REPL log window |

→ [Full reference](lisp.md) · [Guide](../guides/lisp.md)

---

### Structural Editing — vim-sexp

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

→ [Full reference](lisp.md)

---

### Markdown

LocalLeader is `,` in Markdown buffers.

| Keys | Action |
|---|---|
| `,p` | Toggle Markdown browser preview |
| `,dp` | Export to PDF with PlantUML diagrams rendered |
| `,mp` | MARP: open slide in preview server |
| `,mx` | MARP: export to PowerPoint (`.pptx`) |
| `,mh` | MARP: export to HTML |
| `,md` | MARP: export to PDF |

→ [Full reference](markdown.md) · [Diagrams guide](../guides/diagrams.md) · [Presentations guide](../guides/presentations.md)

---

### PlantUML

LocalLeader is `,` in PlantUML buffers.

| Keys | Action |
|---|---|
| `,p` | Preview diagram in browser (via Docker server) |

→ [Full reference](plantuml.md)

---

### HTML Live Preview (Bracey)

LocalLeader is `,` in HTML / CSS / JavaScript buffers.

| Keys | Action |
|---|---|
| `,p` | Start HTML live preview in browser |
| `,x` | Stop the live preview |
| `,r` | Reload the live preview |

→ [Full reference](html.md)
