## Why

The config's plugin/tooling set has grown a lot (blink completion, treesitter parsers, per-language LSP servers, REPL backends, Docker services, npm build steps). The setup docs haven't kept up: the external tools a new machine needs are **scattered across guides and incomplete**, and there is **no single "what do I install for language X" view**. New users hit silent failures — e.g. a missing C compiler means treesitter parsers never compile (no highlight), and a missing LSP server means no completions — with nothing in the docs to point at.

## What Changes

- **Expand `getting-started.adoc`** into a comprehensive base/system setup reference, split into **required for everyone** vs **required per feature**:
  - Neovim ≥ 0.12, git, curl, unzip.
  - **build-essential / a C compiler (`cc`/`gcc`)** — called out explicitly as required to compile nvim-treesitter parsers (a common silent failure).
  - **Node.js + npm** — required by plugin build steps (**markdown-preview.nvim and bracey.vim**).
  - **Docker Engine + Compose v2** — with a feature→service table (AI/Ollama, diagrams/PlantUML, Markdown export, presentations/MARP, AsciiDoc/Antora preview, Lisp REPL containers).
- **Add a new "Language Setup" matrix page** (`languages/setup.adoc`): one row per language/family listing the external prerequisites (LSP server, REPL/runtime, formatter, debugger, treesitter parser) with a one-line install command and a link to the detailed guide — so "working with C#? install these; working with Lisp? install these" is answerable at a glance.
- **Normalize each language guide's Prerequisites section** (dotnet/lisp/haskell/janet/lua) so they're consistent and complete; the matrix links to them.
- **Add a `nav.adoc` entry** for the new page.

## Capabilities

### New Capabilities
- `docs-language-setup`: A per-language setup matrix page listing external prerequisites (LSP, REPL, formatter, debugger, parser) for each language/family, with install commands and links to the detailed language guides.

### Modified Capabilities
- `docs-getting-started`: Extend the canonical getting-started guide to comprehensively cover the base toolchain — the C compiler requirement for treesitter parsers, Node/npm for plugin builds, and the Docker feature→service matrix — and to link out to the new language-setup matrix instead of leaving per-language tools scattered.

## Impact

- **Files:** `docs/modules/ROOT/pages/getting-started.adoc` (expand); `docs/modules/ROOT/pages/languages/setup.adoc` (new); `docs/modules/ROOT/pages/languages/{dotnet,lisp,haskell,janet,lua}.adoc` (normalize Prerequisites); `docs/modules/ROOT/nav.adoc` (add entry).
- **Docs only** — no `lua/` or config changes.
- The Antora build (`docker compose -f antora-playbook.yml run --rm antora antora-playbook.yml`) must still succeed (valid AsciiDoc, resolvable xrefs).
- Independent of the in-flight `feat/03`+ migration branches — describes external prerequisites, which are stable across those config changes.
