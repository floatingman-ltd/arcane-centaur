# Tasks: Add Lisp Learning Series

> **Prerequisite:** `add-lisp-repl-containers` should land first (appendices B–D, lesson 09 artifacts, lesson 11 `:8080`). Lessons 01–08 can be drafted against the existing SBCL container in parallel.

## 1. Scaffold the series

- [x] 1.1 Create `docs/modules/ROOT/pages/learning/lisp/` with `index.adoc` listing the 11 lessons + 6 appendices (model on janet `index.adoc`)
- [x] 1.2 Add a "Lisp Learning" section to `docs/modules/ROOT/nav.adoc`
- [x] 1.3 Cross-link from `languages/lisp.adoc` to the series index

## 2. Tooling lessons (01–02)

- [x] 2.1 `01-setup.adoc` — start the SBCL container, `,cc`, `,eb`, verify (link to, don't duplicate, the `lisp.adoc` Quick Start)
- [x] 2.2 `02-repl-as-ide.adoc` — Conjure eval, sexp slurp/barf, parinfer, rainbow; introspection (`describe`, `documentation`, arglists, source location) as the LSP substitute

## 3. Language lessons (03–07)

- [x] 3.1 `03-forms-functions-data.adoc`
- [x] 3.2 `04-loop-iteration.adoc`
- [x] 3.3 `05-condition-system.adoc` (restarts, `handler-case`/`handler-bind`, the interactive debugger over Swank)
- [x] 3.4 `06-clos.adoc` (`defclass`, `defgeneric`/`defmethod`, multiple dispatch, method combination)
- [x] 3.5 `07-macros.adoc` (`defmacro`, quasiquote, hygiene pitfalls, macro vs function)

## 4. Packaging lesson (08)

- [x] 4.1 `08-packages-systems-quicklisp.adoc` (`defpackage`/`in-package`, ASDF `.asd`, `ql:quickload`, project layout)

## 5. Project lessons (09–11)

- [x] 5.1 `09-building-an-application.adoc` — one ASDF system → four build artifacts (SBCL core, CCL app, ECL native bin, ABCL uberjar)
- [x] 5.2 `10-testing.adoc` — FiveAM/Parachute, suites, run from the REPL, wire `test-op` into the `.asd`
- [x] 5.3 `11-web-restful-service.adoc` — Hunchentoot or Clack/ningle, routes + JSON, run in-container, reach `:8080` from the host

## 6. Appendices

- [x] 6.1 `appendix-a-sbcl.adoc` — default container, `save-lisp-and-die`
- [x] 6.2 `appendix-b-ccl.adoc` — CCL container, `save-application`
- [x] 6.3 `appendix-c-ecl.adoc` — ECL container, compile-through-C native binary
- [x] 6.4 `appendix-d-abcl.adoc` — ABCL container, JVM/uberjar, Java interop
- [x] 6.5 `appendix-e-clisp.adoc` — non-containerized; `:style :spawn` limitation
- [x] 6.6 `appendix-f-commercial.adoc` — Allegro Express, LispWorks (non-containerized)

## 7. Wiring & validation

- [x] 7.1 Add nav bars (prev/index/next) to all 11 lessons; link appendices from the index
- [x] 7.2 Verify every `[source,lisp]` block evaluates in a Conjure REPL (`,ee`/`,eb`)
- [x] 7.3 Confirm no `.md` copies exist under `docs/learning/lisp/`
- [x] 7.4 Build the Antora site locally (`docker compose -f antora-playbook.yml run --rm antora antora-playbook.yml`) — no broken xrefs; `openspec validate add-lisp-learning-series` passes
