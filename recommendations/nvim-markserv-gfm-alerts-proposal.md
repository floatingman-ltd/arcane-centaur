# Proposal for the nvim config owners: render GFM alerts in the markserv preview

Raised 2026-09-03. Written as a proposal because the nvim configuration is managed by a separate
process; nothing here has been applied and no file under `~/.config/nvim/` has been touched.

## What is being asked for

Add GitHub-flavoured-markdown alert rendering to the markserv preview container, so that a
blockquote opening with `[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]` or `[!CAUTION]` renders
as a coloured admonition rather than as a blockquote whose first visible line is the literal text
`[!IMPORTANT]`.

## Why

The RMVMT documentation set uses inline panels to separate three things a reader needs to tell
apart at a glance: permanent design guidance, an open question owed to another team, and a review
comment awaiting an answer. DRIVER-LLD-0021 currently carries eleven such panels across 1670
lines, and that document is reviewed locally through markserv rather than on Confluence, because
markserv is the only place its eight PlantUML diagrams render alongside the text.

GFM alert syntax was chosen for the panels because it is a real convention with a defined
vocabulary, and because it degrades safely: anything that does not understand it shows an ordinary
blockquote. The one place it currently does not degrade *well* is the local preview, where the
marker line is visible as literal text.

## Current state

`~/.config/nvim/docker/markserv/` is a local build, not upstream markserv:

- `package.json` depends on `markdown-it` `^14.1.0`
- `server.js` line 22 requires `markdown-it`, and around line 45 overrides the fence renderer to
  handle `plantuml` and `mermaid` blocks

GFM alerts are a GitHub extension rather than part of CommonMark, so `markdown-it` does not
implement them and renders the marker as text.

## Suggested change

A plugin exists for exactly this and needs no custom code:

1. Add a dependency on a markdown-it GitHub-alerts plugin - `markdown-it-github-alerts` is the
   commonly used one - to `docker/markserv/package.json`.
2. `.use()` it on the `markdown-it` instance in `server.js`, alongside the existing fence override.
3. The plugin emits its own CSS class names, so the container's stylesheet needs the five alert
   colours added, or the plugin's shipped stylesheet included.

The existing `plantuml` and `mermaid` fence override is unaffected: alerts are a blockquote-level
construct and do not interact with fence rendering.

## Scope and risk

- Local preview only. It changes nothing about how any document is published.
- Backwards compatible. A document with no alert syntax renders exactly as it does today.
- Reversible by dropping the dependency and the `.use()` line.
- No change to `,sp` / `MdServerPreview`, the port, the live-reload channel, or the volume mount.

## What this does not solve, so it is not oversold

**It will not produce highlighting on the published Confluence pages.** Those are published from
markdown, and Confluence has no concept of GFM alerts; on the page the panels appear as blockquotes
with a literal marker line. Confluence highlighting needs its own native panel macros, which is a
publishing-path question and is being looked at separately on the RMVMT side. This proposal is
purely about making local review readable.

## If it is declined

Reasonable, and the fallback costs nothing: the documents revert to a plain bold lead-in inside a
blockquote (`> **LOOK HERE - ...**`), which renders identically in markserv, on Confluence and on
GitHub. The only loss is colour, and the panel classes stay distinguishable by their labels.
