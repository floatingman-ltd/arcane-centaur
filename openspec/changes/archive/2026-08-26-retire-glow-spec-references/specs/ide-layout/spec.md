## MODIFIED Requirements

### Requirement: Floating UIs unaffected
The IDE layout SHALL NOT alter the behavior or extent of floating windows (the Markdown preview popup, the `<leader>?` cheatsheet float, which-key hints, Conjure HUD/eval popups, the Claude CLI scratch window).

#### Scenario: Popup over the assembled layout
- **WHEN** a Markdown preview popup or which-key hint is triggered while the IDE layout is assembled
- **THEN** the float renders above the splits at its usual size and position
