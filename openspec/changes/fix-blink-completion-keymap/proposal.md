## Why

Two logged defects in the completion keymap, both rooted in the same thing — the insert-mode menu and the command-line menu were configured independently and drifted apart.

1. **There is no working manual completion trigger.** `<M-Space>` is bound to `show` (`lua/plugins/blink.lua:14`), but this config runs under WSL in a Windows console, where Alt-Space opens the *Windows system menu*. The keystroke never reaches Neovim. Three doc surfaces promise it works: `editor/keybindings.adoc:306`, `editor/code-intelligence.adoc:170`, and `cheatsheets/core.md:172`.
2. **Accepting a completion uses a different key depending on where you are.** Insert mode uses `preset = "none"` with `<CR>` = accept. The cmdline block (`lua/plugins/blink.lua:60`) instead inherits blink's stock `cmdline` preset, where `<Tab>`/`<S-Tab>` select and `<C-y>` accepts. Muscle memory built in insert mode silently fails at the `:` prompt, and no page under `docs/` or `cheatsheets/` states an accept key for either context.

## What Changes

- Define **one completion keymap, used identically in insert mode and on the command line**, replacing both the ad-hoc insert table and the inherited `cmdline` preset:

  | Key | Action |
  |---|---|
  | `<C-Space>` | Show the menu (manual trigger) |
  | `<C-n>` / `<C-p>` | Select next / previous |
  | `<C-y>` | Accept the selected item (or the top item if none selected) |
  | `<C-e>` | Cancel — close the menu and restore what was typed |
  | `<C-b>` / `<C-f>` | Scroll the documentation window up / down |

- **BREAKING — `<CR>` no longer accepts a completion.** Enter inserts a newline in insert mode and executes the command on the command line, always. Accepting is `<C-y>` in both modes. This removes the class of accident where Enter silently commits a suggestion, and is what makes a single cross-mode keymap possible at all.
- **BREAKING — `<M-Space>` is removed.** It is replaced by `<C-Space>`, which is currently unbound anywhere in the config and is not intercepted by the Windows console.
- `<C-y>` uses blink's `select_and_accept`, not `accept`. With `preselect = false, auto_insert = false` (`lua/plugins/blink.lua:22`), plain `accept` is a no-op when nothing is highlighted; `select_and_accept` takes the top item, which is what a reader expects "accept" to mean.
- `<C-e>` moves from `hide` to `cancel`, so dismissing restores the text you had typed rather than leaving the partially-completed word behind.
- Update the three doc surfaces that promise `<M-Space>`, and document the accept key — which no page currently states for either mode.

Out of scope: binding `snippet_forward` / `snippet_backward`. Those are bound nowhere today despite `snippets` being an active source, so snippet placeholders cannot be navigated at all. That is a pre-existing gap, not one of these two defects; it is logged in `recommendations/ideas.md` for a follow-up.

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `completion-engine`: the "Completion ergonomics preserved" requirement currently mandates the exact behavior being replaced — that `<CR>` accepts and that `<M-Space>` triggers. It is rewritten around the single cross-mode keymap, with `<CR>` reserved for newline/execute and `<C-y>` as the accept key. The "Command-line completion" requirement gains the constraint that the command line uses that same keymap rather than blink's stock preset.

## Impact

- **Code:** `lua/plugins/blink.lua` only — the `keymap` table and the `cmdline.keymap` field. No other module reads these.
- **Docs:** `editor/keybindings.adoc`, `editor/code-intelligence.adoc`, `cheatsheets/core.md` (all three assert `Alt-Space`); the accept key needs stating for both modes wherever completion keys are listed.
- **Runtime behavior is touched**, so this requires a dedicated `openspec/TEST_PLAN.md` section walked through in a live Neovim session before the PR is raised — including confirming `<C-Space>` actually reaches Neovim under WSL, which is the specific failure mode that made `<M-Space>` unusable.
- **Muscle memory:** anyone used to `<CR>` accepting will have to relearn `<C-y>`. That is the deliberate cost of the fix.
- No plugin additions or removals; no change to sources, providers, or LSP capability advertisement.
