# Add Lisp Learning Series

## Why

The repository has a Common Lisp language guide (`lisp.adoc`) and cheatsheet, but no guided, REPL-driven learning arc — unlike Janet (`learning/janet/`, 7 lessons) and Ollama (`learning/ollama/`, 8 lessons). New users have reference material but no path that teaches Common Lisp *in this configuration*, building from the editor tooling up to shipping an application and a web service across multiple implementations.

## What Changes

- Add an 11-lesson REPL-driven Common Lisp learning arc as Antora AsciiDoc pages under `docs/modules/ROOT/pages/learning/lisp/`, plus an `index.adoc` and nav entries — following the established Janet/Ollama conventions (numbered `NN-topic.adoc`, xref nav bars, `[source,lisp]` evaluable blocks).
- Lessons:
  1. Setup & Connect — start the SBCL container, `,cc`, `,eb`
  2. The REPL is Your IDE — Conjure eval, sexp editing, parinfer, rainbow, + introspection (`describe`, `documentation`, arglists, source location) in lieu of an LSP
  3. Forms, Functions & Data
  4. LOOP & Iteration
  5. The Condition System (restarts, the interactive debugger over Swank)
  6. CLOS (classes, generic functions, multiple dispatch)
  7. Macros
  8. Packages, Systems & Quicklisp (ASDF, with Quicklisp folded in)
  9. Building an Application (one ASDF system → four implementation-specific artifacts)
  10. Testing (FiveAM/Parachute wired into the `.asd`)
  11. Building a Web RESTful Service (capstone; Hunchentoot/Clack on `:8080`)
- Add implementation **appendices**: A SBCL, B CCL, C ECL, D ABCL (each pointing at its `docker/lisp-swank/<impl>/Dockerfile`), E CLISP and F commercial (Allegro, LispWorks) as non-containerized.
- REPL-only throughout (no LSP); a "REPL as your IDE" section teaches editor-like intelligence from the live image.
- Author directly as AsciiDoc following the Janet arc — the `/add-learning-lesson` skill is Markdown-stale and is deliberately not used here.
- **Prerequisite:** depends on `add-lisp-repl-containers` landing first — appendices B–D, lesson 09's four build artifacts, and lesson 11's `:8080` all rely on the multi-implementation containers and exposed app port from that change. Lessons 01–08 only need the existing SBCL container and could be drafted in parallel.

## Capabilities

### New Capabilities

- `lisp-learning-series`: An 11-lesson REPL-driven Common Lisp learning arc plus implementation appendices, published as Antora AsciiDoc pages and listed in the nav sidebar.

### Modified Capabilities

None.

## Impact

- New: `docs/modules/ROOT/pages/learning/lisp/index.adoc` + `01`–`11` lesson pages + appendix pages (`appendix-a-sbcl.adoc` … `appendix-f-commercial.adoc`).
- `docs/modules/ROOT/nav.adoc` — new "Lisp Learning" section listing the index, lessons, and appendices.
- `docs/modules/ROOT/pages/languages/lisp.adoc` — cross-link to the new series.
- Upstream dependency: `add-lisp-repl-containers` (must land first).
- No Lua, no new plugins.
