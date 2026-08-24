## Why

`<leader>t` toggles the terminal, but `t` reads as *tree*. Reaching for it expecting the file explorer gets a shell panel instead — reported as "`<leader>t` is supposed to toggle the treeview but it toggles the terminal".

The report's mechanism is not quite what happens: `<leader>t` is bound only to `toggle_terminal` (`lua/keymaps.lua:191`), it is not a prefix for anything, and there is no timing or which-key race involved. It is always the terminal, in every state. The defect is that the most obvious key for the tree is taken by something else, while the tree's own toggle sits on `<C-t>` — a key nobody guesses.

The tree's keymaps are also entirely unspecified. `<leader>n`, `<C-n>`, and `<C-t>` appear in `lua/keymaps.lua` and in three doc surfaces, but no capability in `openspec/specs/` states what they do, so nothing keeps them honest.

## What Changes

- **`<leader>t` becomes the file tree toggle** (`:NvimTreeToggle`) — the mnemonic the user reaches for.
- **The terminal toggle moves to `<leader>T`.** Its behavior is unchanged: same full-width bottom split, same persistent shell, same fixed height. Only the key differs. It is deliberately *not* removed — `<leader>L` (IDE layout assembly) opens the terminal through the same code path and depends on it.
- **The open-only tree keymaps are kept as-is**: `<leader>n` and `<C-n>` open the tree. Both already work and are already documented.
- **BREAKING — the global `<C-t>` tree toggle is removed.** It was never reliable: nvim-tree binds `<C-t>` buffer-locally inside the tree window to *Open: New Tab* (`nvim-tree/keymap.lua:64`), and a buffer-local mapping wins over a global one. So `<C-t>` could open the tree but never close it from inside — it silently opened a tab instead. Found during validation. `<leader>t` is now the single toggle.
- **The file tree keymaps become specified.** `ide-layout` gains a requirement covering the tree's open and toggle bindings, so the config and the docs have something to be checked against.
- Update the three doc surfaces that state `<leader>t` toggles the terminal, and add the new tree binding.

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `ide-layout`: the "Full-width terminal toggle" requirement names `<leader>t` as the terminal key throughout — it is rewritten around `<leader>T`, with the terminal's actual behavior (full-width `botright` split, focus-independent) unchanged. The capability also gains a new requirement specifying the file tree's own keymaps, including `<leader>t` as the toggle, which nothing specifies today.

## Impact

- **Code:** `lua/keymaps.lua` only — the `<leader>t` binding at line 191 moves to `<leader>T`, and a new `<leader>t` binding for `:NvimTreeToggle` is added near the other tree maps (lines 87–90). `toggle_terminal` itself is untouched.
- **Docs:** `editor/navigation.adoc:51`, `editor/keybindings.adoc:124`, and `cheatsheets/core.md:48` all state that `<leader>t` toggles the terminal; each needs the new key plus the new tree binding. The tree tables in `navigation.adoc:117-118`, `keybindings.adoc:71-72`, and `cheatsheets/core.md:39-40` gain a row.
- **Runtime behavior is touched**, so this requires a dedicated `openspec/TEST_PLAN.md` section walked through in a live Neovim session before the PR is raised.
- **Muscle memory:** anyone using `<leader>t` for the terminal must move to `<leader>T`. Small, and the shifted key is adjacent.
- Explicitly not affected: `<leader>L` layout assembly, `:Bd`, the quit guardrails, and float behavior — all other `ide-layout` requirements stand unchanged.

Out of scope: the sidebar/terminal full-screen and buffer-tabbing ideas in `recommendations/ideas.md`. Those may later supersede the bottom terminal panel entirely; this change deliberately does the cheap key move rather than pre-empting that work.
