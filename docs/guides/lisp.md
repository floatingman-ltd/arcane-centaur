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
   # swank::*use-dedicated-output-stream* (double colon — internal symbol) must be
   # nil so Swank keeps all traffic on the main connection; with it enabled Swank
   # sends a :new-port handshake that Conjure does not implement, causing the
   # connection to be closed with "end of file".
   sbcl --load ~/.quicklisp/setup.lisp --eval '(ql:quickload :swank)' --eval '(setf swank::*use-dedicated-output-stream* nil)' --eval '(swank:create-server :dont-close t :style :spawn)'

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

### HUD shows `;eval` but not the result / `close-connection: end of file`

There are two distinct failure modes that look the same from Neovim's side
(eval notification appears but no result ever arrives):

**Failure mode A — port 4005 never opens (SBCL crashed at startup)**

Symptoms: `docker compose logs` shows an error before the `Swank started`
line; `nc -z 127.0.0.1 4005` reports the port is not listening.

**Failure mode B — port opens but connection is immediately dropped**

Symptoms: The container starts cleanly, port 4005 accepts connections, but
the Docker terminal shows `swank:close-connection: end of file`.  This is
caused by `*use-dedicated-output-stream*` being `t` (its default value).
With it enabled, Swank's first action after a client connects is to send a
`:new-port` message asking the client to open a second TCP connection for
output.  Conjure's Common Lisp Swank client does not implement this
handshake, so it stops responding; Swank reads EOF on the control stream and
closes the connection.

The fix — `(setf swank::*use-dedicated-output-stream* nil)` — is already in
the Dockerfile.  Note the **double colon** (`swank::`): this symbol is
internal to the swank package and is not exported, so the single-colon form
(`swank:`) raises a package error and must not be used.

**Step 1 — rebuild the image from scratch to pick up the fix:**

```sh
docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml down
docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml build --no-cache
LISP_DIR=$PWD docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml up -d --wait
```

**Step 2 — verify the container started cleanly:**

```sh
# Check status — should reach 'healthy', not stay on 'starting'
docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml ps

# Inspect logs — look for 'Swank started at port: 4005.' with no errors above it
docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml logs
```

**Step 3 — reconnect if you opened the file before the container was healthy:**

Conjure does not retry a failed auto-connect.  Reconnect manually:

| Keys | Action |
|---|---|
| `,cs` | Show current connection status |
| `,cc` | Connect (or reconnect) to Swank |

### Checking the full evaluation log

The HUD shows the last few lines of Conjure's log buffer as a floating popup.
To see the complete history:

| Keys | Action |
|---|---|
| `,lv` | Open the log in a vertical split |
| `,ls` | Open the log in a horizontal split |
| `,lq` | Close the log window |
