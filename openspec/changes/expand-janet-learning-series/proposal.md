## Why

The Janet learning series has only two lessons (setup and first steps), leaving learners without guidance on functions, data manipulation, modules, error handling, or macros — the topics needed to write real Janet programs. Expanding to a full seven-lesson curriculum completes the core arc and introduces a scalable structure that accommodates future deep-dive additions.

## What Changes

- Add `docs/learning/janet/README.md` — series index, the single place listing all lessons (core and deep-dives)
- Add `docs/learning/janet/03-functions.md` — higher-order functions, closures, `->` threading, `map`/`filter`/`reduce`
- Add `docs/learning/janet/04-sequences.md` — `seq` macro, generators, lazy iteration, table/struct patterns, destructuring
- Add `docs/learning/janet/05-modules.md` — `import`, `use`, jpm project layout, using spork library
- Add `docs/learning/janet/06-error-handling.md` — `try`/`catch`, `protect`, `error`, fibers as error mechanism
- Add `docs/learning/janet/07-macros.md` — quasiquoting, `defmacro`, when to use macros vs functions
- Update `docs/learning/janet/01-setup.md` — replace inline breadcrumb nav with `← Index | Next →` pattern
- Update `docs/learning/janet/02-first-steps.md` — replace inline breadcrumb nav with `← Previous | Index | Next →` pattern

## Capabilities

### New Capabilities

- `janet-learning-series`: A seven-lesson interactive curriculum teaching Janet in the context of this Neovim configuration, with a `README.md` index and a naming convention that supports appending future deep-dive lessons without renaming existing files.

### Modified Capabilities

_(none — no existing spec-level behavior is changing)_

## Impact

- `docs/learning/janet/` — all new and modified files are documentation only
- No Lua code changes
- No plugin, keymap, or LSP configuration changes
