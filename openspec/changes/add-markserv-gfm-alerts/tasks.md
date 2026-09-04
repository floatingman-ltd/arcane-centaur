## 1. Container implementation

- [x] 1.1 Add `"markdown-it-github-alerts": "^1.0.1"` to `dependencies` in `docker/markserv/package.json`.
- [x] 1.2 Pin the base image in `docker/markserv/Dockerfile` from `node:20-alpine` to `node:20.20-alpine`. The plugin is ESM-only and the server is CommonJS; this works only because `require(esm)` was backported to Node 20.19, and the floating `20-alpine` tag does not guarantee that floor. Record the reason in a comment — a future reader will otherwise "tidy" the pin away.
- [x] 1.3 Require the plugin in `docker/markserv/server.js` next to the existing `markdown-it` require, resolving it as `const alerts = mod.default || mod`. A bare `require(...)` yields the module namespace object, not the plugin function. The `|| mod` arm keeps working if the plugin ever ships a CommonJS build.
- [x] 1.4 `.use()` the plugin on the `md` instance at `server.js:47`, before the fence renderer override is attached. Alerts are a blockquote-level construct and do not interact with fences, but keeping plugin registration adjacent to construction matches the file's existing shape.
- [x] 1.5 Add the plugin's base rules and light colour definitions (~1.6 KB, from its `styles/github-base.css` and `styles/github-colors-light.css`) to the inlined `<style>` block in `renderPage()`. Both are required — the base rules reference `var(--color-note)` and friends, which only the colour file defines, so base-only styling yields grey borders and uncoloured titles.
- [x] 1.6 Confirm no change is needed to the existing `blockquote` CSS rule: alerts render as `<div class="markdown-alert">`, so the rule does not apply to them and a non-alert blockquote is unaffected.

## 2. Fixture

- [x] 2.1 Add a markdown fixture under `testdocs/` carrying all five alert types, an unrecognised `[!EXAMPLE]` marker, a plain blockquote, an alert with a rich body (multiple paragraphs, a list, inline code, a link), and a `plantuml` fence — so one page exercises every scenario in the spec including the two "must not change" ones.

## 3. Validation

- [x] 3.1 Add a `## Change · add-markserv-gfm-alerts` section to `openspec/TEST_PLAN.md` with `Prepare` / `Validate` / `Raise PR & merge` / `Post-merge` subsections, following the structure of the existing sections.
- [x] 3.2 Make the rebuild explicit in the prepare steps: `docker compose -f docker/markserv/docker-compose.yml up -d --build`. A plain `up -d` reuses the existing image, the change appears not to work, and the next person debugs the wrong layer.
- [x] 3.3 Include a case that rebuilds with **no layer cache** and asserts the container starts and serves an alert. This is the ESM/CommonJS risk from design D2, and it fails as a dead server rather than as unstyled output.
- [x] 3.4 Include the two "nothing changed" cases — a plain blockquote still renders as a blockquote with the existing border, and the `plantuml`/`mermaid` fences still render. These are the ones easiest to skip because nothing is expected to happen.
- [x] 3.5 Note in the prepare steps that `MD_DIR` must be an **absolute** path and must match Neovim's cwd. A relative value resolves against the compose file's directory, silently serving an empty tree — the failure already hit once and left a stray root-owned `docker/markserv/docs/` behind.
- [ ] 3.6 Walk every validation step live in a browser and tick each box only once genuinely confirmed.

## 4. Documentation

- [x] 4.1 Document the alert syntax and the preview's support for it in `docs/modules/ROOT/pages/content/markdown.adoc`, in the markserv preview section.
- [x] 4.2 Add the five alert markers to `docs/modules/ROOT/pages/content/markdown-cheatsheet.adoc`.
- [x] 4.3 Add them to `cheatsheets/markdown.md` as well — that is the in-editor cheatsheet surfaced by `lua/config/cheatsheet.lua`, and it is a separate file from the Antora page.
- [x] 4.4 Record what alerts do **not** do, where a reader would look for it: they render in the markserv preview only, not in the in-buffer renderer, not in the popup, and not on published Confluence pages.
- [x] 4.5 Note the rebuild requirement wherever the container's start command appears, so `up -d` alone is not mistaken for enough.
- [x] 4.6 Build the docs site: `./docker/antora/run.sh antora-playbook.yml`.

## 5. Close out

- [ ] 5.1 Delete `recommendations/nvim-markserv-gfm-alerts-proposal.md`, the incoming proposal this change supersedes, once the change is archived. Its content now lives in `proposal.md` and `design.md`.
- [ ] 5.2 Remove the stray root-owned `docker/markserv/docs/` tree left behind by the earlier relative-`MD_DIR` failure. It is empty, untracked and needs `sudo rm -rf`, so it is the user's to run.
