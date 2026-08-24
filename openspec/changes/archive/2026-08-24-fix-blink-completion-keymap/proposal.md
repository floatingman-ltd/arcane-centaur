## Why

Two logged defects in the completion keymap, both rooted in the same thing — the insert-mode menu and the command-line menu were configured independently and drifted apart.

1. **There is no working manual completion trigger.** `<M-Space>` is bound to `show` (`lua/plugins/blink.lua:14`), but this config runs under WSL in a Windows console, where Alt-Space opens the *Windows system menu*. The keystroke never reaches Neovim. Three doc surfaces promise it works: `editor/keybindings.adoc:306`, `editor/code-intelligence.adoc:170`, and `cheatsheets/core.md:172`.
2. **Accepting a completion uses a different key depending on where you are.** Insert mode uses `preset = "none"` with `<CR>` = accept. The cmdline block (`lua/plugins/blink.lua:60`) instead inherits blink's stock `cmdline` preset, where `<Tab>`/`<S-Tab>` select and `<C-y>` accepts. Muscle memory built in insert mode silently fails at the `:` prompt, and no page under `docs/` or `cheatsheets/` states an accept key for either context.

## What Changes

- Define **one completion keymap, used identically in insert mode and on the command line**, replacing both the ad-hoc insert table and the inherited `cmdline` preset:

  | Key | Action |
  |---|---|
  | `<C-n>` | Show the menu when closed (manual trigger); select next when open |
  | `<C-p>` | Select previous |
  | `<C-y>` | Accept the selected item (or the top item if none selected) |
  | `<C-e>` | Cancel — close the menu and restore what was typed |
  | `<C-k>` | Show the documentation window for the selected item |
  | `<C-b>` / `<C-f>` | Scroll the documentation window up / down |

- **BREAKING — `<CR>` no longer accepts a completion.** Enter inserts a newline in insert mode and executes the command on the command line, always. Accepting is `<C-y>` in both modes. This removes the class of accident where Enter silently commits a suggestion, and is what makes a single cross-mode keymap possible at all.
- **BREAKING — `<M-Space>` is removed**, and no dedicated show key replaces it. `<C-n>` takes on the trigger role in addition to select-next: pressed with the menu closed it opens the menu (highlighting nothing), pressed with the menu open it selects the next item. This restores insert-mode `<C-n>` to the meaning it already has in vanilla Vim.

  `<C-Space>` was the original candidate and was **tested and rejected**: in the target WSL console it is swallowed exactly like `Alt-Space`, so it would have reproduced this very defect under a new key. Any replacement trigger has to be a plain `Ctrl`-plus-letter chord — `Alt`- and `Space`-based chords are what the host console reserves. See `design.md` D2.
- `<C-y>` uses blink's `select_and_accept`, not `accept`. With `preselect = false, auto_insert = false` (`lua/plugins/blink.lua:22`), plain `accept` is a no-op when nothing is highlighted; `select_and_accept` takes the top item, which is what a reader expects "accept" to mean.
- `<C-e>` moves from `hide` to `cancel`, so dismissing restores the text you had typed rather than leaving the partially-completed word behind.
- Update the three doc surfaces that promise `<M-Space>`, and document the accept key for the command line — which no page currently states. (All three surfaces *do* state an insert-mode accept key today; they state `Enter`, which this change unbinds, so all three become wrong in a second way and must be corrected either way.)
- Fix the stale heading on `cheatsheets/core.md:168`, which still reads **"Auto-Completion (nvim-cmp)"**. nvim-cmp was replaced by blink.cmp in change `03-migrate-completion-blink`; the section is being rewritten here regardless, so correcting the engine name in its title is in scope rather than a drive-by.

Out of scope: binding `snippet_forward` / `snippet_backward`. Those are bound nowhere today despite `snippets` being an active source, so snippet placeholders cannot be navigated at all. That is a pre-existing gap, not one of these two defects; it is logged in `recommendations/ideas.md` for a follow-up.

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `completion-engine`: the "Completion ergonomics preserved" requirement currently mandates the exact behavior being replaced — that `<CR>` accepts and that `<M-Space>` triggers. It is rewritten around the single cross-mode keymap, with `<CR>` reserved for newline/execute, `<C-y>` as the accept key, and `<C-n>` serving as both trigger and select-next. It also gains a constraint that the trigger must not be an `Alt`- or `Space`-based chord, so the unreachable-key defect cannot be reintroduced. The "Command-line completion" requirement gains the constraint that the command line uses that same keymap rather than blink's stock preset.

## Impact

- **Code:** `lua/plugins/blink.lua` only — the `keymap` table and the `cmdline.keymap` field. No other module reads these.
- **Docs:** `editor/keybindings.adoc`, `editor/code-intelligence.adoc`, `cheatsheets/core.md` (all three assert `Alt-Space`); the accept key needs stating for both modes wherever completion keys are listed.
- **Runtime behavior is touched**, so this requires a dedicated `openspec/TEST_PLAN.md` section walked through in a live Neovim session before the PR is raised — including confirming the trigger actually reaches Neovim under WSL, which is the specific failure mode that made `<M-Space>` unusable and that then also ruled out `<C-Space>`.
- **Muscle memory:** anyone used to `<CR>` accepting will have to relearn `<C-y>`. That is the deliberate cost of the fix.
- No plugin additions or removals; no change to sources, providers, or LSP capability advertisement.
