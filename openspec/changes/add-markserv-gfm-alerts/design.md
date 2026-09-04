## Context

`docker/markserv/` is not upstream markserv. It is a ~220-line Express server (`server.js`) that renders markdown with `markdown-it` and overrides the fence renderer so `plantuml` blocks become `<img>` tags pointing at the local PlantUML server and `mermaid` blocks become `<pre class="mermaid">` for client-side rendering. Live reload is Server-Sent Events on `/__livereload`. The image is built from `node:20-alpine`.

Two details of the current implementation shape this change, and one of them contradicts the original proposal:

The `markdown-it` instance is constructed once at `server.js:47` with `{ html: true, linkify: true, typographer: true }`, and the fence override is attached immediately after. A plugin `.use()` belongs next to that construction.

**There is no stylesheet file.** All CSS lives in a single inlined `<style>` block built by `renderPage()` (`server.js:103-121`). The proposal's step 3 — "the container's stylesheet needs the five alert colours added, or the plugin's shipped stylesheet included" — has no stylesheet to edit, so it resolves to editing that inline block.

## Goals / Non-Goals

**Goals:**

- The five GFM alert types render as titled, coloured admonitions with GitHub's octicon, matching what a reader sees on GitHub closely enough that the panel category is obvious at a glance.
- A document containing no alert syntax renders exactly as it does today.
- The existing `plantuml` and `mermaid` fence overrides, live reload, and the path-traversal guard are unaffected.
- The change is reversible by removing one dependency, one `require`, one `.use()` and one CSS block.

**Non-Goals:**

- Highlighting on published Confluence pages. Confluence has no GFM alert concept; that needs native panel macros and is a separate publishing-path question.
- Dark-mode alert colours. The page template is light-only today (hardcoded `#24292e` text, `#f6f8fa` code backgrounds), so shipping dark alert colours alone would be inconsistent. Deliberately deferred rather than half-done.
- Alert support in the in-buffer renderer (`render-markdown.nvim`) or the popup. Different code path, different capability, not asked for.
- Changing `,sp` / `:MdServerPreview`, `lua/config/mdpreview.lua`, the port, the live-reload channel, or the volume mount.

## Decisions

### D1 — Use `markdown-it-github-alerts`, not a hand-rolled renderer

`markdown-it-github-alerts@1.0.1` (antfu, MIT) produces GitHub's own markup: `<div class="markdown-alert markdown-alert-note">` wrapping a `<p class="markdown-alert-title">` that carries an inline octicon `<svg>`. Verified by rendering all five types directly.

Alternatives considered. A hand-rolled `blockquote_open` renderer rule would avoid the dependency, but it would have to re-derive the marker parsing, the five class names, the five octicon paths and the title casing — all of which the plugin already gets right and keeps aligned with GitHub. `@mdit/plugin-alert` from `mdit-plugins` ships both CommonJS and ESM builds, which would sidestep D2 entirely, but it emits its own class vocabulary rather than GitHub's, so the CSS would have to be written from scratch instead of taken from the plugin and the output would drift from what contributors see on GitHub. The interop question in D2 turned out to be answerable, so GitHub-fidelity wins.

### D2 — Accept the ESM-only plugin via `require(esm)`, and pin the base image

The plugin is ESM-only: `"type": "module"`, `exports: { ".": "./dist/index.mjs" }`, no CommonJS build. `server.js` is CommonJS. On its face that is incompatible.

It works because `require(esm)` was backported to Node 20.19, and `node:20-alpine` currently resolves to **v20.20.2**. Confirmed by installing and rendering inside the actual image, not just locally — the local shell runs Node v24, where it would have worked regardless and proved nothing.

Two consequences:

The `require` returns a module namespace object, so the plugin function is on `.default`. The call site must be `const alerts = mod.default || mod`, not a bare `require(...)`. The `|| mod` arm costs nothing and survives the plugin ever shipping a CommonJS build.

`node:20-alpine` is a floating tag. It resolves to ≥20.19 today, but the tag is not a guarantee, and a rebuild on a host that has an older `node:20-alpine` cached would produce a container that **fails at startup** rather than degrading. The Dockerfile therefore pins to a base image known to satisfy the floor. This is the one place the change can break hard, so it gets a validation case of its own.

Alternative considered: converting `server.js` to ESM. That removes the interop question at its root, but it converts four working `require` calls and the module's whole loading contract to buy nothing else, and it is a larger diff than the feature. Rejected as disproportionate.

### D3 — Inline the plugin's base and light CSS rather than serving the shipped files

The shipped stylesheets total ~1.6 KB (`github-base.css` 1426 bytes, `github-colors-light.css` 172 bytes). Inlining them into `renderPage()`'s `<style>` block matches how every other rule in this server is delivered and keeps the page a single request with no new route, no `express.static` mount, and no dependency on `node_modules` layout at runtime.

The base stylesheet references colours as `var(--color-note)` and friends; the light stylesheet defines them on `:root`. Both are needed — the base alone renders alerts with a grey `#888` border and no title colour.

Alternatives considered: adding a route that serves the files from `node_modules` couples the page to the dependency's internal paths and adds a request; a CDN link adds an external dependency to a tool whose whole point is working locally.

### D4 — No collision with the existing `blockquote` rule

Alerts render as `<div class="markdown-alert">`, not `<blockquote>`, so the template's `blockquote { border-left: .25em solid #dfe2e5; color: #6a737d; }` does not apply to them and needs no change. A blockquote that is *not* an alert keeps rendering exactly as before. This is worth stating because it is the obvious place a careless implementation would produce a double border or grey out the alert text.

## Risks / Trade-offs

**The plugin is ESM-only and the base image tag floats** → the highest-consequence risk, because it fails at container startup rather than degrading: no server, not merely unstyled alerts. Mitigated by pinning the base image in the Dockerfile and by a validation case that rebuilds from scratch and asserts the container both starts and renders an alert.

**A rebuild is required and `docker compose up -d` alone will not do one** → the container would keep running the old image and the change would appear not to work, sending the next person hunting in the wrong place. Mitigated by making `--build` explicit in the docs and in the test plan's prepare step.

**`html: true` is already set on the `markdown-it` instance** → the plugin injects raw `<svg>`, which only renders because HTML passthrough is on. This is pre-existing and not introduced here, but it means the alert titles depend on that option staying true; turning it off later would strip the octicons and leave bare titles. Noted so the coupling is discoverable.

**Alert colour fidelity is light-mode only** → a reader using a dark browser theme gets GitHub's light alert colours on the template's light background, which is self-consistent but will look wrong if the template is ever darkened. Accepted: the alternative is shipping a dark theme for the whole page, which is a different change.

**The plugin adds a transitive dependency surface to a container that currently has four direct dependencies** → small, MIT-licensed, single-purpose, and the container is a local dev tool with no network exposure beyond `127.0.0.1`. Accepted.

## Migration Plan

1. Add the dependency, the `.use()`, the CSS and the base-image pin.
2. Rebuild: `docker compose -f docker/markserv/docker-compose.yml up -d --build`, with `MD_DIR` set to an absolute path matching Neovim's cwd.
3. Verify against a fixture carrying all five alert types plus a plain blockquote and a `plantuml` fence.

Rollback is removing the dependency, the `require`/`.use()` and the CSS block, then rebuilding. No data, no state, no published artefact is involved.

## Open Questions

None blocking. Dark-mode colours and in-buffer alert rendering are both deliberate non-goals rather than unknowns.
