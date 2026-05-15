## Context

The documentation for this Neovim configuration has grown organically across `documentation/` (Markdown source) and `docs/modules/ROOT/pages/` (generated AsciiDoc). There are currently 19 guides and 23 cheatsheet source files. They share no consistent internal structure, are organised as flat alphabetical lists in the nav sidebar, and contain duplicated setup content scattered across multiple files.

The conversion pipeline (`scripts/convert-docs.sh` and `.github/workflows/docs.yml`) transforms Markdown → AscsiDoc via pandoc, with a sentinel header system to distinguish auto-generated files from manually-owned ones. This pipeline is sound and requires no structural changes — all work in this change is in the source Markdown files and `nav.adoc`.

**Constraints:**
- `docs/modules/ROOT/nav.adoc` is hand-authored and not generated — nav changes are manual
- Files with no sentinel header are manually owned and will not be regenerated — merging files requires sentinel management
- The pandoc pipeline runs in CI; local validation requires `luac` for Lua files only (docs have no build-time validation)
- `main` is branch-protected; all changes ship via PR

## Goals / Non-Goals

**Goals:**
- Define and apply a single consistent guide structure across all guides
- Reduce ~42 source files to ~32 by merging thin/redundant files
- Group nav sidebar by topic family with guides and cheatsheets co-located
- Create `getting-started.md` as the canonical system-prerequisites reference
- Dissolve `cli-console-mode.md` by distributing its sections to their natural homes
- Remove `validation.md` from the published site

**Non-Goals:**
- Changing any Neovim plugin behaviour or keymaps
- Automating the guide template via tooling (template is a convention, not enforced by a linter)
- Versioning or translating documentation
- Changing the pandoc/Antora pipeline

## Decisions

### 1. Template enforced by convention, not tooling

**Decision:** The guide template (usage-first, dynamic jump menu, setup at bottom) is documented as a convention and applied manually. No linter or template generator is introduced.

**Rationale:** The guides are few enough (~15 after merges) that manual consistency is maintainable. A linter would add tooling complexity with minimal payoff. The jump menu being dynamic (only links to present sections) means a static template would require per-guide customisation anyway.

**Alternative considered:** A shell script that validates heading order. Rejected — the set of capability sections varies per guide, making heading-order validation brittle.

---

### 2. Merge strategy: consolidate by functional moment, not by plugin count

**Decision:** Cheatsheets are merged when a reader would naturally look them up together, not purely because they are small. Merges:

| Result file | Sources merged |
|---|---|
| `editing.md` | existing + `comments.md` + `surround.md` |
| `navigation.md` | existing + `fzf.md` + `file-tree.md` + `unimpaired.md` |
| `code-intelligence.md` (new) | `lsp.md` + `completion.md` + `formatting.md` |
| `ai-tools.md` | existing + `copilot.md` |
| `markdown.md` | existing + `plantuml.md` + `html.md` |
| `dotnet.md` (guide+sheet) | existing + `fsharp.md` guide + `fsharp.md` cheatsheet |

**Rationale:** `git.md` already demonstrates the right model — three plugins, one sheet, good size. The REPL keymaps for C# and F# are identical (iron.nvim bindings); a single table with a backend note is cleaner than two identical tables.

**Alternative considered:** Keeping `lsp.md`, `completion.md`, `formatting.md` separate. Rejected — a developer reaching for "how do I trigger completion?" or "why isn't format-on-save working?" is in the same mental context as LSP; one sheet serves all three moments.

---

### 3. cli-console-mode.md dissolved, not renamed

**Decision:** The file is deleted and its six logical sections are distributed:

| Section | Destination |
|---|---|
| Console detection + `is_console` flag | `architecture.md` |
| Open URL behaviour | `architecture.md` |
| Clipboard / OSC 52 | `clipboard.md` (already covered; add cross-ref only) |
| Markdown Preview / Glow | `markdown.md` |
| PlantUML ASCII preview | `diagrams.md` |
| AI Research / Avante | `ai-tools.md` |

**Rationale:** The file was a catch-all for "things that work differently in console mode." Each section belongs to the guide for its feature, not to an environment-mode container. Readers look for "how do I use Glow?" not "what changes in console mode?"

