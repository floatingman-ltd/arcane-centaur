## ADDED Requirements

### Requirement: GFM alert blockquotes render as styled admonitions

The preview server SHALL render a blockquote whose first line is a GFM alert marker — `[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]` or `[!CAUTION]` — as a titled admonition rather than as a blockquote containing the literal marker text. The marker SHALL NOT appear in the rendered output. Each type SHALL carry its own accent colour and GitHub octicon so the category is distinguishable at a glance without reading the title.

#### Scenario: A note alert renders with its title and colour

- **WHEN** a served markdown file contains a blockquote beginning `> [!NOTE]`
- **THEN** the rendered HTML SHALL contain an element with classes `markdown-alert` and `markdown-alert-note`
- **AND** it SHALL contain a title element reading `Note`
- **AND** the literal text `[!NOTE]` SHALL NOT appear anywhere in the rendered output

#### Scenario: All five alert types are supported

- **WHEN** a served markdown file contains one blockquote for each of `[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]` and `[!CAUTION]`
- **THEN** the rendered HTML SHALL contain five distinct alert elements
- **AND** each SHALL carry the type-specific class for its marker
- **AND** each SHALL be given a visually distinct accent colour

#### Scenario: Alert body content is rendered as markdown

- **WHEN** an alert blockquote contains multiple paragraphs, a list, inline code or a link
- **THEN** that content SHALL be rendered as markdown inside the admonition
- **AND** it SHALL NOT be emitted as literal or pre-formatted text

#### Scenario: An unrecognised marker is left alone

- **WHEN** a blockquote begins with a bracketed word belonging to no configured vocabulary, such as `> [!NONSENSE]`
- **THEN** it SHALL render as an ordinary blockquote showing its literal marker text
- **AND** the server SHALL NOT error
- **AND** this SHALL hold whichever vocabulary is selected

### Requirement: Existing rendering behaviour is preserved

Adding alert support SHALL NOT alter how any other markdown construct is rendered. A document containing no alert syntax SHALL render identically to how it rendered before alert support was added.

#### Scenario: A plain blockquote is unchanged

- **WHEN** a served markdown file contains a blockquote with no alert marker
- **THEN** it SHALL render as a `blockquote` element with the existing left border and muted text colour
- **AND** it SHALL NOT be given any alert class or octicon

#### Scenario: Diagram fences still render

- **WHEN** a served markdown file contains a fenced `plantuml` block and a fenced `mermaid` block
- **THEN** the `plantuml` block SHALL still render as an `img` element pointing at the local PlantUML server
- **AND** the `mermaid` block SHALL still render as a `pre` element with class `mermaid`

#### Scenario: Alerts and diagrams coexist in one document

- **WHEN** a served markdown file contains both alert blockquotes and a `plantuml` fence
- **THEN** both SHALL render correctly in the same page

#### Scenario: Live reload still works

- **WHEN** a served markdown file is modified on disk while a browser has the page open
- **THEN** the browser SHALL reload the page via the `/__livereload` event stream

### Requirement: The container starts on a Node runtime that supports the plugin

The alert plugin is distributed as an ES module with no CommonJS build, while the server is CommonJS. The container image SHALL therefore provide a Node runtime that supports requiring an ES module, and the server SHALL resolve the plugin's exported function through the module namespace object rather than assuming a bare CommonJS export.

Because a runtime that lacks this support causes the server to fail at startup rather than to render alerts unstyled, the base image SHALL be pinned rather than left on a floating tag.

#### Scenario: The server starts and serves an alert after a clean rebuild

- **WHEN** the image is rebuilt from scratch with no layer cache and the container is started
- **THEN** the server SHALL start and log that it is listening
- **AND** a request for a markdown file containing an alert SHALL return HTML containing the alert classes

#### Scenario: The plugin is resolved through its default export

- **WHEN** the server requires the alert plugin
- **THEN** it SHALL use the module's `default` export when one is present
- **AND** it SHALL fall back to the module object itself when no `default` is present, so a future CommonJS build of the plugin continues to work

### Requirement: Alert styling is delivered with the page

The server inlines all of its CSS into the page it generates and has no stylesheet file or static asset route. Alert styling SHALL be delivered the same way, so that rendering a page requires no additional request and no runtime dependency on the layout of installed packages.

#### Scenario: Alert CSS is present in the served page

- **WHEN** a markdown page is served
- **THEN** the response SHALL include the alert rules and the alert colour definitions in its inline style block
- **AND** the page SHALL NOT reference an external stylesheet for them

#### Scenario: Colour definitions accompany the base rules

- **WHEN** the alert base rules are present in the page
- **THEN** the custom properties they reference SHALL also be defined
- **AND** no alert SHALL fall back to an undefined colour

### Requirement: The alert vocabulary is selectable without a rebuild

The set of markers treated as alerts SHALL be selectable at container start between two vocabularies:

- **`gfm`** — the five GitHub markers and nothing else. This SHALL be the default, so that by default the preview shows a document the way GitHub will render it.
- **`extended`** — those five plus the Obsidian markers that the in-buffer renderer already recognises, so that the buffer preview and the browser preview agree.

Selection SHALL be made through an environment variable, not a build argument, so that switching requires only recreating the container and never rebuilding the image.

Under `extended`, each additional marker SHALL take the accent colour and icon of the GFM marker it is grouped with, following the same grouping the in-buffer renderer uses, so no new palette is introduced and the same marker reads the same colour in both previews.

#### Scenario: The default vocabulary is the GitHub five

- **WHEN** the container is started with no vocabulary set
- **THEN** the five GFM markers SHALL render as admonitions
- **AND** a marker outside that set, such as `[!EXAMPLE]`, SHALL render as an ordinary blockquote showing its literal text

#### Scenario: The extended vocabulary renders the Obsidian markers

- **WHEN** the container is started with the vocabulary set to `extended`
- **THEN** markers such as `[!EXAMPLE]`, `[!QUESTION]`, `[!TODO]`, `[!BUG]` and `[!SUCCESS]` SHALL render as admonitions
- **AND** each SHALL carry the accent colour and icon of the GFM marker it is grouped with
- **AND** the five GFM markers SHALL keep their own icons

#### Scenario: Switching vocabulary does not require an image rebuild

- **WHEN** the vocabulary is changed and the container is recreated without rebuilding the image
- **THEN** the new vocabulary SHALL take effect

#### Scenario: Titles that plain capitalisation would get wrong

- **WHEN** the `extended` vocabulary renders `[!TLDR]` or `[!FAQ]`
- **THEN** their titles SHALL read `TL;DR` and `FAQ` rather than `Tldr` and `Faq`

#### Scenario: A marker with no GFM counterpart

- **WHEN** the `extended` vocabulary renders `[!QUOTE]` or `[!CITE]`
- **THEN** they SHALL render as admonitions with a muted accent colour
- **AND** they MAY render without an icon, there being no GFM equivalent to borrow one from
