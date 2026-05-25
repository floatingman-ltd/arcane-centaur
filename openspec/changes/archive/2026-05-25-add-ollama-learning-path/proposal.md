## Why

The Ollama tooling (Docker service + Avante) is installed and specced but there is no
interactive learning content. A user who has the config working has no guided path to
go from "it's running" to confidently using Ollama for real work inside Neovim.

## What Changes

- Add `docs/modules/ROOT/pages/learning/ollama/` — a new learning path section
- Add `index.adoc` — series landing page with Core and Deep-Dives sections
- Add `01-setup.adoc` — interactive setup and verification lesson
- Add `02-first-conversations.adoc` — Avante interface, basic chat, switching providers
- Add `03-prompting-fundamentals.adoc` — specificity, context, role-setting
- Add `04-code-assistance.adoc` — selection → ask workflow in this config
- Add `05-model-selection.adoc` — choosing and switching models, RAM tradeoffs
- Add `06-system-prompts.adoc` — shaping behaviour, context window limits
- Add `07-the-api.adoc` — Ollama HTTP API, what Avante does under the hood
- Update `docs/modules/ROOT/nav.adoc` — add Ollama under the Learning section

## Capabilities

### New Capabilities

- `ollama-learning-path`: A seven-lesson interactive learning path for Ollama in this
  Neovim configuration, with an index supporting future deep-dive additions (08+) without
  renaming existing files. Interaction model: shell verification steps ("run this, confirm
  you see: …") and Avante prompts ("open `<leader>ao`, ask: '…', you should see: …").

### Modified Capabilities

_(none — no existing spec-level behavior is changing)_

## Impact

- `docs/modules/ROOT/pages/learning/ollama/` — all new files, documentation only
- `docs/modules/ROOT/nav.adoc` — new Ollama entry under Learning
- No Lua code changes
- No plugin, keymap, or Docker configuration changes