**Alternative considered:** Renaming to `console-mode.md` and keeping it as a cross-reference page. Rejected — it would still be an orphan in the nav with no natural topic family.

---

### 4. Lisp and Janet: nav grouping only, files kept separate

**Decision:** `lisp.md` and `janet.md` (guides and cheatsheets) remain as separate files. The nav groups them under a "Lisp Family" label.

**Rationale:** The plugin set is identical but the REPL, LSP, and install paths diverge enough that a merged file would need heavy conditional prose. Grouping in nav solves the reader-confusion problem without creating a complex merged document.

**Alternative considered:** Full merge into a single "Lisp & Janet" guide. Rejected — the guides are already appropriately-sized and the LSP/REPL sections are materially different.

---

### 5. getting-started.md is a new file, not an expansion of architecture.md

**Decision:** System-level prerequisites (Neovim install, Docker, shared tools) go in a new `getting-started.md`, not appended to `architecture.md`.

**Rationale:** `architecture.md` explains the configuration structure for contributors and curious users. `getting-started.md` is for first-time setup. These are different audiences and different reading moments. Mixing them makes `architecture.md` harder to use as a reference.

**Alternative considered:** A "Prerequisites" section in `architecture.md`. Rejected — wrong audience fit.

---

### 6. Sentinel management for merged files

**Decision:** When two auto-generated files are merged, the result keeps the sentinel of the primary file. The secondary file's sentinel is removed. Files taken to manual ownership have their sentinel removed entirely.

**Rationale:** The conversion script skips files without a sentinel (treats them as manually owned). Merged files that consolidate content from multiple sources will have structural changes the script cannot reproduce, so manual ownership is appropriate for merged cheatsheets.

**Implication:** After this change, the following files become manually owned (no sentinel):
`editing.md`, `navigation.md`, `code-intelligence.md`, `ai-tools.md`, `markdown.md` (cheatsheet), `dotnet.md` (cheatsheet), `dotnet.md` (guide)

## Risks / Trade-offs

- **Nav.adoc maintenance burden** → The hand-authored sidebar must be updated carefully. Missing a new file or leaving a deleted file reference causes a broken nav link. Mitigation: the tasks artifact lists every nav.adoc edit explicitly.

- **Merged cheatsheets grow over time** → `navigation.md` absorbing fzf + file-tree + unimpaired could become long. Mitigation: accepted trade-off; all four are "cursor movement" tools and the combined size (~185 lines) is still one readable page.

- **Sentinel removal is irreversible without git** → Once a file loses its sentinel, the script will never regenerate it. Any future source-MD changes must be manually applied to the adoc too. Mitigation: this is intentional for merged files; git history preserves the original generated versions.

- **dotnet.md guide merge complexity** → The unified .NET guide must clearly separate C# and F# sections without making either feel secondary. Mitigation: use parallel section structure — `## C# (Roslyn)` and `## F# (fsautocomplete)` as siblings under `## LSP`.

## Migration Plan

1. Create `feat/restructure-docs` branch from `main` ✓ (already done)
2. Create `getting-started.md` guide (new file, no adoc yet)
3. Merge cheatsheet pairs in `documentation/cheatsheets/` — update sentinels
4. Merge dotnet + fsharp guides and cheatsheets
5. Dissolve `cli-console-mode.md` — distribute sections, delete file
6. Apply guide template (usage-first, jump menu, setup at bottom) to all remaining guides
7. Remove `validation.md` from `documentation/guides/`
8. Run `scripts/convert-docs.sh` to regenerate all auto-generated adoc files
9. Manually update merged/new adoc files (manually-owned after merge)
10. Rewrite `docs/modules/ROOT/nav.adoc` with topic-family groupings
11. Validate: `find . -name '*.lua' -print0 | xargs -0 luac -p` (Lua unchanged, sanity check)
12. Open PR to `main`

**Rollback:** The branch can be abandoned; `main` is unaffected until the PR merges.

## Open Questions

- None outstanding — all decisions were resolved during the explore session.
