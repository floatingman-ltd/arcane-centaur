## Purpose

Defines the structural template all documentation guides in this repository must follow.

## Requirements

### Requirement: Guides follow usage-first structure
Every guide in `documentation/guides/` SHALL follow a consistent section order:
1. Title and one-line summary
2. Dynamic jump menu (links only to sections present in that guide)
3. Quick Start (always first body section)
4. Capability sections (LSP, REPL, Preview, etc.) in logical order
5. Typical Workflow (always last body section before the horizontal rule)
6. `---` horizontal rule separating body from reference sections
7. Troubleshooting (only if known failure modes exist)
8. Setup (only if non-trivial install steps are required)
9. Prerequisites (dependency table: Dependency | Purpose | Install hint)

#### Scenario: Guide opens with usage content
- **WHEN** a reader opens any guide
- **THEN** Quick Start SHALL be the first substantive section after the jump menu
- **THEN** no install or setup instructions SHALL appear before Quick Start

#### Scenario: Setup sections appear at bottom
- **WHEN** a guide contains Prerequisites and Setup sections
- **THEN** they SHALL appear after the `---` separator
- **THEN** Troubleshooting SHALL appear before Setup, and Setup before Prerequisites

### Requirement: Dynamic jump menu present in all guides
Each guide SHALL include a jump menu immediately below the title/summary. The jump menu
SHALL contain only anchor links to sections that exist in that specific guide. Sections
that do not exist in a guide SHALL NOT have a placeholder or dead link in its menu.

#### Scenario: Jump menu reflects actual sections
- **WHEN** a guide has LSP and REPL sections but no Troubleshooting section
- **THEN** the jump menu SHALL link to LSP and REPL
- **THEN** the jump menu SHALL NOT contain a Troubleshooting link

#### Scenario: Jump menu always includes reference section links
- **WHEN** a guide has a Prerequisites section
- **THEN** the jump menu SHALL include a link to Prerequisites
- **THEN** first-time readers can navigate directly to setup from the top of the page

### Requirement: Prerequisites and Setup are distinct sections
Guides SHALL separate dependency declarations (Prerequisites) from install procedures
(Setup). Prerequisites SHALL be a table listing what is needed. Setup SHALL contain
step-by-step install instructions. Content currently interleaved between the two SHALL
be split accordingly.

#### Scenario: Prerequisites section is a table
- **WHEN** a guide has a Prerequisites section
- **THEN** it SHALL contain a table with columns: Dependency | Purpose | Install hint
- **THEN** it SHALL NOT contain multi-step shell command blocks

#### Scenario: Complex installs go in Setup
- **WHEN** installing a dependency requires more than a single shell command
- **THEN** the procedure SHALL appear in the Setup section, not Prerequisites
