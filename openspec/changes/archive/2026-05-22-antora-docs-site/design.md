## Context

The project has ~40 Markdown documentation files (~5,500 lines) across:
- `docs/guides/` — 18 narrative/how-to files
- `docs/cheatsheets/` — 19 table-heavy keybinding reference files
- `docs/learning/janet/` — 2 tutorial files
- `readme.md` — root entry point (528 lines)
- `specs/`, `testdocs/` — not published to the site

No GitHub Actions workflows exist. There is no published site. The existing Docker infrastructure covers markserv, MARP, PlantUML, md2pdf, ollama, and sbcl-swank.

The two heaviest structural patterns in the docs are:
1. **Keybinding tables** (cheatsheets): large Markdown tables mapping keys to actions — benefit most from AsciiDoc's `[%autowidth]` and `cols` table attributes
2. **Setup instructions** (guides): multi-step install flows with code blocks and informal NOTE/WARNING callouts using Markdown `> **Note**` hacks — benefit from native AsciiDoc admonitions

## Goals / Non-Goals

**Goals:**
- Convert all docs `.md` → `.adoc` using pandoc (big bang, one-time operation)
- Restructure `docs/` to Antora's `modules/ROOT/pages/` layout
- Hand-authored `nav.adoc` for full control over sidebar navigation
- Sentinel header in auto-generated `.adoc` files; pipeline skips files without sentinel
- GitHub Action: sentinel-aware, Antora build via Docker, deploy to `gh-pages`
- Docker run scripts for `antora` and `pandoc` (native-first for pandoc)
- Retain all `.md` files alongside `.adoc` so existing editor preview (glow, markdown-preview.nvim) continues to work
- Site deployed to `https://floatingman-ltd.github.io/arcane-centaur`

**Non-Goals:**
- Antora multi-version or multi-component setup (single component, no versioning)
- Custom Antora UI theme (Antora Default UI out of the box)
- Auto-generated `nav.adoc` (manual, by design)
- Automated nav.adoc updates when new pages are added (manual update per new page)
- Converting `specs/` or `testdocs/` content to the site
- CI for the Neovim config itself (only the docs pipeline)

## Decisions

### Antora over Hugo, Jekyll, or MkDocs
Antora is purpose-built for AsciiDoc technical documentation. It treats AsciiDoc as first-class (not an external renderer shim), provides built-in Lunr search, automatic syntax highlighting, and a polished default UI. For a project of this type (technical docs, guides + reference), Antora's opinionated structure is a feature, not a constraint.

*Alternative considered*: Hugo + Geekdoc theme. Rejected — Hugo calls `asciidoctor` as an external renderer, which limits AsciiDoc feature support and adds friction. Antora's AsciiDoc support is complete and native.

### Sentinel header for pipeline/manual conflict resolution
Auto-generated `.adoc` files receive a header comment block:
```
// :auto-generated: true
// :source: <relative-path-to-source.md>
// Remove this header to take manual ownership of this file
```
Pipeline logic: if `.adoc` contains the sentinel → regenerate from `.md`. If sentinel absent → skip. This makes the ownership contract explicit and prevents accidental overwrite of manual AsciiDoc enrichments. Authors graduate a file by removing the sentinel and committing.

*Alternative considered*: "if `.adoc` exists, never overwrite". Rejected — too coarse; prevents updating auto-managed files when the `.md` source legitimately changes.

### pandoc over kramdoc for big bang conversion
`pandoc` is very likely already installed on the developer machine (confirmed probable). `pandoc/minimal` Docker image available as fallback. Conversion quality for this content (clean Markdown, no unusual extensions) is sufficient with a review pass. `kramdoc` (kramdown-asciidoc) produces marginally cleaner AsciiDoc but requires Ruby — an additional runtime dependency.

*Alternative considered*: kramdoc. Rejected — Ruby dependency not worth it for a one-time conversion; pandoc fallback-to-Docker pattern reusable across the project.

### Native pandoc first, Docker fallback
The conversion script checks for native `pandoc` and uses it if available; falls back to `docker run --rm pandoc/minimal`. Matches the observed project pattern: prefer native tools where present, Docker where not.

### `.md` files retained alongside `.adoc`
`.md` files are kept in their new locations under `docs/modules/ROOT/pages/`. This preserves editor preview compatibility (glow and markdown-preview.nvim target `.md`). The Antora build ignores `.md` files (they are not AsciiDoc sources). When a file is fully graduated to `.adoc`, the `.md` can optionally be deleted — but that's a per-file decision, not a policy.

### Manual `nav.adoc`
Antora's navigation is driven by a `nav.adoc` file that lists page xrefs in the desired order. Auto-generation from directory structure would produce alphabetical order and lose semantic grouping (e.g., language guides grouped together, cheatsheets in a logical sequence). Manual authoring takes ~30 minutes and produces a significantly better sidebar. Nav updates are required when new pages are added — acceptable overhead.

### Docker for Antora, Docker-fallback for pandoc
Consistent with the project's Docker-first tooling philosophy. No global `antora` or Ruby install required. `antora/antora` official image used in the GitHub Action and documented for local use.

### `gh-pages` branch deployment
Standard GitHub Pages pattern. The GitHub Action builds the Antora site and force-pushes the output to `gh-pages`. The source branch (`main`) stays clean — no build artefacts committed.

## Risks / Trade-offs

- **Docs restructure scope**: moving ~40 files to a new directory layout is a large change. Mitigated by the big bang being a scripted, reviewable operation; existing cross-references in converted `.adoc` will need a review pass.
- **pandoc conversion quality**: pandoc doesn't convert Markdown `> **Note**` patterns to AsciiDoc `NOTE:` admonitions — these remain as blockquotes. Mitigated by a dedicated review task to upgrade admonitions manually in the most important guides.
- **nav.adoc maintenance burden**: every new page requires a manual `nav.adoc` update or it won't appear in the sidebar. Mitigated by documenting this clearly in the contributing guide.
- **Sentinel requires contributor awareness**: contributors must know to remove the sentinel before making AsciiDoc-specific edits, or their enrichments will survive only until the next `.md` edit triggers regeneration. Mitigated by a clear comment in the sentinel block itself.
- **GitHub Pages initial setup**: the `gh-pages` branch and GitHub Pages must be enabled in the repo settings once. Not automated — requires a one-time manual action.
