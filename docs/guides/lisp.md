# Working with Lisp

This configuration is built around an interactive, REPL-driven Lisp workflow. Four plugins work together to give you a seamless experience:

| Plugin | Role |
|---|---|
| [Conjure](https://github.com/Olical/conjure) | Connect to a REPL and evaluate code without leaving the editor |
| [vim-sexp](https://github.com/guns/vim-sexp) + [mappings](https://github.com/tpope/vim-sexp-mappings-for-regular-people) | Structural editing — slurp, barf, and move S-expressions |
| [nvim-parinfer](https://github.com/gpanders/nvim-parinfer) | Keeps parentheses balanced automatically as you edit indentation |
| [rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim) | Color-codes matching delimiters so you can see nesting at a glance |

All four plugins lazy-load only when you open a **Lisp**, **Clojure**, **Scheme**, or **Fennel** file.

[conform.nvim](https://github.com/stevearc/conform.nvim) is also loaded for these filetypes and provides **format-on-save** as well as a manual **`<leader>f`** keybinding (normal and visual mode) to reformat the current buffer or selection.

## Prerequisites

### Choosing a REPL

| Language | REPL | Notes |
|---|---|---|
| Common Lisp | SBCL | Recommended — Docker setup included (see Quick Start) |
| Clojure | Clojure nREPL | Start with `clojure -M:nrepl` |
| Scheme | MIT Scheme | `sudo apt install mit-scheme` |
| Fennel | Fennel REPL | `fennel --repl` |

## LSP

The `cl_lsp` server is configured in `lua/config/lsp.lua` for Common Lisp. Install it via Quicklisp: `(ql:quickload :cl-lsp)`. See [readme.md](../../readme.md#lsp-support) for the shared LSP keybindings.

## Quick Start

1. **Start your REPL** in a terminal (Conjure connects to it):

   **Option A — Docker (recommended for Common Lisp):**
   A pre-configured Docker setup lives in `docker/sbcl-swank/`. It runs SBCL with Quicklisp and starts the Swank server on port 4005 automatically.

   ```sh
   # Build the image before first use and after pulling config updates:
   docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml build

   # Start the server and wait until Swank is ready before returning.
   # --build keeps the image current; --wait blocks until the healthcheck
   # passes so Conjure can connect as soon as you open a file.
   LISP_DIR=$PWD docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml up -d --build --wait

   # Stop it when done:
   LISP_DIR=$PWD docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml down
   ```

   Conjure will auto-connect on the next file open, or use `,cc` to connect manually.

   **Option B — local SBCL:**

   ```sh
   # Common Lisp (SBCL via Swank) — :style :spawn creates a new thread per
   # connection, which ensures evaluation results are returned to Conjure correctly.
   sbcl --load ~/.quicklisp/setup.lisp --eval '(ql:quickload :swank)' --eval '(swank:create-server :dont-close t :style :spawn)'

   # Clojure (nREPL)
   clj -Sdeps '{:deps {nrepl/nrepl {:mvn/version "1.0.0"} cider/cider-nrepl {:mvn/version "0.30.0"}}}' -M -m nrepl.cmdline --middleware '["cider.nrepl/cider-middleware"]'

   # Scheme (MIT Scheme)
   mit-scheme   # Conjure connects via its built-in Scheme client
   ```

2. **Open a source file** in Neovim — plugins load automatically:

   ```sh
   nvim hello.lisp    # or hello.clj, hello.scm, hello.fnl
   ```

3. **Evaluate code** using Conjure (local leader is `,`):

   | Keys | Action |
   |---|---|
   | `,ee` | Evaluate the form under the cursor |
   | `,er` | Evaluate the root (outermost) form |
   | `,eb` | Evaluate the entire buffer |
   | `,e!` | Replace the form with its result |
   | `,lv` | Open the REPL log in a vertical split |
   | `,ls` | Open the REPL log in a horizontal split |
   | `,lq` | Close the REPL log window |

4. **Edit structure** with vim-sexp (normal mode):

   | Keys | Action |
   |---|---|
   | `>)` | Slurp forward — pull the next element into the current form |
   | `<)` | Barf forward — push the last element out of the current form |
   | `<(` | Slurp backward |
   | `>(` | Barf backward |
   | `<f` | Move the current form left among its siblings |
   | `>f` | Move the current form right among its siblings |
   | `<e` | Move the current element left |
   | `>e` | Move the current element right |
   | `cse(` or `cse)` | Surround the element with `()` |
   | `cse[` or `cse]` | Surround the element with `[]` |
   | `dsf` | Delete surrounding function call (splice) |

5. **Parinfer** runs in the background — just adjust indentation and parens follow. No keys needed.

6. **Stop the Swank server** when you are done (Common Lisp only):

   If using **Docker**, stop the container:

   ```sh
   LISP_DIR=$PWD docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml down
   ```

   If running **SBCL locally**, evaluate the following with `,ee` (cursor on the form) or `,eb` (entire buffer):

   ```lisp
   (swank:stop-server 4005)
   ```

   Alternatively, switch to the terminal running SBCL and call the same form at the REPL prompt, or quit the process entirely:

   ```lisp
   (quit)
   ```

## Typical Workflow

```
 ┌──────────────────────────────────────────────┐
 │  Docker: sbcl-swank (or local REPL server)   │
 └──────────────────────────────────────────────┘
         ▲  Conjure connects on 127.0.0.1:4005
         │
 ┌──────────────────────────────────────────────┐
 │  Neovim                                      │
 │  ┌───────────────────┬──────────────────┐    │
 │  │  source.lisp      │  Conjure log     │    │
 │  │                   │  (REPL output)   │    │
 │  │  (defun greet (n) │  => "Hello!"     │    │
 │  │    (format t      │                  │    │
 │  │      "Hello ~a" n)│                  │    │
 │  │  )                │                  │    │
 │  │                   │                  │    │
 │  │  ,ee to eval ─────┘                  │    │
 │  └───────────────────┴──────────────────┘    │
 └──────────────────────────────────────────────┘
```

1. Write or edit code in the left pane.
2. Press `,ee` to evaluate the expression under the cursor — the result appears in the Conjure log.
3. Use `,lv` to open the log in a vertical split if it isn't visible.
4. Use vim-sexp motions (`>)`, `<(`, etc.) to restructure S-expressions without counting parentheses.
5. Parinfer keeps parens balanced automatically as you change indentation.
6. Rainbow delimiters let you visually match nesting depth.

## Troubleshooting

### HUD shows `;eval` but not the result

The Conjure HUD logs the evaluation intent the moment you press an eval key.
The result (`; => 6`) is a separate message that arrives once Swank returns it.
If you see the intent line but never the result, Conjure is **not actually
connected** to Swank — evals are logged locally but never sent.

**Step 1 — check whether port 4005 is open:**

```sh
# Should print 'Connected to 127.0.0.1 port 4005' when Swank is ready.
# Ctrl-C to exit once you see the message.
nc -z 127.0.0.1 4005 && echo "Swank is listening" || echo "Swank is NOT listening"
```

If Swank is not listening, the container is still starting up.  Check its
status:

```sh
docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml ps
```

The `STATUS` column will say `starting` or `healthy`.  Only open a Lisp file
once the status is `healthy`.  The easiest way to guarantee this is to use
`--wait` when starting the container (as shown in the Quick Start above) —
it blocks until the healthcheck passes before returning to your shell.

**Step 2 — reconnect if you opened the file too early:**

If you already have a `.lisp` buffer open and the container has since become
healthy, Conjure will not retry on its own.  Reconnect manually:

| Keys | Action |
|---|---|
| `,cs` | Show current connection status |
| `,cc` | Connect (or reconnect) to Swank |

**Step 3 — check the container logs for startup errors:**

```sh
docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml logs
```

SBCL prints a line like `Swank started at port: 4005.` when the server is
ready.  If you see an error before that line, the container is not healthy.
Rebuild from scratch:

```sh
docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml down
docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml build --no-cache
LISP_DIR=$PWD docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml up -d --wait
```

### Checking the full evaluation log

The HUD shows the last few lines of Conjure's log buffer as a floating popup.
To see the complete history:

| Keys | Action |
|---|---|
| `,lv` | Open the log in a vertical split |
| `,ls` | Open the log in a horizontal split |
| `,lq` | Close the log window |
