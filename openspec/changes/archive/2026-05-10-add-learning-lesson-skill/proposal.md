## Why

Adding a new lesson to the learning series currently requires manually following implicit conventions (file naming, nav link format, README index update, section structure, REPL prompt style). Without a codified skill, new lessons risk inconsistency in format, missing nav updates, or broken index links. A dedicated skill makes lesson creation reliable and repeatable.

## What Changes

- Add `.github/skills/add-learning-lesson/SKILL.md` — a skill that guides end-to-end creation of a new learning lesson: reads the existing series, determines the correct filename and number, authors the lesson in the established format, updates the README index, and wires prev/next navigation links

## Capabilities

### New Capabilities

- `learning-lesson-skill`: A Copilot skill (`add-learning-lesson`) that encodes all conventions for the `docs/learning/<lang>/` series structure — lesson format, nav linking, README index maintenance, and the distinction between core lessons and deep-dive lessons.

### Modified Capabilities

_(none)_

## Impact

- `.github/skills/add-learning-lesson/` — new skill directory with `SKILL.md`
- No Lua code, plugin, or documentation changes beyond the skill file itself
