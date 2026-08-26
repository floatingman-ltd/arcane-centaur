## MODIFIED Requirements

### Requirement: In-buffer preview coexists with the Docker preview and the Markdown workflow
markview SHALL be additive: the Docker/Antora browser preview SHALL remain available, and the Markdown preview workflow SHALL be unaffected.

#### Scenario: Docker preview unaffected by markview
- **WHEN** markview is installed (whether toggled on or off)
- **THEN** the `<localleader>p`/`pp`/`pa` Docker/Antora preview maps SHALL still function

#### Scenario: Markdown workflow untouched
- **WHEN** the user opens a Markdown buffer
- **THEN** markview SHALL NOT activate for it
- **AND** the Markdown preview surfaces SHALL continue to work: `markdown-preview.nvim` in a GUI environment, and the in-editor popup (`:MarkdownPopup`) in a console
- **AND** `<localleader>pp` SHALL continue to toggle in-buffer Markdown rendering
