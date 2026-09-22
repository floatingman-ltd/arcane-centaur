## ADDED Requirements

### Requirement: Diagram blocks in AsciiDoc pages render to images at build time
The Antora build SHALL convert diagram blocks in `docs/modules/ROOT/pages/**/*.adoc` into images. `antora-playbook.yml` SHALL register `asciidoctor-kroki` under `asciidoc.extensions`, and the package SHALL be pinned to the `0.x` release line because versions 1.0.0 and above require Asciidoctor.js 4, which Antora 3 does not ship.

#### Scenario: A page containing a diagram block is built
- **WHEN** a page contains a `[plantuml]` block and the site is built
- **THEN** the rendered page SHALL contain an image element for that diagram
- **AND** the diagram source SHALL NOT appear as a code block in the output

#### Scenario: A page containing no diagram block is unaffected
- **WHEN** a page with no diagram block is built
- **THEN** its output SHALL be unchanged from a build without the extension registered

#### Scenario: The extension version is constrained
- **WHEN** the extension is installed
- **THEN** it SHALL resolve to a `0.x` version
- **AND** a 1.x version SHALL NOT be used while Antora 3 is in use

### Requirement: Diagrams are rendered by a self-hosted service
Rendering SHALL be performed by a Kroki service run from `docker/kroki/`, not by a public instance. Documentation content SHALL NOT be sent to a third-party renderer during the build.

The service SHALL listen on a port that does not collide with the existing PlantUML server on 8080.

#### Scenario: Rendering is local
- **WHEN** the site is built
- **THEN** diagram payloads SHALL be sent only to the locally run Kroki service
- **AND** no request SHALL be made to a public rendering service

#### Scenario: Ports do not collide
- **WHEN** both the PlantUML server and Kroki are running
- **THEN** both SHALL be reachable
- **AND** neither SHALL fail to start because the other holds its port

### Requirement: Published pages do not reference a local renderer
Images in the published site SHALL be retrievable by a reader who has no access to the machine that built the site. A page whose image sources point at a `localhost` Kroki address SHALL be treated as a build failure rather than a success.

#### Scenario: Reader on another machine opens a page with a diagram
- **WHEN** a reader opens a published page containing a diagram
- **THEN** the image SHALL render
- **AND** its source SHALL NOT be a `localhost` URL

### Requirement: A missing renderer fails the build rather than publishing a gap
When the Kroki service is unreachable, the build SHALL fail with a message naming the service. It SHALL NOT produce a page with a broken or absent image.

This is deliberately stricter than the graceful degradation applied to editor tooling elsewhere in this repository. A missing formatter or language server inconveniences one person immediately and visibly; a silently diagram-free page is published and read by people who cannot tell a diagram was intended.

#### Scenario: Kroki is not running
- **WHEN** the site is built with no Kroki service reachable
- **THEN** the build SHALL fail
- **AND** the message SHALL name the missing service
- **AND** no page SHALL be published containing a broken image reference

#### Scenario: The build prerequisite is documented
- **WHEN** a reader consults the documentation build instructions
- **THEN** the requirement for a running Kroki service SHALL be stated
- **AND** the command to start it SHALL be given

### Requirement: In-editor diagram preview is unchanged
This capability governs the site build only. `:PumlPreview`, `:PumlPreviewAscii`, markdown-preview.nvim's PlantUML rendering and the Confluence publisher SHALL continue to use the PlantUML server on port 8080, and SHALL NOT be routed through Kroki by this change.

#### Scenario: Editor preview after the change
- **WHEN** the user runs `:PumlPreview` or `:PumlPreviewAscii` in a `plantuml` buffer
- **THEN** the behaviour SHALL be identical to before this change
- **AND** it SHALL NOT require the Kroki service to be running
