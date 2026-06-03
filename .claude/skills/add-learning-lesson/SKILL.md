---
name: add-learning-lesson
description: Add a new lesson to a docs/learning/<lang>/ series. Handles filename assignment, lesson authoring, README index maintenance, and prev/next navigation wiring in one complete workflow.
license: MIT
metadata:
  author: arcane-centaur
  version: "1.0"
---

Add a new lesson to an interactive learning series end-to-end:
topic → filename → lesson file → README index → navigation links.

---

## Preflight

Determine the target language and topic. If either is missing, ask:

> "Which language series? (e.g., `janet`, `lua`)"
> "What topic should this lesson cover?"
> "Is this a **core lesson** (numbered, main sequence) or a **deep-dive** (supplementary, appended after core lessons)?"

Then read the existing series:

```bash
ls docs/learning/<lang>/
```

Read:
1. `docs/learning/<lang>/README.md` (if it exists)
2. The two most recent lesson files — highest-numbered `NN-*.md` files, or the latest `deep-dive-*.md`

This grounds your output in the actual conventions of the series. Do not rely solely on this skill's defaults — real examples override them. If `README.md` does not exist you will create it in Step 3.

---

## Conventions

### Filename Rules

| Lesson type | Filename pattern | Example |
|---|---|---|
| Core lesson | `NN-<topic>.md` | `03-functions.md` |
| Deep-dive | `deep-dive-<topic>.md` | `deep-dive-fibers.md` |

For core lessons, `NN` is the next available two-digit number. Find the current highest:

```bash
ls docs/learning/<lang>/[0-9]*.md 2>/dev/null | sort | tail -1
```

Deep-dives always append after all core lessons.

### Lesson File Structure

Every lesson file MUST contain these eight elements in order:

**1. Title line**
```markdown
# NN — <Full Title> with <Language>
```
For deep-dives:
```markdown
# Deep Dive: <Full Title>
```

**2. Nav line** (immediately after the title, before any content)
```markdown
← [Previous](NN-1-topic.md) | [Index](README.md) | [Next](NN+1-topic.md) →
```
If this is the final lesson (no next yet):
```markdown
← [Previous](NN-1-topic.md) | [Index](README.md) | Next: coming soon
```

**3. Horizontal rule** (`---`)

**4. Numbered sections**
```markdown
## 1. Section Title
## 2. Section Title
```

**5. "Try it" REPL prompts** — at least one per language-feature section.
```markdown
**Try it:** place the cursor on `(greet "Walt")` and press `,ee` — the result appears in the Conjure log.
```

**6. Keymap tables** — for every Neovim tool exercised in the lesson.
```markdown
| Keys | Action |
|---|---|
| `,ee` | Evaluate form under cursor |
| `,er` | Evaluate root (outermost) form |
```

**7. Mini-project / capstone** — a self-contained, complete code example with
step-by-step Conjure/REPL instructions (numbered 1–N). Every concept introduced
in the lesson must appear in the project.

**8. "What to Explore Next" final section** — pointer to the next lesson and
two or three related resources (cheatsheets, guides, language docs).

### README Index Format

```markdown
# <Language> Learning Series

Interactive, REPL-driven lessons for <Language> in this Neovim configuration.

## Core Lessons

| Lesson | File | Topic |
|---|---|---|
| 01 | [01-setup.md](01-setup.md) | Setup |
| 02 | [02-first-steps.md](02-first-steps.md) | First Steps |

## Deep-Dives

| File | Topic |
|---|---|
| _(none yet)_ | |
```

---

## Step 1 — Classify and Name

Determine lesson type and filename.

**Core lesson:**
1. Find the highest existing `NN-*.md` file number.
2. Assign the next number (zero-padded to two digits: `03`, `04`, …).
3. Slugify the topic to kebab-case.
4. Result: `docs/learning/<lang>/NN-<topic-slug>.md`

**Deep-dive:**
1. Slugify the topic to kebab-case.
2. Result: `docs/learning/<lang>/deep-dive-<topic-slug>.md`

Announce your decision and **pause for confirmation** before writing any files:

```
## Lesson Plan

**Type:** core lesson / deep-dive
**Filename:** docs/learning/<lang>/NN-topic.md
**Title:** NN — <Full Title> with <Language>
**Previous lesson:** NN-1-topic.md
**Next lesson:** NN+1-topic.md (or "coming soon" if last)
```

---

## Step 2 — Author the Lesson File

Write `docs/learning/<lang>/<filename>` following the structure in Conventions.

Guidelines:
- Every code snippet must be **evaluable in the REPL** — no pseudo-code or partial examples.
- Keep each snippet short enough to hold in working memory (≤ 15 lines).
- **Weave Neovim tool usage into language teaching** — do not isolate them in a single "tools" section; show `,ee` after a function definition, `>)` when refactoring a form, `K` when exploring an unfamiliar function.
- The mini-project must use **every concept introduced** in the lesson.
- Write for a reader who is following along in Neovim with a REPL open on the right.

---

## Step 3 — Update the README Index

If `docs/learning/<lang>/README.md` does not exist, create it using the README Index Format from Conventions.

Then add the new lesson row:
- **Core lesson** → add a row to the **Core Lessons** table in numeric order.
- **Deep-dive** → add a row to the **Deep-Dives** table.

---

## Step 4 — Wire Navigation Links

**Update the previous lesson's nav line.**

Find the nav line in the previous lesson. It may be in one of two formats:

*New format (lessons written with this skill):*
```
← [Previous](...) | [Index](README.md) | Next: coming soon
```
Replace `Next: coming soon` with `[Next](new-filename.md) →`.

*Old breadcrumb format (early lessons written before this skill existed):*
```
> **Series:** [01 Setup](01-setup.md) · 02 First Steps ← you are here
```
Append a `**Next:**` line immediately after rather than rewriting the breadcrumb:
```markdown
> **Series:** [01 Setup](01-setup.md) · 02 First Steps ← you are here

**Next:** [03 — Functions in Depth](03-functions.md)
```

**If inserting before an existing lesson** (mid-series insertion):
Also update that lesson's `← Previous` pointer to the new file.

---

## Output on Completion

```
## Lesson Added: <filename>

### Files Created
- docs/learning/<lang>/<filename> — new lesson

### Files Modified
- docs/learning/<lang>/README.md — added row to <Core Lessons / Deep-Dives>
- docs/learning/<lang>/<prev-lesson>.md — added Next link

### Structure Check
- [ ] Title line present
- [ ] Nav line present
- [ ] Numbered sections
- [ ] Try-it prompts (at least one per feature section)
- [ ] Keymap tables
- [ ] Mini-project with step-by-step REPL instructions
- [ ] What to Explore Next
```

---

## Guardrails

- **Pause after Step 1** — confirm filename and title before writing any files.
- **Always read existing lessons first** — conventions in real files override this skill's defaults.
- **Every code snippet must be evaluable** — no partial or placeholder examples.
- **The mini-project is required** — a lesson without a capstone exercise is incomplete.
- **Always update README.md** — a lesson not in the index is invisible to readers.
- **Always wire navigation** — broken prev/next links undermine the series flow.
- **Old breadcrumb nav: append, don't rewrite** — the series-wide nav migration is a separate concern; only add the missing Next link.
