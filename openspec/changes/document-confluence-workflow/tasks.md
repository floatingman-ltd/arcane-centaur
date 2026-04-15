## 1. Spec Files

- [ ] 1.1 Verify `specs/confluence-publish/spec.md` covers publish pipeline, script resolution, and non-blocking behaviour
- [ ] 1.2 Verify `specs/confluence-pull/spec.md` covers pull, backup creation, and credential check
- [ ] 1.3 Verify `specs/confluence-comments/spec.md` covers fetch, sidecar overwrite, and credential check
- [ ] 1.4 Verify `specs/confluence-conflict-detection/spec.md` covers state persistence, stale-version dialog, and no-conflict fast path
- [ ] 1.5 Verify `specs/confluence-page-map/spec.md` covers map format, path normalisation, git-root resolution, and not-found error
- [ ] 1.6 Verify `specs/confluence-filter-pipeline/spec.md` covers filter resolution, link substitution, code macros, and PlantUML rendering

## 2. Cross-check Against Implementation

- [ ] 2.1 Read `lua/config/confluence.lua` `M.publish()` and confirm all observable behaviours are covered by `confluence-publish` spec
- [ ] 2.2 Read `lua/config/confluence.lua` `M.pull()` and confirm all observable behaviours are covered by `confluence-pull` spec
- [ ] 2.3 Read `lua/config/confluence.lua` `M.fetch_comments()` and confirm all observable behaviours are covered by `confluence-comments` spec
- [ ] 2.4 Read `state_read()` / `state_write()` and confirm conflict detection spec matches the implementation
- [ ] 2.5 Read `find_page_entry()` and confirm page-map spec matches the lookup algorithm including path normalisation
- [ ] 2.6 Read `scripts/confluence_filter.lua` and confirm filter-pipeline spec matches the filter's capabilities

## 3. Documentation Consistency

- [ ] 3.1 Verify `docs/guides/confluence.md` is consistent with the new specs (no contradictions)
- [ ] 3.2 Update `docs/guides/confluence.md` if any discrepancies are found
