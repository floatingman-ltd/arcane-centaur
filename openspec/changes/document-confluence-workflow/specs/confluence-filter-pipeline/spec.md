## ADDED Requirements

### Requirement: Filter pipeline enhances pandoc output when confluence_filter.lua is present
When `confluence_filter.lua` is found (via `CONFLUENCE_FILTER_LUA` env var, `~/.config/nvim/scripts/`, or `<git-root>/scripts/`), the system SHALL pass it to pandoc as a Lua filter during publish, enabling link substitution, code-macro conversion, and PlantUML rendering. If the filter is not found, publish SHALL proceed with basic pandoc conversion only.

#### Scenario: Filter applied when present
- **WHEN** `confluence_filter.lua` is found in the standard location and `,cc` is run
- **THEN** pandoc is invoked with `--lua-filter=<path>` and the output includes enhanced macros

#### Scenario: Publish succeeds without filter
- **WHEN** `confluence_filter.lua` is not found in any location
- **THEN** pandoc runs without a Lua filter and basic conversion output is uploaded

### Requirement: Filter substitutes relative markdown links with Confluence URLs
The filter SHALL replace relative markdown links (`[text](../other.md)`) with the corresponding Confluence page URL from the page map, so cross-page links remain valid in Confluence.

#### Scenario: Relative link substituted
- **WHEN** the markdown file contains a relative link to another file that is in the page map
- **THEN** the published Confluence page contains the Confluence URL in place of the relative path

#### Scenario: Link target not in page map
- **WHEN** the markdown file contains a relative link to a file not in the page map
- **THEN** the link is left unchanged in the published output

### Requirement: Filter converts fenced code blocks to Confluence code macros
The filter SHALL convert standard markdown fenced code blocks to Confluence `ac:structured-macro` code blocks, preserving the language identifier.

#### Scenario: Code block converted to macro
- **WHEN** the markdown contains ` ```python … ``` `
- **THEN** the published Confluence page contains an `ac:structured-macro` code block with `language="python"`

### Requirement: Filter renders plantuml fences as inline PNG images
The filter SHALL send the content of `plantuml` fenced code blocks to the local PlantUML server and embed the resulting PNG as an inline image in the Confluence page.

#### Scenario: PlantUML diagram rendered
- **WHEN** the markdown contains a ` ```plantuml … ``` ` fence and the PlantUML server is running
- **THEN** the published Confluence page contains an inline PNG image of the diagram

#### Scenario: PlantUML server unavailable
- **WHEN** the PlantUML server is not running and a `plantuml` fence is present
- **THEN** the publish fails or the block is left as a code macro, and an error or warning is shown
