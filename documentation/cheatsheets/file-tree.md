# File Tree Cheatsheet (nvim-tree)

**Leader** = `Space`

→ Back to [main cheatsheet](index.md)

## Opening the Tree

| Keys | Mode | Action |
|---|---|---|
| `<leader>n` or `Ctrl-n` | Normal | Open file tree |
| `Ctrl-t` | Normal | Toggle file tree (open/close) |
| `Ctrl-f` | Normal | Reveal current file in tree |

## Inside the Tree Window

These are nvim-tree's built-in keys (active while the cursor is in the tree pane):

| Keys | Action |
|---|---|
| `Enter` or `o` | Open file / expand directory |
| `v` | Open in vertical split |
| `s` | Open in horizontal split |
| `t` | Open in new tab |
| `a` | Create new file or directory |
| `d` | Delete file or directory |
| `r` | Rename file or directory |
| `x` | Cut file |
| `c` | Copy file |
| `p` | Paste file |
| `y` | Copy filename |
| `Y` | Copy relative path |
| `gy` | Copy absolute path |
| `H` | Toggle hidden / dotfiles visibility |
| `R` | Refresh the tree |
| `q` | Close the tree window |
| `g?` | Show nvim-tree help |

---

*Global keymaps defined in `lua/keymaps.lua`. Tree plugin configured in `lua/plugins/nvim-tree.lua`.*
