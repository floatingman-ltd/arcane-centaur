## Context

Current bindings, all in `lua/keymaps.lua`:

| Key | Line | Action |
|---|---|---|
| `<leader>n` | 88 | `:NvimTreeOpen` |
| `<C-n>` | 89 | `:NvimTreeOpen` |
| `<C-t>` | 90 | `:NvimTreeToggle` |
| `<leader>t` | 191 | `toggle_terminal` |
| `<leader>L` | 193 | `ide_layout` |

Two things make this a smaller change than the bug report suggests.

First, there is no race. The `<leader>gcv` defect documented in `CLAUDE.md` came from a lazy `keys` map being created only after which-key built its triggers, so on fast input the prefix was not held. Nothing like that applies here: `<leader>t` is set eagerly in `lua/keymaps.lua`, it is a complete map rather than a prefix, and no other `<leader>t*` binding exists. It resolves immediately and always to the terminal.

Second, the terminal cannot simply be deleted. `ide_layout` (`<leader>L`) does not call `toggle_terminal`, but it inlines the same open path and shares the module-level `term_buf` upvalue — the comment at the relevant line says "reuse the same open path as toggle_terminal". Removing the toggle would leave that duplicated logic with no counterpart and would strip three of `ide-layout`'s seven requirements. The cheap fix is to move the key.

The tree keymaps are documented in three places and match the config exactly. They are, however, specified nowhere — `openspec/specs/` has no requirement naming `<leader>n`, `<C-n>`, or `<C-t>`.

## Goals / Non-Goals

**Goals:**

- Make `<leader>t` do what a reader expects: toggle the file tree.
- Keep the terminal fully working, on a key one shift away.
- Put the tree's keymaps under a specification so config and docs can be checked against each other.
- Break nothing that the docs currently promise.

**Non-Goals:**

- Changing any terminal *behavior* — split position, persistence, height, focus return.
- Touching `<leader>L`, `:Bd`, the quit guardrails, or float behavior.
- Removing `<C-t>`, `<leader>n`, or `<C-n>`.
- The full-screen panel / buffer-tabbing ideas in `recommendations/ideas.md`.
- The blink completion keymap defects — a separate change.

## Decisions

**D1 — Move the terminal to `<leader>T` rather than removing it.**

- _Why:_ `<leader>L` depends on the terminal panel, and three `ide-layout` requirements specify its behavior. A key move costs one line and one spec delta; removal would hollow out a capability for a panel that still works.
- _Alternative rejected:_ delete the toggle and let `<leader>L` and `:terminal` cover it. Considered and declined — it trades a one-line change for a multi-requirement spec rewrite, to remove something that is not broken.
- _Alternative rejected:_ make `<leader>t` a group (`tt` tree, `tm` terminal). Declined — adds a keystroke to both for a collision between exactly two things.

**D2 — Keep `<C-t>`, `<leader>n`, and `<C-n>` exactly as they are.**

- _Why:_ All three work today and all three are documented in all three surfaces. The reported defect is that the *expected* key was missing, not that the existing ones were wrong. Adding `<leader>t` satisfies the expectation without invalidating anything a reader has already learned.
- _Trade-off:_ the tree ends up with four bindings (`<leader>t`, `<leader>n`, `<C-t>`, `<C-n>`), which is more than it strictly needs. Retiring `<C-t>` and `<C-n>` later is a trivial follow-up once `<leader>t` has bedded in; doing it now would break working documented keys in the same change that fixes a keymap complaint.

**D3 — Specify the tree keymaps inside `ide-layout` rather than creating a new capability.**

- _Why:_ `ide-layout` already owns keymap-level requirements (`<leader>t`, `<leader>L`, `:Bd`) and already reasons about the tree window in "Tree never left as the last window". A separate `file-tree-keymaps` capability would split tree behavior across two specs.
- _Alternative rejected:_ a new capability. Cleaner in isolation, worse in aggregate.

**D4 — `<leader>t` binds `:NvimTreeToggle`, not `:NvimTreeOpen`.**

- _Why:_ The complaint was that it does not *toggle*. `<leader>n` and `<C-n>` remain the open-only variants for anyone who wants the tree without the risk of closing it.

## Risks / Trade-offs

- **`<leader>T` collides with something** → Verify no `<leader>T` map exists before binding, and confirm `<leader>t` is not left as a which-key prefix that delays the tree toggle. Both are cheap greps plus a live check.
- **Muscle memory for `<leader>t` = terminal** → Unavoidable, and the point of the change. The new key is one shift away, and the docs call the move out explicitly rather than silently updating a table row.
- **Four tree bindings is redundant** → Accepted deliberately (D2). Noted as a follow-up rather than bundled in.
- **Docs drift across six locations** — three assert the terminal key, three list tree keys → Grep for `<leader>t` and the pandoc-escaped `++<++leader++>++t` after editing; every hit must be intentional.
- **`cheatsheets/core.md` is the `<leader>?` in-editor surface**, not just web docs → It must be updated in the same change or the in-editor cheatsheet will contradict the running config.

## Migration Plan

1. Move the `<leader>t` terminal binding to `<leader>T` in `lua/keymaps.lua`; leave `toggle_terminal` itself untouched.
2. Add `<leader>t` → `:NvimTreeToggle` beside the existing tree maps.
3. Update all six doc locations.
4. Write the `TEST_PLAN.md` section and walk it live.
5. Rollback is a single-commit revert; the change is two keymap lines plus doc text.

## Open Questions

- Whether `<C-t>` and `<C-n>` are worth keeping once `<leader>t` exists. Deliberately left alone here (D2); revisit after living with the new binding.
