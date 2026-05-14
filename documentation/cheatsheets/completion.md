# Auto-Completion Cheatsheet (nvim-cmp)

→ Back to [main cheatsheet](index.md)

## Completion Menu

| Keys | Mode | Action |
|---|---|---|
| `Alt-Space` | Insert | Open completion menu on demand |
| `Ctrl-n` | Insert (menu open) | Select next suggestion |
| `Ctrl-p` | Insert (menu open) | Select previous suggestion |
| `Enter` | Insert | Confirm highlighted suggestion |
| `Ctrl-e` | Insert | Dismiss completion menu |
| `Ctrl-f` | Insert | Scroll documentation preview down |
| `Ctrl-b` | Insert | Scroll documentation preview up |

`Enter` only inserts when an entry is actively highlighted — it will not
accidentally confirm the first suggestion. `Ctrl-n` and `Ctrl-p` follow
Vim's built-in completion-navigation convention and never block normal typing.

## Completion Sources

| Source | Provides |
|---|---|
| `nvim_lsp` | Language server completions |
| `luasnip` | Snippet expansions |
| `buffer` | Words from open buffers |
| `path` | File-system paths |
| `spell` | Dictionary words (when `spell` is active) |
| `cmp-conjure` | Conjure REPL completions (Lisp buffers) |

## Command-line Completion

| Mode | Sources |
|---|---|
| `/` search | Buffer words |
| `:` commands | File paths, then Ex commands |

---

*Configured in `lua/plugins/nvim-cmp.lua`.*
