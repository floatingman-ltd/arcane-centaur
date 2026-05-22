## ADDED Requirements

### Requirement: Skill is invocable as add-learning-lesson
The repository SHALL contain a skill at `.github/skills/add-learning-lesson/SKILL.md` that is loadable by the Copilot CLI skill system.

#### Scenario: Skill loads successfully
- **WHEN** a user invokes the `add-learning-lesson` skill
- **THEN** the skill context is injected and the agent follows its workflow

---

### Requirement: Skill reads existing series before authoring
Before creating any file, the skill SHALL scan the target language's learning directory and read the README index and the two most recent lesson files to ground its output in current conventions.

#### Scenario: Series already has lessons
- **WHEN** the skill is invoked for a language with existing lessons
- **THEN** the agent reads the README.md and the last two lesson files before writing anything

#### Scenario: Series has no lessons yet
- **WHEN** the skill is invoked for a language with no existing lessons
- **THEN** the agent falls back to the documented default conventions in the skill

---

### Requirement: Skill determines correct filename
The skill SHALL assign filenames according to lesson type:
- Core lesson: `NN-<topic>.md` where NN is the next available two-digit number
- Deep-dive: `deep-dive-<topic>.md` appended after all core lessons

#### Scenario: Adding a core lesson to a series with 02 as the last
- **WHEN** the highest existing core lesson number is 02
- **THEN** the new file is named `03-<topic>.md`

#### Scenario: Adding a deep-dive lesson
- **WHEN** the user specifies a deep-dive
- **THEN** the file is named `deep-dive-<topic>.md` regardless of existing lesson count

---

### Requirement: Skill authors lesson with required structure
Every lesson file created by the skill SHALL contain:
1. A title line: `# NN — <Title> with <Language>`
2. A nav line immediately after the title: `← [Previous](prev.md) | [Index](README.md) | [Next](next.md) →` (or `Next: coming soon` if it is the final lesson)
3. A horizontal rule after the nav line
4. Numbered top-level sections (`## 1.`, `## 2.`, etc.)
5. At least one "Try it" REPL prompt per language-feature section
6. Keymap tables for any Neovim tools exercised in the lesson
7. A mini-project or hands-on capstone as the penultimate section
8. A "What to Explore Next" final section pointing to the next lesson and related docs

#### Scenario: Lesson file is created
- **WHEN** the skill creates a new lesson file
- **THEN** the file contains all eight required structural elements

#### Scenario: Mini-project is present
- **WHEN** the lesson file is written
- **THEN** there is at least one section containing a complete, evaluable code example with step-by-step Conjure/REPL instructions

---

### Requirement: Skill updates the README index
After creating the lesson file, the skill SHALL update `docs/learning/<lang>/README.md` to add the new lesson to the appropriate section (Core Lessons or Deep-Dives).

#### Scenario: Core lesson added
- **WHEN** a core lesson is created
- **THEN** the README Core Lessons table gains a new row for the lesson

#### Scenario: Deep-dive lesson added
- **WHEN** a deep-dive lesson is created
- **THEN** the README Deep-Dives table gains a new row for the lesson

---

### Requirement: Skill updates adjacent navigation links
After creating the lesson file, the skill SHALL:
- Update the previous lesson's nav line to include a `Next →` link to the new lesson
- If a lesson already exists after the insertion point, update its `← Previous` link

#### Scenario: New lesson appended at end of series
- **WHEN** the new lesson is the last in the series
- **THEN** the previously-last lesson's nav line is updated to link `Next →` to the new file

#### Scenario: New lesson inserted between two existing lessons
- **WHEN** the new lesson is inserted between lesson N and lesson N+1
- **THEN** lesson N's `Next →` link points to the new lesson, and lesson N+1's `← Previous` link points to the new lesson

---

### Requirement: README.md exists for every learning series
Every language directory under `docs/learning/` SHALL have a `README.md` with two sections: **Core Lessons** (a numbered table) and **Deep-Dives** (a table, may be empty).

#### Scenario: README already exists
- **WHEN** the skill is invoked and a README.md is already present
- **THEN** the skill updates it in place without replacing existing content

#### Scenario: README does not exist
- **WHEN** the skill is invoked and no README.md exists for the language
- **THEN** the skill creates one with the two required sections before adding the new lesson row
