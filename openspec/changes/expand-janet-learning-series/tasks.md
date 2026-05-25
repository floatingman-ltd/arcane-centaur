## Tasks

### 1. Series index page

- [x] 1.1 Create `docs/modules/ROOT/pages/learning/janet/index.adoc` from `docs/learning/janet/README.md` — use `xref:NN-topic.adoc[Lesson title]` links (not copied Markdown links) to all seven lessons

### 2. Lesson 03 — Antora page

- [x] 2.1 Convert `docs/learning/janet/03-functions.md` to `docs/modules/ROOT/pages/learning/janet/03-functions.adoc` (hand-authored, no auto-generated sentinel); include scratch-file/Conjure-log intro and `[source,janet]` code blocks
- [x] 2.2 Add nav bar: `← xref:02-first-steps.adoc[Previous] | xref:index.adoc[Index] | xref:04-sequences.adoc[Next] →`

### 3. Lesson 04 — Sequences

- [x] 3.1 Create `docs/modules/ROOT/pages/learning/janet/04-sequences.adoc` — `seq` macro, generators, lazy iteration, table/struct patterns, destructuring; include scratch-file/Conjure-log intro and `[source,janet]` code blocks; nav bar pointing to 03 and 05

### 4. Lesson 05 — Modules

- [x] 4.1 Create `docs/modules/ROOT/pages/learning/janet/05-modules.adoc` — `import`, `use`, jpm project layout, using spork library; include scratch-file/Conjure-log intro and `[source,janet]` code blocks; nav bar pointing to 04 and 06

### 5. Lesson 06 — Error Handling

- [x] 5.1 Create `docs/modules/ROOT/pages/learning/janet/06-error-handling.adoc` — `try`/`catch`, `protect`, `error`, fibers as error mechanism; include scratch-file/Conjure-log intro and `[source,janet]` code blocks; nav bar pointing to 05 and 07

### 6. Lesson 07 — Macros

- [x] 6.1 Create `docs/modules/ROOT/pages/learning/janet/07-macros.adoc` — quasiquoting, `defmacro`, when to use macros vs functions; include scratch-file/Conjure-log intro and `[source,janet]` code blocks; nav bar pointing to 06, index only (no Next)

### 7. Navigation

- [x] 7.1 Update `docs/modules/ROOT/nav.adoc` — add index and lessons 03–07 under the Janet Learning section, following the existing pattern for 01 and 02
- [ ] 7.2 Verify all xref links in new `.adoc` files resolve (no broken cross-references)
- [ ] 7.3 Run Antora build and confirm build succeeds, sidebar lists all seven lessons under Janet Learning, and new pages render without errors

### 8. Remove stale Markdown files

- [ ] 8.1 Delete `docs/learning/janet/03-functions.md` (superseded by `03-functions.adoc`)
- [ ] 8.2 Delete `docs/learning/janet/README.md` (superseded by `index.adoc`)
- [ ] 8.3 Delete `docs/learning/janet/` directory if empty after removals
