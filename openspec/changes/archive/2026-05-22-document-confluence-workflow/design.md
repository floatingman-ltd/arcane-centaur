## Context

The Confluence workflow (`lua/config/confluence.lua`) is a 622-line pure-Lua module that has grown organically to handle publish, pull, comments, conflict detection, page-map resolution, and an optional Lua filter pipeline. It has comprehensive inline comments but no formal specification. This change captures its intended behaviour as a set of verifiable requirements — no code changes.

## Goals / Non-Goals

**Goals:**
- Produce one spec file per logical capability (6 total) that completely describes the observable behaviour of the existing implementation
- Each spec serves as: (a) a regression baseline for future changes, (b) a review target for AI-assisted modifications, and (c) onboarding documentation

**Non-Goals:**
- Changing any code; this is documentation only
- Specifying internal helper functions (find_git_root, find_page_entry, etc.) — only observable, user-facing behaviour is specified
- Covering error messages at the exact string level

## Decisions

### One spec file per logical subsystem
Six capabilities maps cleanly to six spec files. Alternatives considered: one monolithic spec (hard to navigate), two files publish/everything-else (loses granularity). Six files keeps each spec focused and independently referenceable.

### Specify observable behaviour, not internal implementation
Specs describe WHEN/THEN scenarios a user or test can verify. Internal helpers are not specced — they are implementation details. This makes specs resilient to future refactors.

### Use ADDED Requirements throughout
Since no prior specs exist for this workflow, all requirements are `ADDED`. There are no `MODIFIED` or `REMOVED` entries.

## Risks / Trade-offs

- [Risk] Specs may drift from the implementation over time → Mitigation: specs are the source of truth; future code changes must update the relevant spec.
- [Trade-off] Speccing existing behaviour means we might document bugs as intended behaviour → Acceptable; a separate change can fix bugs and update specs simultaneously.
