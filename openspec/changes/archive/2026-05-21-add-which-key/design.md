## Context

The config has 81 keymaps across `lua/keymaps.lua`, `lua/config/lsp.lua`, `after/ftplugin/`, and plugin files. 33 have `desc` fields; 48 do not. which-key.nvim shows a popup when the user pauses after a prefix key, using the existing `desc` metadata — no keymap refactoring needed. The value comes from two things: (1) the plugin itself, and (2) filling in missing `desc` fields so the popup is fully populated.

Neovim's `vim.keymap.set` already accepts a `desc` field in the opts table. which-key reads it automatically. No API changes needed.

## Goals / Non-Goals

**Goals:**
- Install which-key.nvim and make it show on `<leader>` pause
- Register group labels for multi-key prefixes (`<leader>gc`, `<leader>os`)
- Add `desc` to all keymaps currently missing it

**Non-Goals:**
- Reorganising or renaming existing keymaps
- Adding new keymaps (those belong in their respective feature changes)
- which-key for `<localleader>` (filetype keymaps are self-contained; popup noise outweighs benefit there)

## Decisions

### Use `opts = {}` with a minimal `config` block
which-key works out of the box with no configuration. The only custom setup needed is group label registration via `require("which-key").add(...)`. No presets, no icons config — keep it minimal.

**Alternatives considered:** full `opts` config with icons, delay tuning, window styling. Rejected — defaults are good and TokyoNight styles the popup correctly without any tweaks.

### Register group labels for prefix clusters only
Only `<leader>gc` (Copilot) and `<leader>os` (OpenSpec) form true multi-key clusters worth labelling. Single-letter `<leader>` keys (`n`, `t`, `e`, etc.) are self-describing via their `desc` field.

**Alternatives considered:** labelling every `<leader>` subkey. Rejected — adds noise without clarity.

### Add `desc` inline, not via which-key's `add()`
Descriptions belong on the `vim.keymap.set` call itself, not registered separately via which-key. This keeps keymap intent co-located with the keymap definition and works independent of which-key being loaded.

## Risks / Trade-offs

- **`<space>` keymaps in haskell.lua** use `<space>` directly (not `<leader>`). They will appear in the which-key popup but with raw `<space>` prefix. Low impact — Haskell-only, buffer-local. → No mitigation needed; note in tasks.
- **Popup on `z` keys**: which-key also shows on `z` prefix pause. This is a feature (helps with fold keys once `add-code-folding` lands) but is a minor behaviour change. → Accept.
