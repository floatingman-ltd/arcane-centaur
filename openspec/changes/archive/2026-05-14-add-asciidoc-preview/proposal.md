## Why

The editor provides rich Markdown preview via `,p` (Glow or markdown-preview.nvim) and `,pp` (Glow popup), but has no equivalent for AsciiDoc files. As the project migrates documentation to AsciiDoc for the Antora docs site, authors need to preview `.adoc` files without leaving the editor. The existing `.md` preview workflow remains unchanged — this change adds a parallel path for AsciiDoc.

## What Changes

- Add `after/ftplugin/asciidoc.lua` with `,p` and `,pp` keymaps that convert the current `.adoc` file to HTML via Docker (`asciidoctor/docker-asciidoctor`) and open the result in the system browser
- In console mode, `,p` and `,pp` show a graceful notification explaining that AsciiDoc preview is not available in terminal environments
- Add `docker/asciidoctor/` directory containing a shell run-script and README documenting the Docker image and usage
- Update `docs/cheatsheets/markdown.md` to note that AsciiDoc preview uses the same `,p`/`,pp` keys
- Update `readme.md` to document the new AsciiDoc preview capability

## Capabilities

### New Capabilities

- `asciidoc-preview`: Preview the current `.adoc` file in the system browser by converting it to HTML via the `asciidoctor/docker-asciidoctor` Docker image. Triggered by `,p` (GUI) or `,pp` (GUI). Console mode displays an informational notification that HTML preview is not available in terminal environments.

### Modified Capabilities

<!-- none — existing markdown preview keymaps and behaviour are unchanged -->

## Impact

- **`after/ftplugin/asciidoc.lua`**: new file — localleader `,` set, `,p` and `,pp` keymaps defined
- **`docker/asciidoctor/`**: new directory — `run.sh` wrapper script and `README.md`
- **`docs/cheatsheets/markdown.md`**: note added that the same keymaps apply to `.adoc` files
- **`readme.md`**: AsciiDoc preview entry added to relevant plugin/feature table
- **No changes** to `after/ftplugin/markdown.lua` or any existing preview logic
- **Runtime dependency**: Docker must be running; `asciidoctor/docker-asciidoctor` image pulled on first use (no pre-build required)
