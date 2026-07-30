## MODIFIED Requirements

### Requirement: Guides and cheatsheets co-located per topic group

Within each topic group in the nav, an area that has NOT been migrated to the per-plugin page model SHALL list its guide AND cheatsheet together, with the guide before the cheatsheet. An area that HAS been migrated to the per-plugin page model (see the `docs-plugin-page` capability) SHALL instead list one entry per plugin page under that area, and SHALL NOT retain a separate guide+cheatsheet pair for the migrated plugins.

#### Scenario: Git group lists per-plugin pages

- **WHEN** a reader browses the Editor Core group
- **THEN** the Git entries are one nav entry each for the vim-fugitive, gitsigns, and diffview pages
- **AND** no "Git Guide" or "Git Cheatsheet" nav entry remains

#### Scenario: Unmigrated areas keep guide+cheatsheet co-location

- **WHEN** a reader browses an area not yet migrated to the per-plugin model
- **THEN** that area's guide and cheatsheet still appear together, guide before cheatsheet
