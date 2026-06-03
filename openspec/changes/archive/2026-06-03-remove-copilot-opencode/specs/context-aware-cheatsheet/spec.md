## MODIFIED Requirements

### Requirement: Universal core section always present
The floating window SHALL always display a universal core section covering LSP bindings, window/split navigation, git (fugitive, gitsigns, diffview), the Claude CLI, visual editing, system clipboard, formatting, and auto-completion.

#### Scenario: Core content visible regardless of filetype
- **WHEN** the cheatsheet float is opened from any buffer
- **THEN** LSP keybindings (gd, K, gr, leader+rn, leader+ca, leader+e, [d, ]d) are present in the float content

#### Scenario: Core content visible for unknown filetype
- **WHEN** the cheatsheet float is opened from a buffer whose filetype has no mapping (e.g. `text`, `sh`, ``)
- **THEN** the float displays core content and no language-specific section
