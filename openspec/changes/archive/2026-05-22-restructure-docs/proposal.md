## Why

The documentation has grown organically across two problems: readers can't tell where to look (guides are a flat alphabetical list with no grouping by topic family), and guides are structurally inconsistent — prerequisites, setup instructions, and usage content are jumbled in different orders across files, making repeat visits frustrating. Additionally, the Markdown → AsciiDoc conversion pipeline (pandoc + sentinel system) has been a source of repeated CI friction and a maintenance burden without delivering value now that native AsciiDoc authoring is practical. Fixing all three now, before more guides are added, establishes a clean authoring model and taxonomy for all future documentation.

## What Changes

**Native AsciiDoc authoring — pipeline eliminated:**
- `docs/modules/ROOT/pages/*.adoc` become the primary source of truth for all documentation
- `documentation/` folder deleted entirely (all `.md` source files removed)
- `scripts/convert-docs.sh` deleted
- `pandoc` install and conversion step removed from `.github/workflows/docs.yml`
- Sentinel header system no longer needed — all adoc files are directly owned
- CI workflow simplified to: Antora build → gh-pages deploy only

**README.md simplified:**
- Root `README.md` reduced to repo metadata (name, tagline, quick install, requirements)
- All detailed documentation removed from README and replaced with a link to the hosted docs site
- README is the only Markdown file that remains

**Guide template — all guides restructured:**
- Usage-first: Quick Start and capability sections appear at the top
- Dynamic jump menu below the title (only links to sections that exist in that guide)
- Setup sections moved to the bottom in reverse order: Troubleshooting → Setup → Prerequisites
- Setup and Prerequisites split into distinct sections (currently conflated)

**New getting-started guide:**
- Neovim version requirement (currently buried in `dotnet.md`)
- AppImage/tarball install instructions (currently in `dotnet.md`)
- General system prerequisites shared across languages
- Individual guides replace repeated version/install content with a cross-reference

**Nav sidebar grouped by topic family** (currently flat alpha list):
- Languages: .NET Ecosystem, Lisp Family, Haskell
- Editor Core, AI & Automation, Content Creation, Project Tooling, Reference

**File merges — guides:**
- `dotnet.md` + `fsharp.md` → unified `.NET (C# and F#)` guide
- `cli-console-mode.md` dissolved: console detection → `architecture.md`; Glow → `markdown.md`; PlantUML ASCII → `diagrams.md` (new guide); Avante → `ai-tools.md`

**File merges — cheatsheets:**
- `unimpaired.md` → merged into `navigation.md`
- `comments.md` + `surround.md` → merged into `editing.md`
- `copilot.md` → merged into `ai-tools.md`
- `plantuml.md` + `html.md` → merged into `markdown.md`
- `lsp.md` + `completion.md` + `formatting.md` → new `code-intelligence.md`
- `fsharp.md` cheatsheet → merged into `dotnet.md` cheatsheet

**New content:**
- `docs/modules/ROOT/pages/guides/git.adoc` — workflow guide for fugitive + gitsigns + diffview (cheatsheet already exists)
- `docs/modules/ROOT/pages/guides/diagrams.adoc` — absorbs PlantUML ASCII + Mermaid content (replaces existing stub)
- `docs/modules/ROOT/pages/guides/getting-started.adoc` — system setup, Neovim install, Docker install, shared prereqs
- `docs/modules/ROOT/pages/cheatsheets/code-intelligence.adoc` — LSP + completion + formatting

**Removed from site:**
- `validation.adoc` — tooling validation, not user-facing documentation
- `cli-console-mode.adoc` — dissolved into existing homes
- `fsharp.adoc` (cheatsheet) — content moved to `dotnet.adoc` cheatsheet

**Lisp / Janet:** kept as separate files, grouped together in nav sidebar.

## Capabilities

### New Capabilities
- `docs-guide-template`: Consistent guide structure — usage-first with dynamic jump menu, setup at bottom in reverse order (Troubleshooting → Setup → Prerequisites)
- `docs-nav-structure`: Topic-family grouping in nav sidebar with guides and cheatsheets co-located per group
- `docs-getting-started`: Single canonical setup guide covering Neovim install, version requirements, and shared system prerequisites

### Modified Capabilities
- `markdown-preview-glow`: Glow console preview section moves from `cli-console-mode.md` into `markdown.md`
- `plantuml-ascii`: ASCII preview section moves from `cli-console-mode.md` into new `diagrams.md`
- `console-detection`: Console detection documentation moves from `cli-console-mode.md` into `architecture.md`

## Impact

- `docs/modules/ROOT/pages/` — all `.adoc` files restructured, merged, and authored directly
- `docs/modules/ROOT/nav.adoc` — hand-authored sidebar rewritten with topic groupings
- `documentation/` — entire folder deleted
- `scripts/convert-docs.sh` — deleted
- `README.md` — simplified to repo metadata + link to hosted docs site
- `.github/workflows/docs.yml` — pandoc step removed; Antora build + deploy retained
