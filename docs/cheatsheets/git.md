# Git Cheatsheet

**Leader** = `Space`

→ Back to [main cheatsheet](index.md)

---

## vim-fugitive — Git Operations

Run any git command with `:Git <args>` or its short alias `:G <args>` (e.g. `:Git commit`, `:G rebase -i HEAD~3`).

| Keys | Mode | Action |
|---|---|---|
| `<leader>gs` | Normal | Open git status (`:Git`) |
| `<leader>gb` | Normal | Git blame for current file |
| `<leader>gl` | Normal | Git log |
| `<leader>gd` | Normal | Git diff (unstaged changes) |
| `<leader>gp` | Normal | Git push |

### Inside the `:Git` status window

| Keys | Action |
|---|---|
| `s` | Stage file / hunk under cursor |
| `u` | Unstage file / hunk under cursor |
| `=` | Toggle inline diff for file under cursor |
| `cc` | Commit staged changes |
| `dd` | Diff file under cursor |
| `q` | Close the status window |

---

## gitsigns.nvim — In-Buffer Git Signs

Changed lines are marked in the sign column:
`▎` added · `▎` changed · `▁`/`▔` deleted line

### Hunk Navigation

| Keys | Mode | Action |
|---|---|---|
| `]h` | Normal | Jump to next hunk |
| `[h` | Normal | Jump to previous hunk |

### Hunk Actions

| Keys | Mode | Action |
|---|---|---|
| `<leader>hs` | Normal / Visual | Stage hunk (or selected lines) |
| `<leader>hr` | Normal / Visual | Reset hunk (or selected lines) |
| `<leader>hS` | Normal | Stage entire buffer |
| `<leader>hR` | Normal | Reset entire buffer |
| `<leader>hu` | Normal | Undo last stage |
| `<leader>hp` | Normal | Preview hunk inline |
| `<leader>hb` | Normal | Full blame for current line |
| `<leader>hd` | Normal | Diff this file (unstaged) |
| `<leader>hD` | Normal | Diff this file (staged, vs. HEAD) |

### Text Object

| Keys | Mode | Action |
|---|---|---|
| `<leader>ih` | Visual / Operator | Select current hunk |

---

> **Note — Haskell buffers:** `<leader>hs` is used by haskell-tools for Hoogle
> search in `.hs` files. The buffer-local haskell binding takes precedence there;
> use the fugitive status window (`:Git`) to stage changes while editing Haskell.

---

*Plugin configured in `lua/plugins/git.lua`.*
