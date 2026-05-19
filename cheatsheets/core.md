# Arcane-Centaur Cheatsheet

**Leader** = `Space` · **LocalLeader** = `,` (in language buffers)

---

## LSP (all LSP-enabled buffers)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `K` | Hover documentation |
| `gr` | Find references |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>e` | Show diagnostic float |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |

---

## Navigation & Splits

| Key | Action |
|-----|--------|
| `Ctrl-h` | Move to left split |
| `Ctrl-j` | Move to split below |
| `Ctrl-k` | Move to split above |
| `Ctrl-l` | Move to right split |
| `Ctrl-↑` | Shrink split height |
| `Ctrl-↓` | Grow split height |
| `Ctrl-←` | Shrink split width |
| `Ctrl-→` | Grow split width |

## File Tree

| Key | Action |
|-----|--------|
| `<leader>n` / `Ctrl-n` | Open file tree |
| `Ctrl-t` | Toggle file tree |
| `Ctrl-f` | Reveal current file in tree |

## Terminal

| Key | Action |
|-----|--------|
| `<leader>t` | Toggle terminal split (15-line) |
| `Esc` | Exit terminal insert mode |

---

## Git

### Fugitive

| Key | Action |
|-----|--------|
| `<leader>gs` | Git status |
| `<leader>gb` | Git blame |
| `<leader>gl` | Git log |
| `<leader>gd` | Git diff (unstaged) |
| `<leader>gp` | Git push |

### Gitsigns

| Key | Action |
|-----|--------|
| `]h` | Next hunk |
| `[h` | Previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hu` | Undo stage hunk |
| `<leader>hb` | Blame line |

### Diffview

| Key | Action |
|-----|--------|
| `<leader>gD` | Open diff view (working tree) |
| `<leader>gH` | File history for current file |
| `<leader>gX` | Close diff view |

---

## Copilot

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl-j` | Insert | Accept full inline suggestion |
| `Alt-f` | Insert | Accept next word of suggestion |
| `<leader>gcs` | Normal/Visual | Copilot CLI: suggest |
| `<leader>gce` | Normal/Visual | Copilot CLI: explain |
| `<leader>c` | Normal | Jump back from Copilot chat panel |

---

## Editing

| Key | Mode | Action |
|-----|------|--------|
| `<` | Visual | Outdent and reselect |
| `>` | Visual | Indent and reselect |
| `Tab` | Visual | Indent selection |
| `S-Tab` | Visual | Outdent selection |
| `S-Down` | Visual | Move block down |
| `S-Up` | Visual | Move block up |
| `<leader>p` | Visual | Paste without overwriting clipboard |

## System Clipboard

| Key | Mode | Action |
|-----|------|--------|
| `<leader>y` | Normal/Visual | Yank to system clipboard |
| `<leader>Y` | Normal | Yank line to system clipboard |
| `<leader>d` | Normal/Visual | Cut to system clipboard |
| `<leader>p` | Normal | Paste from clipboard (after cursor) |
| `<leader>P` | Normal | Paste from clipboard (before cursor) |

## Formatting

| Key | Action |
|-----|--------|
| `<leader>f` | Format buffer or selection (LSP-preferred) |

---

## Auto-Completion (nvim-cmp)

| Key | Mode | Action |
|-----|------|--------|
| `Alt-Space` | Insert | Open completion menu |
| `Ctrl-n` | Insert | Next suggestion |
| `Ctrl-p` | Insert | Previous suggestion |
| `Enter` | Insert | Confirm highlighted suggestion |
| `Ctrl-e` | Insert | Dismiss completion menu |
| `Ctrl-f` | Insert | Scroll docs down |
| `Ctrl-b` | Insert | Scroll docs up |

---

## OpenSpec

| Key | Action |
|-----|--------|
| `<leader>osn` | New OpenSpec change |
| `<leader>oss` | OpenSpec status |
| `<leader>osl` | List OpenSpec changes |
