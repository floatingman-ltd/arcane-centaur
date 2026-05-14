## Context

See `design.md` for full rationale. Summary: add `,p`/`,pp` preview for `.adoc` files via Docker asciidoctor → HTML → `xdg-open`. Console mode shows a graceful notify. `.md` preview is unchanged.

## 1. Docker Setup

- [x] 1.1 Create `docker/asciidoctor/` directory
- [x] 1.2 Create `docker/asciidoctor/run.sh`: wrapper script that runs `docker run --rm -v "$(pwd)":/documents asciidoctor/docker-asciidoctor asciidoctor "$@"` with a Docker availability check
- [x] 1.3 Create `docker/asciidoctor/README.md`: document the image, first-use pull behaviour, and `run.sh` usage

## 2. Neovim ftplugin

- [x] 2.1 Create `after/ftplugin/asciidoc.lua`:
  - Set `vim.b.maplocalleader = ","`
  - Require `config.terminal`
  - Map `,p` (buffer-local): if `term.is_console` → `vim.notify` warn "AsciiDoc preview requires a GUI environment"; else → check Docker available, build output path `/tmp/asciidoc-preview-<bufnr>.html`, run `docker run --rm -v ...` asciidoctor conversion, then `xdg-open` the output file
  - Map `,pp` (buffer-local): identical behaviour to `,p` (no popup equivalent for HTML output)
  - Add Docker availability check helper: if `docker info` fails → `vim.notify` error with instructions

## 3. Documentation

- [x] 3.1 Update `docs/cheatsheets/markdown.md`: add a note that `,p`/`,pp` also work on `.adoc` files (GUI only) with the same keymaps
- [x] 3.2 Update `readme.md`: add AsciiDoc preview entry to the plugin/feature overview (note Docker dependency and GUI-only constraint)

## 4. Validation

- [x] 4.1 Open a `.adoc` file in GUI Neovim, press `,p` — confirm Docker runs, HTML is generated in `/tmp/`, and system browser opens the file
- [x] 4.2 Press `,pp` — confirm glow popup opens (via pandoc → CommonMark)
- [x] 4.3 Open a `.adoc` file in console Neovim (`--headless` or a real terminal session with `term.is_console = true`) — confirm `vim.notify` warning appears and no error is thrown
- [ ] 4.4 Stop Docker and press `,p` in GUI mode — confirm a clear error notification appears (not a silent failure or Lua traceback)
- [x] 4.5 Confirm `.md` preview is unaffected: `,p` and `,pp` in a Markdown buffer still route to Glow/markdown-preview as before
- [x] 4.6 Lua syntax check: `find . -name '*.lua' -print0 | xargs -0 luac -p`
