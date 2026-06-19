# Design: Add Lisp Learning Series

## Context

Two learning arcs already exist and define the conventions:

- **Janet**: `docs/modules/ROOT/pages/learning/janet/` — `index.adoc` + `01`–`07` `NN-topic.adoc`, each with an AsciiDoc xref nav bar, numbered `==` sections, `[source,janet]` evaluable blocks, and a verify/troubleshooting section. Governed by the `janet-learning-series` spec ("No Markdown copies SHALL exist").
- **Ollama**: `learning/ollama/` — same shape, 8 lessons.

AsciiDoc under `docs/modules/ROOT/pages/` is the canonical source (per `CLAUDE.md`); `docs/learning/` holds only empty leftover dirs from the migration. The `/add-learning-lesson` skill and its `learning-lesson-skill` spec still describe the old Markdown layout (`docs/learning/<lang>/*.md` + `README.md`) and are therefore stale — this arc is authored directly as AsciiDoc against the Janet templates, not via that skill.

The Common Lisp toolchain this arc teaches is already configured: Conjure (Swank client, port 4005), vim-sexp + mappings, nvim-parinfer, rainbow-delimiters, conform (format-on-save). No CL LSP is configured, by design — in Common Lisp the running image *is* the language server (arglists, completion, documentation, source location all come live from Swank).

## Goals / Non-Goals

**Goals:**

- 11 REPL-driven lessons + 6 appendices, following Janet/Ollama AsciiDoc conventions exactly.
- Build from editor tooling (lessons 01–02) → core language (03–07) → packaging (08) → projects (09–11).
- Tie the multi-implementation containers into the appendices and the app/web lessons.
- Every code block evaluable in a Conjure REPL with `,ee`/`,eb`.

**Non-Goals:**

- Not building the containers or the app port (that is `add-lisp-repl-containers`).
- No LSP content (REPL-only; introspection taught via Swank).
- Not using or modifying the `/add-learning-lesson` skill (its modernization is a separate follow-up).
- No new Lua or plugins.

## Decisions

**1. Eleven lessons, sequenced tools → language → packaging → projects.**
01 Setup, 02 REPL-as-IDE (tools); 03 Forms/Functions/Data, 04 LOOP & Iteration, 05 Condition System, 06 CLOS, 07 Macros (language); 08 Packages/Systems/Quicklisp (packaging); 09 Building an App, 10 Testing, 11 Web Service (projects). The brief pinned three points — first lessons build on the tools, build an app, build a web service — and the rest fills the gap.

**2. CLOS before Macros.**
So the project lessons (09–11) can model with objects; macros — the deepest topic — sits just before packaging. (Reversible.)

**3. Testing after Building an Application.**
You test the system you just built; the web service is the capstone (lesson 11), which reuses the testing approach. (Reversible.)

**4. Quicklisp folded into the Packages/Systems lesson (08).**
No standalone Quicklisp lesson — `defpackage`/ASDF/`ql:quickload` are taught together as the "make a project" unit.

**5. REPL-as-IDE section in lesson 02.**
Teaches `describe`, `documentation`, arglists, and `M-.`-style source location via Conjure/Swank — the authentic CL substitute for LSP features (no LSP is configured).

**6. Appendices A–D containerized, E–F doc-only.**
A SBCL, B CCL, C ECL, D ABCL each walk through the implementation's `docker/lisp-swank/<impl>/Dockerfile`, the start command, quirks, and the implementation-specific executable (`save-lisp-and-die` / `save-application` / ECL→C binary / ABCL uberjar). E CLISP and F commercial (Allegro, LispWorks) are described as non-containerized.

**7. Lesson 09 produces four artifacts.**
One ASDF system, four build endings — the concrete payoff that ties the arc to the appendices and to `add-lisp-repl-containers`.

**8. Authored as AsciiDoc directly.**
Mirror the Janet page structure (hand-authored; nav bars via xref; `nav.adoc` entries), not the stale Markdown skill.

## Risks / Trade-offs

- [Hard dependency on `add-lisp-repl-containers`] → Sequence it first; until then, appendices B–D and lessons 09/11 cannot be verified against real containers. Lessons 01–08 need only the existing SBCL container, so they can be drafted in parallel.
- [Large arc = substantial authoring + drift risk] → Keep each lesson self-contained and evaluable; reuse the existing `lisp.adoc` Quick Start (link, don't duplicate) for setup.
- [Examples must stay evaluable across implementations] → Lessons 03–08 target portable ANSI Common Lisp; implementation-specific behavior is confined to lesson 09 and the appendices.
- [The stale `/add-learning-lesson` skill may mislead future contributors] → Recorded here that the arc was authored directly; modernizing the skill + its spec is flagged as a separate, out-of-scope change.
