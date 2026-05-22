# Janet

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

## vim-sexp — Structural Editing

| Key | Action |
|-----|--------|
| `>)` | Slurp forward |
| `<)` | Barf forward |
| `cse(` / `cse)` | Surround element with `()` |
| `cse[` / `cse]` | Surround element with `[]` |
| `dsf` | Splice (delete surrounding call) |

---

> Janet uses the `janet` client-server protocol; Conjure auto-connects on
> first evaluation if a Janet process is reachable.
