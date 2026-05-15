## Why

The documentation has grown organically across two problems: readers can't tell where to look (guides are a flat alphabetical list with no grouping by topic family), and guides are structurally inconsistent — prerequisites, setup instructions, and usage content are jumbled in different orders across files, making repeat visits frustrating. Fixing both now, before more guides are added, establishes a clear template and taxonomy for all future documentation.

## What Changes

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
- `documentation/guides/git.md` — workflow guide for fugitive + gitsigns + diffview (cheatsheet already exists)
- `documentation/guides/diagrams.md` — absorbs PlantUML ASCII + Mermaid content
- `documentation/guides/getting-started.md` — system setup, Neovim install, shared prereqs
- `documentation/cheatsheets/code-intelligence.md` — LSP + completion + formatting

**Removed from site:**
- `validation.md` — tooling validation, not user-facing documentation
- `cli-console-mode.md` — dissolved into existing homes
- `fsharp.md` cheatsheet — content moved to `dotnet.md` cheatsheet

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

- `documentation/guides/` — all files restructured; several merged or removed
- `documentation/cheatsheets/` — several files merged; new `code-intelligence.md` added
- `docs/modules/ROOT/pages/` — all `.adoc` files regenerated from updated sources
- `docs/modules/ROOT/nav.adoc` — hand-authored sidebar rewritten with topic groupings
- `scripts/convert-docs.sh` — no structural changes; runs as-is against updated sources
- `.github/workflows/docs.yml` — no structural changes needed
