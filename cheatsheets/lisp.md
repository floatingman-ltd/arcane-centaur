# Lisp / Clojure / Scheme / Fennel

**LocalLeader** = `,`

---

## Conjure — Evaluation

| Key | Action |
|-----|--------|
| `,ee` | Evaluate form under cursor |
| `,er` | Evaluate root (outermost) form |
| `,eb` | Evaluate entire buffer |
| `,e!` | Replace form with its evaluated result |
| `,cc` | Connect to REPL manually |

## Conjure — REPL Log

| Key | Action |
|-----|--------|
| `,lv` | Open REPL log in vertical split |
| `,ls` | Open REPL log in horizontal split |
| `,lq` | Close REPL log window |

---

## vim-sexp — Structural Editing

| Key | Action |
|-----|--------|
| `>)` | Slurp forward — pull next element into form |
| `<)` | Barf forward — push last element out of form |
| `<(` | Slurp backward |
| `>(` | Barf backward |
| `>f` | Move current form right among siblings |
| `<f` | Move current form left among siblings |
| `>e` | Move current element right |
| `<e` | Move current element left |
| `cse(` / `cse)` | Surround element with `()` |
| `cse[` / `cse]` | Surround element with `[]` |
| `dsf` | Delete surrounding function call (splice) |

---

## GUIDES

- [1] sbcl-swank — Launch SBCL+Swank Docker image and connect
- [2] clojure-nrepl — Start nREPL server and connect Conjure
