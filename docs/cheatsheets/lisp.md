# Lisp Cheatsheet (Conjure + vim-sexp)

**LocalLeader** = `,` in Lisp / Clojure / Scheme / Fennel buffers

→ Back to [main cheatsheet](index.md) · Full guide: [../guides/lisp.md](../guides/lisp.md)

## Conjure — Evaluation

| Keys | Action |
|---|---|
| `,ee` | Evaluate form under cursor |
| `,er` | Evaluate root (outermost) form |
| `,eb` | Evaluate entire buffer |
| `,e!` | Replace form with its evaluated result |
| `,cc` | Connect to REPL manually |

## Conjure — REPL Log

| Keys | Action |
|---|---|
| `,lv` | Open REPL log in vertical split |
| `,ls` | Open REPL log in horizontal split |
| `,lq` | Close REPL log window |

## Structural Editing — vim-sexp

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

## Other Active Plugins

- **nvim-parinfer** — keeps parentheses balanced as you edit indentation (no keymaps)
- **rainbow-delimiters.nvim** — color-codes matching delimiters by depth (no keymaps)
- **LSP** (`cl_lsp` for Common Lisp) — see [lsp.md](lsp.md)
- **Formatting** (conform.nvim, format-on-save) — see [formatting.md](formatting.md)

---

*Conjure prefix configured in `lua/plugins/lisp.lua`. vim-sexp keymaps from `tpope/vim-sexp-mappings-for-regular-people`. LocalLeader set in `after/ftplugin/lisp.lua`, `clojure.lua`, and `scheme.lua`.*
