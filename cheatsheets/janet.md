# Janet

**LocalLeader** = `,`

---

## Conjure — Evaluation

| Key | Mode | Action |
|-----|------|--------|
| `,ee` | n | Evaluate form under cursor |
| `,er` | n | Evaluate root (outermost) form |
| `,em` | n | Evaluate marked form |
| `,ew` | n | Evaluate word under cursor |
| `,e!` | n | Evaluate and replace with result |
| `,eb` | n | Evaluate buffer (from memory) |
| `,ef` | n | Evaluate file (load from disk) |
| `,E` | x | Evaluate visual selection |
| `,gd` | n | Go to definition |
| `K` | n | Look up documentation (no prefix) |

## Conjure — Log Window

| Key | Action |
|-----|--------|
| `,ls` | Open log in horizontal split |
| `,lv` | Open log in vertical split |
| `,lt` | Open log in new tab |
| `,lg` | Toggle log window |
| `,ll` | Jump to latest result in log |
| `,lq` | Close all visible log windows |

## Conjure — Connection (Janet stdio client)

| Key | Action |
|-----|--------|
| `,cs` | Start the Janet REPL subprocess |
| `,cS` | Stop the Janet REPL subprocess |

> This config uses the Janet **stdio client** (`janet -n -s`). Conjure
> starts the subprocess automatically; use `,cs`/`,cS` to restart it.

---

## vim-sexp — Structural Editing

| Key | Mode | Action |
|-----|------|--------|
| `>)` | n | Slurp forward — pull next element into form |
| `<)` | n | Barf forward — push last element out of form |
| `<(` | n | Slurp backward |
| `>(` | n | Barf backward |
| `>e` / `<e` | n | Swap element forward / backward |
| `>f` / `<f` | n | Swap form forward / backward |
| `<I` / `>I` | n | Insert at head / tail of current form |
| `dsf` | n | Splice — delete surrounding brackets |
| `cse(` / `cse)` | n, x | Wrap element in `()` |
| `cse[` / `cse]` | n, x | Wrap element in `[]` |
| `cse{` / `cse}` | n, x | Wrap element in `{}` |

## vim-sexp — Text Objects

| Key | Mode | Action |
|-----|------|--------|
| `af` / `if` | x, o | Outer / inner list (compound form) |
| `as` / `is` | x, o | Outer / inner string |
| `ae` / `ie` | x, o | Outer / inner element |

---

> Janet uses the `janet -n -s` stdio client; Conjure spawns it automatically.
> Use `,cs` / `,cS` to start/stop the subprocess manually.
