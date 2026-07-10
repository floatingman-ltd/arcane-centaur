## Context

Setup information is currently spread across `getting-started.adoc` (base tools: Neovim, Docker, build-essential/git/curl/unzip, Node via nvm) and each language guide's Prerequisites section (dotnet, lisp, haskell, janet, lua). The base guide predates several additions — it doesn't call out the C compiler as a **treesitter-parser** requirement, treats Node as "optional (markdown-preview only)" when bracey.vim also needs it, and there is no single place that answers "what do I install to work in language X". This surfaced repeatedly during test-machine validation (silent parser-install failures, missing LSP servers).

## Goals / Non-Goals

**Goals:**
- One authoritative base-setup page covering every shared tool, split required-for-all vs required-per-feature, with a feature→dependency table.
- One Language Setup matrix answering per-language prerequisites at a glance, linking to detailed guides.
- Consistent Prerequisites sections across language guides; no base-tool duplication.

**Non-Goals:**
- No `lua/`/config changes — docs only.
- Not rewriting the language guides' bodies — only normalising their Prerequisites sections.
- Not automating installs (no setup script) — documentation only.

## Decisions

- **Base authority stays `getting-started.adoc`; add a separate matrix page rather than one giant page.** A single mega-page would bury the per-language answer; a matrix page is scannable and links to detail. Alternative (per-guide only) leaves the "what do I need for X" question unanswered without opening each guide.
- **Matrix rows link to guides; guides own the detail.** Avoids duplicating install steps in two places (single source of truth per tool). The matrix is a scannable index; the guide has the full instructions.
- **Split base deps into required-for-everyone vs required-per-feature.** Most silent failures are base tools (C compiler, Node) that read as "optional" today; making the split explicit prevents that.
- **Use current Antora paths.** The existing `docs-getting-started` spec references an old `documentation/guides/getting-started.md` path; the live site uses `docs/modules/ROOT/pages/`. This change uses the live paths.

## Risks / Trade-offs

- [Duplication drift between matrix and guides] → Matrix holds only one-liners + links; full steps live once in the guide.
- [Install commands go stale (versions, URLs)] → Prefer version-agnostic commands and official-download links over pinned versions; note "check releases page" where needed.
- [Broken xrefs fail the Antora build] → Verify all `xref:` targets exist and rebuild the site before merge.
- [Overlap with the in-flight migration branches] → Docs-only and describes external prerequisites (stable across blink/treesitter changes); branch from `main`, independent of `feat/03`+.

## Migration Plan

1. Expand `getting-started.adoc` (base toolchain + feature→dependency table + link to matrix).
2. Create `languages/setup.adoc` matrix page.
3. Normalise each language guide's Prerequisites section; link the matrix to them.
4. Add the nav entry; rebuild the Antora site to confirm valid AsciiDoc and resolvable xrefs.
5. Rollback = revert the branch (docs-only, isolated).

## Open Questions

- Should the matrix live under `languages/` or a top-level `setup/`? (Proposed: `languages/setup.adoc`, grouped in the Languages nav section.)
- Do we want a companion "copy-paste everything" apt/one-shot block, or keep tool-by-tool? (Proposed: tool-by-tool + a short "minimal base" block.)
