## Context

The Janet learning series lives in two places:
- `docs/learning/janet/` — Markdown sources (GitHub preview, human-readable)
- `docs/modules/ROOT/pages/learning/janet/` — Antora `.adoc` pages (the live docs site)

Lessons 01 and 02 have Antora `.adoc` pages (auto-generated, now frozen). Lesson 03 was added as Markdown only — no Antora page exists for it yet. The README and nav.adoc reference 04–07 but those files don't exist at all. Four lessons plus a nav update for 03–07 remain.

The convert-docs.sh pipeline was removed in restructure-docs. New pages are hand-authored AsciiDoc directly in `docs/modules/ROOT/pages/`.

## Goals / Non-Goals

**Goals:**
- Deliver lessons 04–07 as hand-authored AsciiDoc in `docs/modules/ROOT/pages/learning/janet/`
- Create `docs/modules/ROOT/pages/learning/janet/03-functions.adoc` from the existing `docs/learning/janet/03-functions.md`
- Remove stale Markdown files from `docs/learning/janet/` (`README.md`, `03-functions.md`) — AsciiDoc is the canonical source
- Update `docs/modules/ROOT/nav.adoc` to list lessons 03–07 under the Janet Learning section
- Apply consistent `← Previous | Index | Next →` nav (AsciiDoc xref format) to all new `.adoc` pages

**Non-Goals:**
- Rewriting lessons 01 or 02 content
- Converting 01 or 02 from auto-generated to hand-authored
- Adding deep-dive lessons
- Changing Conjure, vim-sexp, or any plugin configuration

## Decisions

### 1. Hand-authored AsciiDoc, not Markdown conversion

**Decision:** Write new lessons directly as `.adoc` files only. Do not re-introduce a pandoc conversion pipeline. Remove the existing Markdown files (`README.md`, `03-functions.md`) from `docs/learning/janet/` once their `.adoc` counterparts exist.

**Rationale:** The restructure-docs change deliberately removed the conversion script. AsciiDoc is the source of truth. There is no value in maintaining parallel Markdown copies that will drift — GitHub can render `.adoc` files directly. The `docs/learning/janet/` directory will be emptied and can be removed once all lessons are in Antora.

**Alternative considered:** Keep Markdown as GitHub-preview convenience copies. Rejected: dual sources drift, create confusion about which is canonical, and GitHub's AsciiDoc rendering makes Markdown copies redundant.

### 2. One `.adoc` per lesson, no shared includes

**Decision:** Each lesson is a self-contained `.adoc` file. No shared include files for the nav bar or boilerplate.

**Rationale:** Antora supports `include::` but the nav pattern is a single line — the overhead of maintaining an include file for three lines of content is not justified. Lessons are few enough that copy-paste consistency is acceptable.

### 3. Nav bar uses inline AsciiDoc xrefs

**Decision:** Nav bars use `xref:` syntax: `← xref:03-functions.adoc[Previous] | xref:index.adoc[Index] | xref:05-modules.adoc[Next] →`

**Rationale:** Relative Markdown links (`[Previous](03-functions.md)`) do not work in Antora. AsciiDoc xrefs resolve correctly in both local Antora builds and the GitHub Pages site.

### 4. Lesson 03 Antora page created from existing Markdown

**Decision:** Convert `docs/learning/janet/03-functions.md` to `docs/modules/ROOT/pages/learning/janet/03-functions.adoc` manually. Delete the Markdown source once the `.adoc` exists (consistent with Decision 1).

**Rationale:** The Markdown was written with Antora in mind (lesson structure, code blocks). Manual conversion preserves quality. The `.adoc` will be hand-owned (no auto-generated sentinel).

## Risks / Trade-offs

- **Nav links break if lesson filenames change** → Mitigated: filenames follow a stable `NN-topic.adoc` convention. No renames planned.
- **Stale Markdown removal** → `docs/learning/janet/README.md` and `03-functions.md` are removed once their `.adoc` counterparts are in place. If the directory becomes empty it can also be removed.
