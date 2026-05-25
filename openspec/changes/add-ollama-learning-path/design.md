## Context

The Ollama Docker service and Avante integration are fully implemented and specced. A user
who follows the getting-started guide has Ollama running and Avante configured, but there
is no interactive learning content — only reference documentation in `ai-tools.adoc`.

The Janet learning series established the pattern for interactive learning content in this
repo: linear lessons, hand-authored AsciiDoc, REPL-driven exercises with consistent "Try it"
prompts. The Ollama path follows the same convention.

## Goals / Non-Goals

**Goals:**
- Seven core lessons (01–07) covering the complete workflow from setup to the raw API
- An index page with Core and Deep-Dives sections (08+ reserved, none yet)
- A consistent interaction model: shell verification steps and Avante prompt exercises
- Nav sidebar updated to list the Ollama series under Learning
- Naming convention that supports appending deep-dives without renaming existing files

**Non-Goals:**
- Changing any Lua, Docker, or plugin configuration
- Adding new keymaps or Avante configuration
- Writing deep-dive lessons (08+) — those are future additions
- Covering Ollama concepts beyond this config's toolchain (no general Ollama CLI usage,
  no REST API library integrations)

## Decisions

### 1. Mirror the Janet series structure exactly

**Decision:** Use the same file layout, nav pattern, and lesson shape as the Janet series:
`docs/modules/ROOT/pages/learning/ollama/NN-topic.adoc`, an `index.adoc` landing page,
and `← Previous | Index | Next →` nav bars using `xref:` links.

**Rationale:** Consistency lowers the cognitive load for both readers and future contributors.
The Janet pattern was deliberately designed to be reusable for other learning paths.

**Alternative considered:** A single long guide page. Rejected: loses the interactive
lesson rhythm and makes it harder to link to specific topics.

### 2. Two-surface interaction model

**Decision:** Each lesson alternates between two types of interactive step:
- **Shell steps**: `Run this command. Confirm you see: <expected output>`
- **Avante steps**: `Open <leader>ao. Ask: '<prompt>'. You should see: <expected behaviour>`

**Rationale:** Ollama has no REPL equivalent to Conjure's `,ee`. The two-surface model
provides the same "do and verify" rhythm without pretending otherwise. Shell steps handle
infrastructure verification; Avante steps handle AI interaction exercises.

### 3. Lesson 01 is a full interactive setup lesson, not a pointer to ai-tools.adoc

**Decision:** Write `01-setup.adoc` as a self-contained interactive lesson with
prerequisites, progressive verification steps, a RAM-based model decision tree, and a
troubleshooting section. It is the interactive companion to `ai-tools.adoc`, not a
replacement.

**Rationale:** A reader starting the learning path should not need to jump between documents.
The reference guide (`ai-tools.adoc`) remains the authoritative quick-reference; the lesson
provides the guided first-time experience.

### 4. Lesson 05 covers model switching only; deep-dives are 08+

**Decision:** `05-model-selection.adoc` covers the mechanics of choosing and switching
models (RAM tradeoffs, pulling, updating `avante.lua`). It does not attempt to survey the
model landscape in depth. Deep-dives on specific model families (Llama, code-optimised,
embedding) are reserved for lessons 08+ and are not in scope for this change.

**Rationale:** Keeps the core path at a consistent depth. Model landscape evolves quickly;
separating it into deep-dives means updates don't require touching core lessons.

## Risks / Trade-offs

- **Avante prompt exercises are non-deterministic** → LLM outputs vary. Exercises use
  prompts designed for stable, verifiable responses (e.g., "Reply with exactly: X") for
  smoke tests, and open-ended prompts for exploration sections where exact output doesn't matter.
- **Model availability changes** → `llama3.1:8b` and `llama3.2:3b` are current defaults.
  If Ollama deprecates these tags, model names in lessons become stale. Mitigation: model
  names in lessons are clearly labelled as "current default — check `avante.lua` if this
  has changed."
- **Shell command path is long** → `docker compose -f ~/.config/nvim/docker/ollama/docker-compose.yml`
  is verbose. Lessons use the full path consistently rather than assuming a working directory,
  matching the pattern in `ai-tools.adoc`.
