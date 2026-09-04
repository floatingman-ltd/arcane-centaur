## Why

The markserv preview container renders a blockquote opening with `[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]` or `[!CAUTION]` as an ordinary blockquote whose first visible line is the literal text of the marker. GFM alerts are a GitHub extension rather than part of CommonMark, and `markdown-it` does not implement them.

This matters because the preview server is the only place some documents can be reviewed at all. A document carrying eight PlantUML diagrams renders them alongside its text nowhere else — not on Confluence, and not in the in-buffer renderer. Where a document uses alerts to separate categories of panel a reader needs to tell apart at a glance, the local preview is the one place the syntax fails to degrade *well*: it degrades to a blockquote with a stray marker line rather than to something readable.

## What Changes

- Add `markdown-it-github-alerts` to `docker/markserv/package.json` and `.use()` it on the `markdown-it` instance in `docker/markserv/server.js`, so the five GFM alert types render as titled, coloured admonitions with their GitHub octicon.
- Inline the plugin's base and light-theme CSS into the page template's existing `<style>` block in `server.js`. The container has **no stylesheet file** — all CSS is inlined by `renderPage()` — so the proposal's "add to the container's stylesheet" step resolves to editing that block.
- Document the alert syntax and the preview's support for it in the markdown content guide and cheatsheet.
- Add a `## Change · add-markserv-gfm-alerts` section to `openspec/TEST_PLAN.md`.

Not a breaking change. A document with no alert syntax renders byte-identically to today, and the whole change is reversible by dropping the dependency and the `.use()` call.

## Capabilities

### New Capabilities

- `markdown-server-preview`: the rendering contract of the markserv Docker preview server — which markdown constructs it renders and which of them must keep working. The container has never had a spec, so the alert requirement has no existing home, and the behaviours this change must *not* disturb (the `plantuml` and `mermaid` fence overrides, live reload, the path-traversal guard) have never been written down either.

### Modified Capabilities

None. `markdown-popup-preview` and `markdown-native-rendering` both govern in-editor rendering and are untouched by this change; the preview server is a separate path reached through `,sp` / `:MdServerPreview`.

## Impact

- `docker/markserv/package.json` — one new dependency.
- `docker/markserv/server.js` — one `require`, one `.use()`, and roughly 1.6 KB of CSS added to the inlined `<style>` block.
- Requires a container rebuild (`docker compose ... up -d --build`); the running container will not pick this up on restart alone.
- **The plugin is ESM-only** (`"type": "module"`, `dist/index.mjs`, no CommonJS build) while `server.js` is CommonJS. This works only because `require(esm)` was backported to Node 20.19 and the `node:20-alpine` base image currently resolves to v20.20.2. It is the one real risk in the change and is treated as such in the design.
- No change to `,sp` / `:MdServerPreview`, `lua/config/mdpreview.lua`, the port, the live-reload channel, or the volume mount.
- Explicitly out of scope: highlighting on published Confluence pages. Confluence has no concept of GFM alerts and needs its own native panel macros; that is a publishing-path question being handled separately.
