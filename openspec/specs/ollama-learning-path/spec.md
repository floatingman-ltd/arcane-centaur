# Spec: ollama-learning-path

## Purpose

Define the requirements for the Ollama learning path — a seven-lesson interactive series
teaching users to set up, use, and extend Ollama-powered AI assistance within this Neovim
configuration. Follows the same structure and conventions as the Janet learning series.

## Requirements

### Requirement: Seven core lessons exist as Antora pages
The seven core lessons of the Ollama learning path SHALL each have a hand-authored AsciiDoc
file at `docs/modules/ROOT/pages/learning/ollama/NN-topic.adoc`. No Markdown copies SHALL
be created alongside these `.adoc` files.

#### Scenario: All core lessons are accessible
- **WHEN** a reader navigates to the Ollama learning section of the docs site
- **THEN** lessons 01 through 07 SHALL each be accessible as an Antora page

### Requirement: Series index exists as an Antora page
A `docs/modules/ROOT/pages/learning/ollama/index.adoc` page SHALL exist listing all seven
core lessons with xref links and a Deep-Dives section stub (marked "none yet") that
supports future additions at lesson 08+ without renaming existing files.

#### Scenario: Index lists core lessons and deep-dives section
- **WHEN** a reader opens the Ollama learning section
- **THEN** the index SHALL list all seven core lessons with titles and brief topic descriptions
- **THEN** the index SHALL include a Deep-Dives section (may be empty/stubbed)

### Requirement: Each lesson has a consistent nav bar
Every lesson page SHALL include a `← Previous | Index | Next →` nav bar using AsciiDoc
xref format. Lesson 01 SHALL omit `← Previous`. Lesson 07 SHALL omit `Next →`.

#### Scenario: Middle lesson nav bar
- **WHEN** a reader opens lesson 04 (Code Assistance)
- **THEN** the nav bar SHALL link to lesson 03, the index, and lesson 05

#### Scenario: Last lesson nav bar
- **WHEN** a reader opens lesson 07 (The API)
- **THEN** the nav bar SHALL link to lesson 06 and the index
- **THEN** there SHALL be no `Next →` link

### Requirement: Each lesson uses the two-surface interaction model
Every lesson SHALL use one or both of:
- **Shell steps**: a command block followed by "Confirm you see: `<expected output>`"
- **Avante steps**: an instruction to open `<leader>ao` with a specific prompt and
  description of expected behaviour

No lesson SHALL contain exercises that require tools outside of Docker, the shell, and
Avante as configured in this repo.

#### Scenario: Shell verification step
- **WHEN** a reader encounters a shell step in any lesson
- **THEN** the step SHALL include a command block and a "Confirm you see:" line specifying expected output

#### Scenario: Avante exercise step
- **WHEN** a reader encounters an Avante step in any lesson
- **THEN** the step SHALL specify the keymap to use, the exact prompt to send, and the expected behaviour

### Requirement: Lesson 01 covers full interactive setup and verification
`01-setup.adoc` SHALL cover: prerequisites checklist, starting the Docker service,
health-checking the API endpoint, a RAM-based model selection decision, pulling the chosen
model, verifying the model list, connecting via Avante, and a smoke-test prompt. A
troubleshooting section SHALL cover common failure modes.

#### Scenario: Reader can verify Ollama is working end-to-end
- **WHEN** a reader completes lesson 01
- **THEN** they SHALL have confirmed the Docker service is running, a model is pulled,
  and Avante returns a response to a test prompt

### Requirement: Lesson 05 covers model selection and switching
`05-model-selection.adoc` SHALL cover: the RAM/speed/quality tradeoff, the two default
model options (`llama3.1:8b`, `llama3.2:3b`), how to pull a different model, and how to
update the active model in `avante.lua`. It SHALL reference deep-dives (08+) for in-depth
model family coverage.

#### Scenario: Reader can switch models
- **WHEN** a reader completes lesson 05
- **THEN** they SHALL know how to pull a new model and update `avante.lua` to use it

### Requirement: Nav sidebar lists the Ollama learning path
`docs/modules/ROOT/nav.adoc` SHALL list the Ollama series index and lessons 01–07 under
the Learning section, following the same pattern as the Janet series.

#### Scenario: Ollama lessons appear in sidebar
- **WHEN** a reader opens the docs site
- **THEN** the Ollama series index and all seven core lessons SHALL appear in the nav sidebar
