## Context

The repository contains a `docs/learning/` tree for interactive, REPL-driven tutorials. Currently only `docs/learning/janet/` exists, with two lessons. The convention established by those lessons includes: numbered filenames (`NN-topic.md`), a breadcrumb nav line, numbered sections, inline "try it" REPL prompts, keymap tables, a mini-project, and a README.md index as the sole series navigator. Deep-dive lessons use a `deep-dive-<topic>.md` naming scheme and are listed in a separate section of the README index.

Without a skill, each new lesson requires the author to remember all conventions, manually update the previous lesson's "Next" link, and update the README index — steps that are easy to miss.

## Goals / Non-Goals

**Goals:**
- Codify the full lesson creation workflow in a single invocable skill
- Ensure every lesson has the correct filename, nav links, section structure, REPL prompts, and mini-project
- Ensure the README index and adjacent lesson nav links are always updated
- Support both core lessons (numbered) and deep-dive lessons (prefixed)
- Be language-agnostic (works for janet, lua, or any future language under `docs/learning/`)

**Non-Goals:**
- Generating lesson *content* automatically without user guidance (topic and depth are user-directed)
- Managing any documentation outside `docs/learning/`
- Replacing the openspec workflow for non-lesson changes

## Decisions

**Decision: Single SKILL.md, no sub-files**
Skills in this repo are a single `SKILL.md` under `.github/skills/<name>/`. The skill encodes all conventions inline rather than referencing external templates, keeping it self-contained and portable.
*Alternative considered*: A separate `template.md` file the skill copies — rejected because it adds indirection and the template content is small enough to inline.

**Decision: README.md as sole series navigator**
Each lesson's nav is `← Previous | Index | Next →` pointing to adjacent files and the README. The README holds the canonical ordered list. This means only one file needs updating when a lesson is inserted, not every downstream lesson.
*Alternative considered*: Breadcrumb nav in every file listing all lessons (current state in 01/02) — rejected because it breaks on every insertion.

**Decision: Core vs. deep-dive distinction in filename**
Core lessons: `NN-topic.md` (e.g., `03-functions.md`). Deep-dives: `deep-dive-<topic>.md` (e.g., `deep-dive-fibers.md`). Deep-dives append after core lessons and are listed in a separate README section.
*Alternative considered*: Sub-numbered files (e.g., `03a-closures.md`) — rejected because it's harder to scan and implies a fixed relationship to a parent lesson.

**Decision: Skill updates adjacent nav links**
The skill is responsible for updating the previous lesson's "Next →" link and, if inserting before an existing lesson, the next lesson's "← Previous" link. This is the most fragile manual step and the primary motivation for the skill.

## Risks / Trade-offs

- [Risk] Skill instructions could drift from actual conventions as the series evolves → Mitigation: skill instructs agent to read the existing README and two most recent lessons before authoring, grounding output in current reality rather than stale instructions.
- [Risk] Language-agnostic scope could make instructions too vague → Mitigation: skill instructs agent to read the existing series for the target language to infer conventions, falling back to documented defaults only when no examples exist.
- [Trade-off] The skill cannot enforce content quality (depth, accuracy of code examples) — it only enforces structure. Content review remains a human responsibility.
