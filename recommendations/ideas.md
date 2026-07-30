# Things we'd like to add

1. Additional language support
   - javascript
   - typescript
   - assembler
   - terraform
   - lua
2. some sort of visual buffer tabbing:
   - the sidebar panels for claude.cli and avanate.nvim are awkward to read, it seems both would like to be "full screen" 
   - the terminal at the bottom of the screen requires scrolling, it too would like a "full screen"

## Things that seem broken

- `<leader>t` is supposed to toggle the treeview but it toggles the terminal if it has been opened

- `<M-Space>` (Alt-Space) is meant to bring up the completion menu manually
  (`lua/plugins/blink.lua:14`, `["<M-Space>"] = { "show", "fallback" }`), but under WSL the console
  is a Windows one and Alt-Space opens the *Windows* system menu instead. The keystroke never
  reaches Neovim, so there is currently no working manual completion trigger. Four doc pages
  promise it works. Needs either a different default trigger (e.g. `<C-Space>`) or a documented
  WSL-specific note.

- blink completion accepts with a different key depending on where you are, and neither is
  documented. In insert mode `lua/plugins/blink.lua` uses `preset = "none"` and binds
  `<CR>` = accept, `<C-n>`/`<C-p>` = select. The cmdline block (`lua/plugins/blink.lua:60`)
  falls back to blink's stock `cmdline` preset instead, where `<Tab>`/`<S-Tab>` select and
  `<C-y>` accepts. So the muscle memory built in insert mode doesn't carry over to `:`.
  No page under `docs/modules/ROOT/pages/` or `cheatsheets/` states an accept key for
  either context. Logged as a deliberate Non-Goal in the reorganize-per-plugin-docs design
  ("the blink cmdline accept-key alignment"); deciding whether to align the keys is a
  runtime change, documenting whatever they end up being is docs-only.
