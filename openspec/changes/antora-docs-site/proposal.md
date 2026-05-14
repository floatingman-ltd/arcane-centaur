## Why

The project documentation lives in ~40 Markdown files (~5,500 lines) spread across `docs/guides/`, `docs/cheatsheets/`, and `docs/learning/`. There is no published website — readers must navigate raw GitHub file views. Markdown's limitations (no native admonitions, weak table formatting, no include directives, no DRY content) become visible at this scale.

Converting to AsciiDoc and publishing via Antora on GitHub Pages gives:
- **Richer authoring**: native `NOTE:`/`TIP:`/`WARNING:` admonitions, proper table formatting (column widths, spans), source callouts in code blocks, `include::` for shared content
- **A real docs website**: navigable sidebar, syntax-highlighted code, search (Lunr), consistent theme
- **Sustainable pipeline**: every push to `main` automatically rebuilds and redeploys the site via a GitHub Action
- **Conflict-safe workflow**: a sentinel header distinguishes auto-generated `.adoc` files (safe to overwrite) from manually-enriched ones (protected from pipeline overwrites)

## What Changes

- **Big bang conversion**: all ~40 `.md` files converted to `.adoc` using `pandoc` (native-first, Docker fallback), with a sentinel header injected into auto-generated files
- **Antora structure**: `docs/` restructured to `docs/modules/ROOT/pages/` with `antora.yml`, `antora-playbook.yml`, and a hand-authored `nav.adoc`
- **GitHub Action**: `.github/workflows/docs.yml` — sentinel-aware conversion pipeline, Antora build (Docker), deploy to `gh-pages` branch
- **Docker tooling**: `docker/antora/` and `docker/pandoc/` with run scripts and READMEs
- **`readme.md` → `readme.adoc`**: root readme converted and updated to link to the live site

## Capabilities

### New Capabilities

- `antora-docs-site`: AsciiDoc documentation site built by Antora and deployed to GitHub Pages at `https://floatingman-ltd.github.io/arcane-centaur`. Site includes guides, cheatsheets, and learning content with sidebar navigation, syntax highlighting, and Lunr full-text search. Rebuilt and redeployed automatically on every push to `main` that touches documentation files.

### Modified Capabilities

<!-- none at spec level — all existing content is preserved, format changes only -->

## Impact

- **`docs/`**: restructured from flat guide/cheatsheet layout to `docs/modules/ROOT/pages/guides/`, `docs/modules/ROOT/pages/cheatsheets/`, `docs/modules/ROOT/pages/learning/`
- **`docs/modules/ROOT/nav.adoc`**: new file — manual navigation tree
- **`antora.yml`**: new file — Antora component descriptor at repo root
- **`antora-playbook.yml`**: new file — Antora site configuration at repo root
- **`.github/workflows/docs.yml`**: new file — build + deploy GitHub Action
- **`docker/antora/`**: new directory — run script and README
- **`docker/pandoc/`**: new directory — run script and README
- **`readme.adoc`**: new file (converted from `readme.md`); `readme.md` retained for GitHub repo homepage rendering
- **All `.md` files in `docs/`**: converted counterparts live under new Antora structure; originals retained for editor preview compatibility (glow, markdown-preview.nvim still work on `.md`)
- **No changes** to any Lua plugin or ftplugin files
