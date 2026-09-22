## Why

The Antora site can only show diagrams as ASCII art in literal blocks. `other/terminals-ssh-tmux-mosh.adoc` needed six of them to stay readable, and they are the practical ceiling of that technique: alignment is maintained by hand, nothing validates them, and a change to one line means redrawing the box around it.

The repository already renders PlantUML — in Markdown previews, in `.puml` buffers via `:PumlPreview`, and in the Confluence publisher — all against a PlantUML server in Docker. The Antora build is the one surface that cannot, so the same diagram must be drawn twice in two formats depending on where it is published.

## What Changes

- **Register a diagram extension in `antora-playbook.yml`** so `[plantuml]` and other diagram blocks in `.adoc` pages render to images during the site build.
- **The extension is `asciidoctor-kroki`, not `asciidoctor-diagram`.** `asciidoctor-diagram` is a Ruby gem; Antora runs Asciidoctor.js under Node and cannot load it. This corrects the premise the change was first scoped under.
- **Pin `asciidoctor-kroki@latest-0`.** Version 1.0.0 and above requires Asciidoctor.js 4, which Antora 3 does not ship. The container here is Antora 3.1.14 on Node 16.20.2, measured 2026-09-21.
- **Add a Kroki service under `docker/kroki/`**, following the pattern of `docker/plantuml-server/` and `docker/ollama/`. Rendering is a service, so the containers-first rule covers it.
- **Build a small image for the Antora container** (`docker/antora/Dockerfile`) that installs the extension, and set `NODE_PATH` so Antora can resolve it — see `design.md` D3, where the naive install fails.
- **Convert the six ASCII diagrams in `other/terminals-ssh-tmux-mosh.adoc`** to rendered diagrams, as the first consumer and the proof the pipeline works.
- **Document the workflow** in `content/diagrams.adoc`, which currently describes three diagram paths and would gain a fourth.

Not breaking. Pages with no diagram blocks build exactly as now, and the ASCII literal blocks that remain elsewhere are untouched.

## Capabilities

### New Capabilities

- `docs-diagram-rendering`: Diagram blocks in Antora AsciiDoc pages are rendered to images at build time by a self-hosted Kroki service, with defined behaviour when that service is unreachable.

### Modified Capabilities

None. `plantuml-ascii` governs in-editor `:PumlPreviewAscii` and is untouched — this change adds a build-time path and removes no preview path. `docs-nav-structure` is unaffected because no page is added or moved.

## Impact

- **`antora-playbook.yml`** — gains an `asciidoc.extensions` entry and diagram attributes. It has never carried either.
- **`docker/antora/run.sh`** — must run the extension-bearing image instead of `antora/antora` directly, and reach the Kroki service.
- **`docker/kroki/`** — new compose file and README.
- **`docs/modules/ROOT/pages/other/terminals-ssh-tmux-mosh.adoc`** — six literal blocks become diagram blocks.
- **`docs/modules/ROOT/pages/content/diagrams.adoc`** — a fourth workflow to document.
- **Build prerequisites** — building the docs would newly require a running Kroki container. That is a change to what `./docker/antora/run.sh` needs and must be stated in `getting-started.adoc`.
- **Not affected:** every in-editor preview path. `:PumlPreview`, `:PumlPreviewAscii`, markdown-preview.nvim and the Confluence publisher keep using the PlantUML server on port 8080.

**An open question this change must settle rather than inherit:** whether Kroki replaces `docker/plantuml-server` outright. Kroki bundles PlantUML and speaks the same deflate+base64 encoding, so one service could serve both the build and the editor. Against that, `http://localhost:8080` is hardcoded at four call sites and the consolidation would touch working preview paths for no benefit to this change's goal. Recorded as D4 in `design.md`.
