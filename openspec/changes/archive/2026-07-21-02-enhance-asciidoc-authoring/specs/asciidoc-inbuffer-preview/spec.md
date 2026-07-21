## ADDED Requirements

### Requirement: Opt-in in-buffer AsciiDoc rendering
AsciiDoc buffers SHALL support an opt-in, toggle-able in-buffer rendered view via `OXY2DEV/markview.nvim`. Rendering SHALL start disabled and be controlled by a buffer-local toggle, so editing is unaffected until the user requests a rendered view.

#### Scenario: Rendering is off by default
- **WHEN** the user opens an AsciiDoc buffer
- **THEN** markview rendering SHALL NOT be active and the raw markup SHALL be shown

#### Scenario: Toggle renders the buffer in place
- **WHEN** the user invokes the markview toggle (`<localleader>mv`) in an AsciiDoc buffer
- **THEN** AsciiDoc elements (headings, emphasis, lists) SHALL be rendered in-buffer via extmarks, without leaving Neovim or invoking Docker

#### Scenario: Toggle off restores raw markup
- **WHEN** the user toggles markview off
- **THEN** the buffer SHALL return to showing raw AsciiDoc markup

### Requirement: In-buffer preview coexists with the Docker preview and the Markdown workflow
markview SHALL be additive: the Docker/Antora browser preview SHALL remain available, and the Markdown preview workflow SHALL be unaffected.

#### Scenario: Docker preview unaffected by markview
- **WHEN** markview is installed (whether toggled on or off)
- **THEN** the `<localleader>p`/`pp`/`pa` Docker/Antora preview maps SHALL still function

#### Scenario: Markdown workflow untouched
- **WHEN** the user opens a Markdown buffer
- **THEN** markview SHALL NOT activate for it, and markdown-preview.nvim / glow.nvim SHALL behave exactly as before this change
