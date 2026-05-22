# OpenSpec Branch Convention

Every new OpenSpec change MUST have a matching git branch created BEFORE any work begins.

## Rule
- `openspec new change <name>` → immediately `git checkout -b feat/<name>`
- All proposal, spec, design, task, and implementation commits go on that branch
- Never commit OpenSpec artifacts directly to `main`

## Branch naming
- Feature work: `feat/<change-name>`
- Fix work: `fix/<change-name>`
- Match the OpenSpec change name exactly (e.g. change `restructure-docs` → branch `feat/restructure-docs`)

## Background
Established after the `restructure-docs` proposal was accidentally committed to `main` and had to be retroactively moved to `feat/restructure-docs`.
