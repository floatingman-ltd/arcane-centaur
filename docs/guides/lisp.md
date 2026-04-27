# Working with Lisp

This configuration is built around an interactive, REPL-driven Lisp workflow. Four plugins work together to give you a seamless experience:

| Plugin | Role |
|---|---|
| [Conjure](https://github.com/Olical/conjure) | Connect to a REPL and evaluate code without leaving the editor |
| [vim-sexp](https://github.com/guns/vim-sexp) + [mappings](https://github.com/tpope/vim-sexp-mappings-for-regular-people) | Structural editing — slurp, barf, and move S-expressions |
| [nvim-parinfer](https://github.com/gpanders/nvim-parinfer) | Keeps parentheses balanced automatically as you edit indentation |
| [rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim) | Color-codes matching delimiters so you can see nesting at a glance |

All four plugins lazy-load only when you open a **Lisp**, **Clojure**, **Scheme**, or **Fennel** file.

> **Janet** shares the same plugin set (Conjure, vim-sexp, parinfer, rainbow-delimiters). See [janet.md](janet.md) for the Janet-specific guide.

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
   # Common Lisp (SBCL via Swank).
   # - :style :spawn creates a new thread per connection.
   # - swank::*use-dedicated-output-stream* nil (double colon — internal symbol)
   #   keeps all traffic on the single control connection; without it Swank
   #   sends a :new-port handshake that Conjure does not implement, causing
   #   the connection to be closed with "end of file".
   # - :interface is not needed for local SBCL (Conjure connects to 127.0.0.1
   #   which is the default); only required inside a Docker container where
   #   port-forwarding routes to a different network interface.
   sbcl --load ~/.quicklisp/setup.lisp \
        --eval '(ql:quickload :swank)' \
        --eval '(ignore-errors (setf swank::*use-dedicated-output-stream* nil))' \
        --eval '(swank:create-server :dont-close t :style :spawn)'

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
   | `>)` | **Slurp forward** — extend the closing `)` rightward, pulling the next sibling *into* the form |
   | `<)` | **Barf forward** — shrink the closing `)` leftward, pushing the last element *out of* the form |
   | `<(` | **Slurp backward** — extend the opening `(` leftward, pulling the previous sibling *into* the form |
   | `>(` | **Barf backward** — shrink the opening `(` rightward, pushing the first element *out of* the form |
   | `<f` | Move the current form left among its siblings |
   | `>f` | Move the current form right among its siblings |
   | `<e` | Move the current element left |
   | `>e` | Move the current element right |
   | `cse(` or `cse)` | Surround the element with `()` |
   | `cse[` or `cse]` | Surround the element with `[]` |
   | `dsf` | Delete surrounding function call (splice) |

   See [Structural Editing: Slurp & Barf](#structural-editing-slurp--barf) below for step-by-step examples.

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

## Structural Editing: Slurp & Barf

Slurp and barf let you **reshape S-expressions without manually counting or moving parentheses**. The cursor can be anywhere inside (or on the delimiter of) the target form when you press the key.

Each example below shows the code before and after the operation.

---

### Slurp forward — `>)`

Moves the **closing** `)` one step to the right, pulling the **next sibling** element into the form.

```lisp
; Before — cursor anywhere inside (foo bar); 'baz' is a sibling outside the form
(foo bar) baz

; After >)  — 'baz' is now inside the form
(foo bar baz)
```

Useful when you realise a following expression belongs inside the current call. Press `>)` again to pull in the next sibling, and so on.

---

### Barf forward — `<)`

Moves the **closing** `)` one step to the left, pushing the **last element** out of the form.

```lisp
; Before — cursor anywhere inside (foo bar baz)
(foo bar baz)

; After <)  — 'baz' has been expelled; it is now a sibling after the form
(foo bar) baz
```

This is the reverse of slurp forward. Use it to trim an element you accidentally slurped in, or to split a call up.

---

### Slurp backward — `<(`

Moves the **opening** `(` one step to the left, pulling the **previous sibling** element into the form.

```lisp
; Before — cursor anywhere inside (bar baz); 'foo' is a sibling before the form
foo (bar baz)

; After <(  — 'foo' is now the first element inside the form
(foo bar baz)
```

---

### Barf backward — `>(`

Moves the **opening** `(` one step to the right, pushing the **first element** out of the form.

```lisp
; Before — cursor anywhere inside (foo bar baz)
(foo bar baz)

; After >(  — 'foo' has been expelled; it is now a sibling before the form
foo (bar baz)
```

---

### Combining operations

Slurp/barf pairs let you migrate elements between adjacent forms without cutting and pasting:

```lisp
; Start: two separate forms (cursor inside the defun)
(defun greet (name)) (format t "Hello ~a!" name)

; >)  slurp the format call into defun
(defun greet (name)
  (format t "Hello ~a!" name))
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

### HUD shows nothing / `close-connection: end of file`

There are **three distinct failure modes**.  Read all three before rebuilding.

---

**Failure mode 1 — port 4005 never opens (SBCL crashed at startup)**

Symptoms: `docker compose logs` shows an error *before* the
`Swank started at port: 4005.` line; the container status stays
`starting` and never reaches `healthy`.

---

**Failure mode 2 — Conjure's connection is refused (HUD shows nothing, no `close-connection`)**

Symptoms: The container is `healthy`, port 4005 is open on the host,
but Conjure cannot connect and the HUD stays silent.

Root cause: `swank:create-server` binds to `127.0.0.1` (loopback) by
default.  Docker port-forwarding routes host connections to the
**container's eth0 interface** (e.g. `172.17.0.2`), not to its loopback.
The TCP connection is refused at the network level — Swank never sees it,
so no `close-connection` appears in the logs.

Fix: the `swank-start.lisp` in this repo passes `:interface "0.0.0.0"` so
Swank listens on all interfaces.

---

**Failure mode 3 — connection drops immediately (spurious `close-connection: end of file`)**

Symptoms: `docker compose logs` prints `close-connection: end of file`
repeatedly.

There are two sources for this message:

**(a) Healthcheck noise (harmless)** — the old healthcheck opened a TCP
connection to Swank every 5 seconds to test reachability.  Swank accepted
the connection, read EOF when the healthcheck exited, and logged
`close-connection: end of file`.  The current healthcheck reads
`/proc/net/tcp` instead and makes no TCP connection.

**(b) The `:new-port` handshake** — `*use-dedicated-output-stream*`
defaults to `t`.  When Conjure connects, Swank immediately sends `:new-port`
asking the client to open a second socket for output.  Conjure does not
implement this handshake; it stops reading, Swank reads EOF, and logs
`close-connection: end of file`.  The `swank-start.lisp` sets
`swank::*use-dedicated-output-stream* nil` to disable this.  Note the
**double colon** (`swank::`): the symbol is internal to the package and not
exported, so the single-colon form raises a package error.

---

**Applying the fixes**

All three fixes are already in the repository (`swank-start.lisp`,
updated `Dockerfile`, updated `docker-compose.yml`).  They only take
effect after a full image rebuild:

```sh
# 1. Pull the latest config
cd ~/.config/nvim && git pull

# 2. Stop any running container and rebuild from scratch
docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml down
docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml build --no-cache

# 3. Start and wait until healthy before opening a Lisp file
LISP_DIR=$PWD docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml up -d --wait
```

**Verifying it worked:**

```sh
# Status should be 'healthy'
docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml ps

# Logs should show 'Swank started at port: 4005.' with no errors
# (no repeated 'close-connection' lines — those came from the old healthcheck)
docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml logs
```

**Reconnecting after a rebuild:**

Conjure does not retry a failed auto-connect.  After the container is
healthy, reconnect manually if you already have a `.lisp` buffer open:

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
