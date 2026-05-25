## Why

The Janet learning series has only two lessons (setup and first steps), leaving learners without guidance on functions, data manipulation, modules, error handling, or macros — the topics needed to write real Janet programs. Expanding to a full seven-lesson curriculum completes the core arc and introduces a scalable structure that accommodates future deep-dive additions.

## What Changes

### Already Delivered
- `docs/learning/janet/README.md` — series index (will be superseded by `index.adoc`) ✅
- `docs/learning/janet/03-functions.md` — higher-order functions, closures, `->` threading, `map`/`filter`/`reduce` (will be superseded by `03-functions.adoc`) ✅
- `docs/modules/ROOT/pages/learning/janet/01-setup.adoc` — Antora page ✅
- `docs/modules/ROOT/pages/learning/janet/02-first-steps.adoc` — Antora page ✅

### Remaining
- Create `docs/modules/ROOT/pages/learning/janet/index.adoc` — series index with xref links to all seven lessons
- Create `docs/modules/ROOT/pages/learning/janet/03-functions.adoc` — converted from existing Markdown source
- Create `docs/modules/ROOT/pages/learning/janet/04-sequences.adoc` — `seq` macro, generators, lazy iteration, table/struct patterns, destructuring
- Create `docs/modules/ROOT/pages/learning/janet/05-modules.adoc` — `import`, `use`, jpm project layout, using spork library
- Create `docs/modules/ROOT/pages/learning/janet/06-error-handling.adoc` — `try`/`catch`, `protect`, `error`, fibers as error mechanism
- Create `docs/modules/ROOT/pages/learning/janet/07-macros.adoc` — quasiquoting, `defmacro`, when to use macros vs functions
- Delete stale Markdown files (`docs/learning/janet/README.md`, `03-functions.md`, directory)

## Capabilities

### New Capabilities

- `janet-learning-series`: A seven-lesson interactive curriculum teaching Janet in the context of this Neovim configuration, with a `README.md` index and a naming convention that supports appending future deep-dive lessons without renaming existing files.

### Modified Capabilities

_(none — no existing spec-level behavior is changing)_

## Impact

- `docs/learning/janet/` — all new and modified files are documentation only
- No Lua code changes
- No plugin, keymap, or LSP configuration changes
