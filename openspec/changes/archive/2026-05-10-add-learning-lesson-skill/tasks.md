## 1. Skill File

- [x] 1.1 Create `.github/skills/add-learning-lesson/SKILL.md` with the full skill workflow
- [x] 1.2 Write the Preflight section: scan `docs/learning/<lang>/`, read README.md and the two most recent lesson files
- [x] 1.3 Write Step 1 — Classify the lesson (core numbered vs. deep-dive) and determine the correct filename
- [x] 1.4 Write Step 2 — Author the lesson file with all required structural elements (title, nav, numbered sections, Try-it prompts, keymap tables, mini-project, What to Explore Next)
- [x] 1.5 Write Step 3 — Update the README index (create it if absent, add row to Core Lessons or Deep-Dives table)
- [x] 1.6 Write Step 4 — Wire navigation: update previous lesson's Next link; update next lesson's Previous link if inserting mid-series
- [x] 1.7 Write the Output section describing the completion summary the agent should emit

## 2. Convention Documentation

- [x] 2.1 Inline the lesson format conventions into the skill (nav line format, section numbering, Try-it style, mini-project requirements)
- [x] 2.2 Inline the README index format (two-section table: Core Lessons + Deep-Dives)
- [x] 2.3 Inline the filename convention rules (NN- prefix for core, `deep-dive-` prefix for deep-dives)

## 3. Validation

- [x] 3.1 Invoke the skill against the Janet series and create lesson 03-functions.md as a smoke-test
- [x] 3.2 Confirm README.md was created/updated with the new lesson row
- [x] 3.3 Confirm lesson 02-first-steps.md nav was updated with a Next link to 03-functions.md
- [x] 3.4 Confirm the lesson file contains all required structural elements (nav, numbered sections, Try-it, mini-project, What to Explore Next)
