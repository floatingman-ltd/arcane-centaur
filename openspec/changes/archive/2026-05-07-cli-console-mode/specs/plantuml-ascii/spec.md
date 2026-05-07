## ADDED Requirements

### Requirement: PumlPreviewAscii command always available
A `:PumlPreviewAscii` user command SHALL be registered for `plantuml` filetype buffers
in all environments (console and GUI). It SHALL fetch the plain ASCII rendering from the
PlantUML Docker server's `/txt/` endpoint and display the result in a scratch buffer.

> **Known limitation:** The `/utxt/` endpoint (Unicode box-drawing characters) is not
> supported by the current `plantuml/plantuml-server:jetty` image. Plain ASCII (`/txt/`)
> is used instead. Upgrading to a `/utxt/`-capable image is a future enhancement.

#### Scenario: ASCII preview fetches from txt endpoint
- **WHEN** `:PumlPreviewAscii` is invoked on a plantuml buffer
- **THEN** the buffer content SHALL be encoded using the existing PlantUML encoding logic
- **THEN** a request SHALL be made to `http://localhost:8080/txt/<encoded>`
- **THEN** the text response SHALL be written into a new scratch buffer

### Requirement: ASCII output displayed in scratch buffer
The scratch buffer used by `:PumlPreviewAscii` SHALL have `buftype=nofile` and
`bufhidden=wipe`. It SHALL open in a vertical split. It SHALL not prompt to save on
close.

#### Scenario: Scratch buffer properties
- **WHEN** `:PumlPreviewAscii` produces output
- **THEN** the result SHALL appear in a vertical split with `buftype=nofile`
- **THEN** closing the buffer SHALL not prompt for save

### Requirement: Console default routes PlantUML to ASCII
When `term.is_console` is `true`, `:PumlPreview` SHALL behave identically to
`:PumlPreviewAscii`. The PNG path (`:PumlPreview` → `/png/` → browser) SHALL only be
registered when `term.is_console` is `false`.

#### Scenario: Console PumlPreview uses ASCII path
- **WHEN** `term.is_console` is `true` and `:PumlPreview` is invoked
- **THEN** the plain ASCII art SHALL be fetched and shown in a scratch buffer

#### Scenario: GUI PumlPreview uses PNG path
- **WHEN** `term.is_console` is `false` and `:PumlPreview` is invoked
- **THEN** the PNG URL SHALL be opened via `util.open_url` as before

### Requirement: Encoding failure handled
If the Python encoding step fails, `:PumlPreviewAscii` SHALL emit an ERROR notification
and SHALL not attempt to open a scratch buffer.

#### Scenario: Encoding failure
- **WHEN** the Python encoding command exits with a non-zero status
- **THEN** an ERROR notification SHALL be shown
- **THEN** no scratch buffer SHALL be opened
