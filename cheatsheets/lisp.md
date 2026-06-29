# Lisp / Clojure / Scheme / Fennel

**LocalLeader** = `,`

---

## Conjure — Evaluation (all clients)

| Key | Mode | Action |
|-----|------|--------|
| `,ee` | n | Evaluate form under cursor |
| `,er` | n | Evaluate root (outermost) form |
| `,em` | n | Evaluate marked form |
| `,ew` | n | Evaluate word under cursor |
| `,ep` | n | Evaluate and display result inline |
| `,e!` | n | Evaluate and replace with result |
| `,eb` | n | Evaluate buffer (from memory) |
| `,ef` | n | Evaluate file (load from disk) |
| `,ece` | n | Evaluate form, insert result as comment |
| `,ecr` | n | Evaluate root form, insert result as comment |
| `,E` | x | Evaluate visual selection |
| `,E` | n | Evaluate motion (operator) |
| `,gd` | n | Go to definition |
| `K` | n | Look up documentation (no prefix) |

## Conjure — Log Window

| Key | Action |
|-----|--------|
| `,ls` | Open log in horizontal split |
| `,lv` | Open log in vertical split |
| `,lt` | Open log in new tab |
| `,le` | Open log in current window |
| `,lg` | Toggle log window |
| `,lr` | Reset log (soft — wipe contents) |
| `,lR` | Reset log (hard — delete buffer) |
| `,ll` | Jump to latest result in log |
| `,lq` | Close all visible log windows |

## Conjure — Connection (Common Lisp / Janet)

| Key | Action |
|-----|--------|
| `,cc` | Connect to REPL (Swank port 4005 / netrepl) |
| `,cd` | Disconnect from REPL |

## Conjure — Clojure extras

| Key | Action |
|-----|--------|
| `,cf` | Connect via `.nrepl-port` file |
| `,ei` | Interrupt current evaluation |
| `,ve` | Display last exception |
| `,v1` / `,v2` / `,v3` | Display recent results |
| `,vs` | View source of symbol under cursor |
| `,ta` | Run all tests |
| `,tn` | Run tests in current namespace |
| `,tc` | Run test under cursor |
| `,rr` | Refresh changed namespaces |
| `,ra` | Refresh all namespaces |

## Conjure — Janet / Scheme / Fennel (stdio)

| Key | Action |
|-----|--------|
| `,cs` | Start the REPL subprocess |
| `,cS` | Stop the REPL subprocess |

---

## vim-sexp — Structural Editing (vim-sexp-mappings-for-regular-people)

| Key | Mode | Action |
|-----|------|--------|
| `>)` | n | Slurp forward — pull next element into form |
| `<)` | n | Barf forward — push last element out of form |
| `<(` | n | Slurp backward — pull previous element into form |
| `>(` | n | Barf backward — push first element out of form |
| `>e` | n | Swap element forward |
| `<e` | n | Swap element backward |
| `>f` | n | Swap form forward |
| `<f` | n | Swap form backward |
| `<I` | n | Insert at head of current form |
| `>I` | n | Insert at tail of current form |
| `dsf` | n | Splice — delete surrounding brackets |
| `cse(` / `cse)` | n, x | Wrap element in `()` |
| `cse[` / `cse]` | n, x | Wrap element in `[]` |
| `cse{` / `cse}` | n, x | Wrap element in `{}` |
| `W` / `B` / `E` | n, x, o | Next/prev element head; next element tail |

## vim-sexp — Text Objects

| Key | Mode | Action |
|-----|------|--------|
| `af` / `if` | x, o | Outer / inner list (compound form) |
| `aF` / `iF` | x, o | Outer / inner top-level list |
| `as` / `is` | x, o | Outer / inner string |
| `ae` / `ie` | x, o | Outer / inner element (atom/string/form) |

## vim-sexp — Motions

| Key | Mode | Action |
|-----|------|--------|
| `(` / `)` | n, x, o | Move to paired brackets backward / forward |
| `[[` / `]]` | n, x, o | Previous / next top-level element |
| `[e` / `]e` | n, x, o | Select previous / next element |

---

## GUIDES

- [1] sbcl-swank — Launch SBCL+Swank Docker image and connect
- [2] clojure-nrepl — Start nREPL server and connect Conjure
