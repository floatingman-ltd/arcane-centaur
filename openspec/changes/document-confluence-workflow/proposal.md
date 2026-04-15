## Why

The Confluence workflow in `lua/config/confluence.lua` is a substantial, feature-rich system (publish, pull, comments, conflict detection, filter pipeline) but has no specification document. This makes it hard to understand the intended behaviour, validate that the implementation is correct, and safely extend or modify the workflow in the future. Completely documenting it now creates a stable reference for both human contributors and AI-assisted changes.

## What Changes

- Add a spec for the Confluence publish workflow (markdown → Confluence via pandoc + REST API)
- Add a spec for the Confluence pull workflow (Confluence → local markdown via pandoc)
- Add a spec for the Confluence comment-fetch workflow
- Add a spec for conflict detection (version-tracking via `.confluence-state.json`)
- Add a spec for the page-map resolution (mapping local files to Confluence URLs)
- Add a spec for the filter pipeline (`confluence_filter.lua` — link substitution, code macros, PlantUML)
- No code changes; documentation / specification only

## Capabilities

### New Capabilities

- `confluence-publish`: Full specification of the publish workflow: page-map lookup, script/filter resolution, pandoc conversion, conflict check, and REST PUT
- `confluence-pull`: Specification of the pull workflow: GET page body, pandoc back-conversion, `.bak` backup, and local file overwrite
- `confluence-comments`: Specification of the comment-fetch workflow: GET comments, write to sidecar `.comments.md`
- `confluence-conflict-detection`: Specification of the version-state system (`.confluence-state.json`, stale-version dialog)
- `confluence-page-map`: Specification of the page-map file format and lookup algorithm
- `confluence-filter-pipeline`: Specification of the optional Lua filter (link substitution, code macros, PlantUML rendering)

### Modified Capabilities

<!-- No existing specs; all capabilities are new documentation -->

## Impact

- No code changes; no existing behaviour is modified
- New files: `openspec/specs/confluence-*/spec.md` (6 spec files)
- Provides a baseline for future confluence-related changes to reference
