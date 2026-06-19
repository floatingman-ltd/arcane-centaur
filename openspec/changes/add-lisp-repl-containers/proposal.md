# Add Lisp REPL Containers (multi-implementation Swank)

## Why

Today only SBCL has a Swank container (`docker/sbcl-swank/`). The planned Common Lisp learning arc needs more: its "Building an Application" lesson produces *implementation-specific* artifacts (SBCL core, CCL application, ECL native binary, ABCL uberjar), its appendices document each implementation hands-on, and its "Web RESTful Service" lesson must reach a running service from the host. Beyond the arc, anyone wanting to test portability — or run a library that only works on one implementation — has no supported way to do so, and there is no documented way to run a *different* implementation behind the single Conjure/Swank connection.

## What Changes

- Consolidate the Docker Swank setup into one `docker/lisp-swank/` directory:
  - A single shared `swank-start.lisp` (the Swank wire protocol is implementation-agnostic; the `:interface "0.0.0.0"` and `*use-dedicated-output-stream* nil` settings carry over unchanged).
  - One `docker-compose.yml` with four services under Compose **profiles** (`sbcl`, `ccl`, `ecl`, `abcl`), all publishing `127.0.0.1:4005:4005`. Only one profile runs at a time — establishing the contract: **whatever container owns `127.0.0.1:4005` is the active Lisp; Conjure only ever dials 4005.**
  - A readable per-implementation Dockerfile each (`sbcl/`, `ccl/`, `ecl/`, `abcl/`), so each learning appendix can point at one file.
- Expose an application port (`127.0.0.1:8080:8080`) so the web-service lesson can be reached from the host.
- Migrate the existing `docker/sbcl-swank/` into the new layout **without changing SBCL's behavior** — SBCL stays the trivial default (same build, same `up -d --wait`).
- Switching is **catalog-first / zero-Lua**: each implementation is started with a documented one-liner (`docker compose --profile <impl> up -d --wait`). A thin `:LispImpl` helper command is explicitly deferred.
- Document **CLISP** (interpreter, no native threads → `:style :spawn` caveat) and the **commercial** implementations (Allegro, LispWorks) as *non-containerized* — described, not shipped.
- Correct stale docs: `CLAUDE.md` line 30 (`cl_lsp` → `—`; no CL LSP is configured) and the line-22 note that Lisp uses `lsp_format = "prefer"` (a no-op with no CL LSP attached). Update `lisp.adoc` + `lisp-cheatsheet.adoc` for the new container layout.

## Capabilities

### New Capabilities

- `lisp-repl-containers`: Dockerized Common Lisp REPL servers for SBCL, CCL, ECL, and ABCL — each connectable from Conjure via Swank on `127.0.0.1:4005`, one active at a time, with a shared Swank startup, an exposed application port, and documented implementation switching. CLISP and commercial implementations are documented as non-containerized.

### Modified Capabilities

None — no existing OpenSpec spec covers the SBCL Swank container (it lived only in `lisp.adoc` prose). This change creates the first spec for it.

## Impact

- `docker/lisp-swank/` — new: shared `swank-start.lisp`, profiles `docker-compose.yml`, `sbcl/Dockerfile`, `ccl/Dockerfile`, `ecl/Dockerfile`, `abcl/Dockerfile`.
- `docker/sbcl-swank/` — removed (migrated into `docker/lisp-swank/sbcl/` + the shared files).
- Docs: `docs/modules/ROOT/pages/languages/lisp.adoc`, `docs/modules/ROOT/pages/languages/lisp-cheatsheet.adoc`, `docs/modules/ROOT/pages/getting-started.adoc` (SBCL + Swank section / compose paths), `CLAUDE.md` (lines 22 and 30).
- No Lua changes (catalog-first; `lua/plugins/lisp.lua` already points Conjure at 4005 and is unchanged). No new Neovim plugins.
- Downstream: unblocks `add-lisp-learning-series` (appendices, lesson 07 build artifacts, lesson 08 `:8080`).
