## Purpose

Defines the per-plugin documentation page model: one Antora page per plugin, opening with a
plain-language description and then that plugin's keymaps, replacing the per-area guide+cheatsheet
split for migrated areas.

## Requirements

### Requirement: One documentation page per plugin

Each plugin/extension that the user interacts with SHALL have its own Antora page under its area directory (e.g. `docs/modules/ROOT/pages/editor/git/<plugin>.adoc`), rather than being documented interleaved with other plugins in a shared area guide or cheatsheet. Plugins that form one workflow (e.g. vim-fugitive, gitsigns, diffview) SHALL each get a separate page.

#### Scenario: Git area is three plugin pages

- **WHEN** the `docs/modules/ROOT/pages/editor/git/` directory is listed
- **THEN** it contains one page each for `vim-fugitive`, `gitsigns`, and `diffview`
- **AND** the former `editor/git.adoc` and `editor/git-cheatsheet.adoc` no longer exist

#### Scenario: A plugin's keymaps live on exactly one page

- **WHEN** a reader looks for a given plugin's keymaps in the web docs
- **THEN** they appear on that plugin's page
- **AND** they are not duplicated on any other Antora page

### Requirement: Plugin page opens with a BA-level description then keymaps

Every plugin page SHALL begin with a brief, plain-language ("BA-level") description of what the plugin does and why it is useful — free of Neovim jargon — immediately followed by that plugin's keymaps. Setup or prerequisite notes, if any, SHALL appear after the keymaps, not before the description.

#### Scenario: Description precedes keymaps

- **WHEN** a reader opens any plugin page
- **THEN** the first substantive content is a plain-language description of the plugin
- **AND** the keymap table(s) follow that description

#### Scenario: Keymaps are complete and accurate

- **WHEN** a plugin page documents keymaps
- **THEN** every keymap listed matches a keymap actually bound for that plugin in the config
- **AND** no keymap bound for that plugin is omitted from its page

### Requirement: Plugin page points to the in-editor keymap surfaces

Each plugin page SHALL note that which-key (live popups, generated from each keymap's `desc`) and the `<leader>?` context-aware cheatsheet are the in-editor equivalents, so a reader knows where the authoritative live view is.

#### Scenario: Page references the live surfaces

- **WHEN** a reader reaches the end of a plugin page
- **THEN** it references which-key and/or `<leader>?` as the in-editor keymap reference
