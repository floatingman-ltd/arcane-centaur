# asciidoc-inbuffer-preview Specification

## Purpose
Specifies an opt-in, toggle-able rendered view of an AsciiDoc buffer, drawn in place with extmarks by `OXY2DEV/markview.nvim`, so a document can be read as formatted text without leaving Neovim or starting Docker. Rendering starts disabled, because the capability is for reading rather than for editing.

**Not implemented.** markview is not installed and no `<localleader>mv` toggle exists: it depends on `cathaysia/tree-sitter-asciidoc`, which is absent from nvim-treesitter, and the work was deferred rather than abandoned — see the note at `lua/plugins/asciidoc.lua`. The requirements below therefore describe intended behaviour, not current behaviour.

The Docker/Antora browser preview remains the only rendered view of AsciiDoc available today. That is exactly why the second requirement matters when the grammar does land: this capability has to be purely additive, leaving both the Docker preview and the whole Markdown rendering path untouched.

## Requirements
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
- **THEN** markview SHALL NOT activate for it
- **AND** the Markdown preview surfaces SHALL continue to work: `markdown-preview.nvim` in a GUI environment, and the in-editor popup (`:MarkdownPopup`) in a console
- **AND** `<localleader>pp` SHALL continue to toggle in-buffer Markdown rendering

