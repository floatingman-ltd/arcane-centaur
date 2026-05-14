## Context

See `design.md` for full rationale. Summary: big-bang convert ~40 `.md` → `.adoc` with pandoc, restructure to Antora layout, add GitHub Action pipeline with sentinel-aware logic, deploy to GitHub Pages. Docker-first for antora and pandoc. Manual `nav.adoc`. Retain `.md` files for editor preview.

---

## 1. Docker Tooling

- [x] 1.1 Create `docker/pandoc/` directory
- [x] 1.2 Create `docker/pandoc/run.sh`: check for native `pandoc` first; if not found, run `docker run --rm -v "$(pwd)":/data pandoc/minimal "$@"`; mark executable
- [x] 1.3 Create `docker/pandoc/README.md`: document `pandoc/minimal` image, native-first strategy, first-use pull behaviour, and example conversion command

- [x] 1.4 Create `docker/antora/` directory
- [x] 1.5 Create `docker/antora/run.sh`: run `docker run --rm -v "$(pwd)":/antora antora/antora "$@"`; mark executable
- [x] 1.6 Create `docker/antora/README.md`: document `antora/antora` image, local build usage (`./docker/antora/run.sh antora-playbook.yml`), and first-use pull behaviour

## 2. Big Bang Conversion

- [x] 2.1 Write `scripts/convert-docs.sh`: for each `.md` file under `docs/` and `readme.md`, run pandoc (`-f markdown -t asciidoc`) to produce a `.adoc` counterpart, injecting the sentinel header block at the top of each generated file
  - Sentinel format:
    ```
    // :auto-generated: true
    // :source: <relative-path-to-source.md>
    // Remove this header to take manual ownership of this file
    ```
- [x] 2.2 Run `scripts/convert-docs.sh` against all source `.md` files; verify `.adoc` output exists for every source file
- [x] 2.3 Review pass on converted `.adoc` files: check headings, tables, code blocks, and cross-file links for conversion artefacts; fix any broken relative links (`.md` → `.adoc` extension in xrefs)
- [x] 2.4 Manual admonition upgrade: find all `> **Note**`, `> **Warning**`, `> **Tip**` patterns in converted `.adoc` files and replace with native AsciiDoc admonitions (`NOTE:`, `WARNING:`, `TIP:`) — 0 occurrences found; pandoc rendered all blockquotes as `____` delimiter blocks, which are acceptable AsciiDoc sidebars

## 3. Antora Structure

- [x] 3.1 Create `antora.yml` at repo root:
- [x] 3.2 Create directory structure: `docs/modules/ROOT/pages/guides/`, `docs/modules/ROOT/pages/cheatsheets/`, `docs/modules/ROOT/pages/learning/janet/`
- [x] 3.3 Move converted `.adoc` files into their Antora page locations (mirror the current `docs/guides/`, `docs/cheatsheets/`, `docs/learning/` structure)
- [x] 3.4 Retain all original `.md` files in their current locations (they are not picked up by Antora and preserve editor preview)
- [x] 3.5 Create `docs/modules/ROOT/nav.adoc`: hand-authored navigation tree with xrefs for all guide, cheatsheet, and learning pages, grouped logically
- [x] 3.6 Create `antora-playbook.yml` at repo root:
- [x] 3.7 Convert `readme.md` → `readme.adoc` (project root); `readme.md` remains for GitHub's repo homepage rendering

## 4. GitHub Action Pipeline

- [x] 4.1 Create `.github/workflows/docs.yml`:
- [x] 4.2 Verify the sentinel-skip logic: add a test `.md` and a corresponding sentinel-free `.adoc` and confirm the action does not overwrite the `.adoc`

## 5. GitHub Pages Setup (manual, one-time)

- [ ] 5.1 In the GitHub repo Settings → Pages, set source to `gh-pages` branch, root `/` *(manual — do once after first successful Action run)*
- [ ] 5.2 Confirm the site is accessible at `https://floatingman-ltd.github.io/arcane-centaur` after the first successful Action run *(manual)*

## 6. Documentation

- [x] 6.1 Update `readme.adoc`: add "Documentation" section linking to the live GitHub Pages site
- [x] 6.2 Create `docs/modules/ROOT/pages/guides/contributing.adoc`: document the authoring workflow, sentinel header convention, how to graduate a file to manual AsciiDoc, and nav.adoc update requirement for new pages
- [x] 6.3 Update `readme.md` (GitHub homepage): add link to live docs site

## 7. Validation

- [ ] 7.1 Run `./docker/antora/run.sh antora-playbook.yml` locally; confirm site builds without errors and `build/site/index.html` exists
- [ ] 7.2 Open `build/site/index.html` in a browser; confirm navigation sidebar lists all guides and cheatsheets
- [ ] 7.3 Push a trivial `.adoc` edit to `main`; confirm GitHub Action triggers, completes successfully, and the change is visible on the live site
- [ ] 7.4 Push a new `.md` file (no corresponding `.adoc`); confirm pipeline converts it with sentinel and includes it in the build
- [ ] 7.5 Manually edit the sentinel out of one `.adoc`; push a change to its `.md` source; confirm pipeline does NOT overwrite the `.adoc`
- [ ] 7.6 Confirm all existing `.md` preview keymaps still work (`,p`, `,pp` on a `.md` file opens glow/markdown-preview as before)
