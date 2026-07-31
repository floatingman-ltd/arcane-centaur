## Context

`lua/plugins/blink.lua` configures completion twice, and the two halves disagree.

The insert-mode block sets `keymap.preset = "none"` and enumerates every key by hand: `<CR>` accept, `<C-n>`/`<C-p>` select, `<M-Space>` show, `<C-e>` hide, `<C-b>`/`<C-f>` scroll docs. The `cmdline` block deliberately does *not* inherit that — a comment at line 57 explains why: with `preset = "none"` inherited, the command line would have no keys at all. It therefore sets `keymap = { preset = "cmdline" }`, pulling in blink's stock table where `<Tab>`/`<S-Tab>` select, `<C-y>` accepts, `<C-e>` cancels, and `<CR>` executes.

That workaround is the source of defect 2. It solved "cmdline has no keys" by giving the command line a *different* set of keys, and nothing documents either set.

Defect 1 is independent but lands in the same table: `<M-Space>` cannot reach Neovim in this environment. The config runs under WSL in a Windows console, which claims Alt-Space for its own system menu before the terminal sees it. The binding is not wrong — it is unreachable, which is worse, because the config and three doc pages all assert it works.

Relevant existing behavior that constrains the fix: `completion.list.selection = { preselect = false, auto_insert = false }` (line 22). Nothing is highlighted when the menu opens. This is deliberate and is what the `completion-engine` spec means by "no-auto-select behavior so that `<CR>` never inserts an unselected first suggestion".

## Goals / Non-Goals

**Goals:**

- One completion keymap that behaves identically in insert mode and on the command line.
- A manual trigger that actually reaches Neovim under WSL.
- An accept key that is the same everywhere and is documented, which no page currently does.
- Keep the no-auto-select behavior: opening the menu must never pre-commit anything.

**Non-Goals:**

- Binding `snippet_forward` / `snippet_backward`. Bound nowhere today despite `snippets` being an active source; a real gap, but a pre-existing one and not either logged defect. Logged in `recommendations/ideas.md`.
- Changing sources, providers, scoring, or the `blink.compat` bridges for `cmp-spell` / `cmp-conjure`.
- Changing how completion capabilities are advertised to LSP servers.
- Reworking which-key or the `<leader>?` cheatsheet surfaces.
- The `<leader>t` tree/terminal keymap defect — a separate change.

## Decisions

**D1 — One table, applied to both modes.** Define the keymap once and assign the same table to `keymap` and to `cmdline.keymap`, both with `preset = "none"`.

- _Why:_ Directly removes the drift. The original comment's concern — that cmdline inherits `preset = "none"` and ends up with no keys — is addressed by giving cmdline the full explicit table rather than a different preset.
- _Alternative rejected:_ keep `preset = "cmdline"` and re-document both sets. Cheaper, and it was offered, but it preserves the defect and only writes it down.

**D2 — `<C-Space>` replaces `<M-Space>` outright.** Not bound in addition to it.

- _Why:_ `<C-Space>` is unbound anywhere in `lua/` and is not intercepted by the Windows console. Keeping a dead `<M-Space>` alongside it would leave a binding that works on some machines and silently fails on this one — exactly the confusion being removed. It is also what blink's own stock cmdline preset uses, so the two sets converge rather than diverge.
- _Alternative rejected:_ bind both. Rejected on the user's call; a single documented trigger is the point.

**D3 — `<C-y>` accepts, via `select_and_accept` rather than `accept`.**

- _Why:_ With `preselect = false`, plain `accept` does nothing when no item is highlighted — the menu would appear to ignore the key until you pressed `<C-n>` first. `select_and_accept` takes the top item, which is what "accept" means to a reader. This preserves the spirit of the no-auto-select requirement: nothing is committed *implicitly*, but an explicit accept keystroke does commit something.
- _Alternative rejected:_ `accept`, for strict symmetry with the old `<CR>` binding. Rejected — it makes the key a no-op in the most common state.

**D4 — `<CR>` is not bound at all.** Enter inserts a newline in insert mode and executes on the command line.

- _Why:_ This is what makes one cross-mode keymap possible. `<CR>` cannot mean "accept" on the command line, because there it must mean "run the command" — so as long as `<CR>` is the accept key in insert mode, the two modes can never match. Unbinding it also strengthens the existing no-accidental-accept guarantee from "Enter does not accept an *unselected* item" to "Enter never accepts, ever".
- _Trade-off:_ this is the breaking part of the change. It is the deliberate cost.

**D5 — `<C-e>` becomes `cancel`, not `hide`.**

- _Why:_ `hide` closes the menu and leaves whatever was inserted; `cancel` restores what the user actually typed. For a dismiss key, restore is the expected behavior, and it matches blink's stock cmdline preset — again converging the two modes.

**D6 — `<C-b>` / `<C-f>` keep their current meaning.** Documentation scroll, carried over unchanged into both modes.

## Risks / Trade-offs

- **`<C-Space>` may itself be intercepted** by some terminal or window manager, which would reproduce defect 1 with a different key → The TEST_PLAN must verify the key actually arrives, in a live WSL session, before the PR is raised. Verify with `:map <C-Space>` and by observing the menu, not by reading the config. If it is intercepted, fall back to a plain letter-based trigger rather than another modifier combination.
- **`<CR>` no longer accepting will feel broken before it feels better** → It is called out as BREAKING in the proposal and must be stated prominently in the docs, not buried in a table row.
- **`<C-n>` / `<C-p>` are also normal-mode tree bindings** (`lua/keymaps.lua:89`, `<C-n>` opens the file tree) → No conflict: these are insert- and cmdline-mode maps, and the tree map is normal-mode. Worth noting because the sibling tree keymap change touches the same keys in a different mode.
- **Command-line `<Tab>` behavior changes.** Dropping the stock preset means `<Tab>` no longer selects a completion item; it falls back to native command-line completion → This is arguably a regression for anyone using `<Tab>` at the `:` prompt. The TEST_PLAN must exercise `:` completion explicitly and confirm the fallback is acceptable.
- **Three doc surfaces assert `Alt-Space` today.** Missing one leaves the config contradicting its own docs, which is the original defect → Grep for `M-Space`, `Alt-Space`, and `Alt+Space` after the edit; the count must reach zero.

## Migration Plan

1. Extract the keymap into a single local table in `lua/plugins/blink.lua`; assign it to both `keymap` and `cmdline.keymap`.
2. Update the three doc surfaces; add the accept key, which none of them currently state.
3. Write the `TEST_PLAN.md` section and walk it live — specifically including "does `<C-Space>` reach Neovim under WSL".
4. Rollback is a single-commit revert: the change is confined to one table plus doc text.

## Open Questions

- Whether `<Tab>` at the `:` prompt is missed once it falls back to native command-line completion. Resolve during live validation rather than by guessing — if it is missed, `<Tab>` can be added to the shared table as a select-next alias without breaking the one-set-everywhere goal.
