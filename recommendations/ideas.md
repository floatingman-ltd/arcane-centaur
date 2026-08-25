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
3. markdown folding on **headings**, not just indentation. Today `lua/plugins/ufo.lua` returns the *indent* provider for markdown, so nested lists fold and headings do not — which is not what most people expect from a document outline. The reason treesitter folding is disabled is recorded in `openspec/specs/code-folding/spec.md:48`: it "errors on special buffers such as the `glow` preview". **`replace-glow-renderer` removed glow**, so that rationale no longer applies, and treesitter folding is exactly what would provide heading folds. Worth re-testing whether the errors still occur with glow gone; if they do not, markdown could move to the treesitter provider and the `code-folding` spec would need a delta. Surfaced while validating `replace-glow-renderer` (RG.9c) — the expectation that `zM` would collapse sections is reasonable and currently unmet.

4. signature help, and a way to browse method overloads. Today there is no way to see a method's
   other overloads. Roslyn collapses them into a *single* completion item and just notes the count
   ("+16 overloads"), so the completion documentation window cannot page through them — it renders
   one item's docs and there is no second item to move to. Overloads belong to a different LSP
   request, `textDocument/signatureHelp`, which is switched off here on both available paths:
   blink's own module has `signature.enabled = false`, and `on_attach` in `lua/config/lsp.lua`
   binds no `vim.lsp.buf.signature_help`. Enabling blink's would not be sufficient on its own
   either: its window renders only `signatures[(activeSignature or 0) + 1]`
   (`signature/window.lua:54`) and the command set is just `show_signature` / `hide_signature` /
   `scroll_signature_up` / `scroll_signature_down` — there is **no overload-cycling command**. So
   this needs signature help turned on *plus* something that actually cycles signatures, with its
   own keybindings and doc updates. Surfaced while validating `fix-blink-completion-keymap`; well
   outside that change, which is a keymap consolidation.

## Things to keep an eye on

Not defects — they work as designed — but ergonomics we are not yet sure about. Left to settle with
use before deciding.

- **`<C-n>` carries several meanings, separated only by mode.** In normal mode it opens the file
  tree (`lua/keymaps.lua`); in insert mode it is both the manual completion trigger *and*
  select-next; on the command line it is select-next. The separation is clean and was verified
  (TEST_PLAN BC.10: `:verbose nmap <C-n>` resolves to `:NvimTreeOpen<CR>`, `:verbose imap <C-n>` to
  the blink mapping, no leakage either way) — but "same chord, four jobs" is a lot to hold, and it
  already caused one false failure during validation, where pressing it a moment before entering
  insert mode opened the tree instead of the completion menu.

  Worth noting if this is revisited: **the tree role is the cheapest to give up.** Once
  `fix-tree-terminal-keymaps` lands, the tree answers to `<leader>t` (toggle), `<C-t>` (toggle),
  `<leader>n` (open) and `<C-f>` (reveal) — so dropping `<C-n>` would remove nothing that is not
  already covered twice over, and would leave `<C-n>` meaning one thing: completion, in both modes
  that have it. The alternative, moving the completion trigger instead, is worse — it is constrained
  to plain `Ctrl`-plus-letter chords by the WSL console, and `<C-n>` is what stock Vim already means
  in insert mode.

  Deferred deliberately: see how it feels in daily use first.

## Things that seem broken

- the terminal opens at **reduced width when toggled from inside the tree window**, instead of full width. Measured in a 171-column terminal: opened from the text pane `winwidth(0)` is 171 (correct); opened from the tree it is 140 — which is 171 minus the 30-column tree minus its separator, i.e. the split lands below the *editor column* rather than spanning the screen. The tree stays full height beside it.

  This contradicts an existing requirement. `openspec/specs/ide-layout/spec.md` — *Requirement: Full-width terminal toggle* — says the terminal SHALL open full-width at the bottom "regardless of which window has focus when invoked", with a scenario explicitly stating "not inside the tree column". `toggle_terminal` in `lua/keymaps.lua` does use `botright split`, which should be unconditional, so something is relocating the window afterwards; nvim-tree re-establishing its own layout on `WinNew` is the obvious suspect but is **unconfirmed**. Not reproducible headlessly — a scripted run with the same arrangement produced a correct full-width 171 split, so the trigger is not understood.

  `<leader>L` (IDE layout assembly) is **not** affected — it opens its terminal full-width through the same `botright split` code, which narrows the fault to `toggle_terminal` invoked with focus already in the tree window rather than to the split call itself.

  Found during `fix-tree-terminal-keymaps` validation (TEST_PLAN TK.3/TK.4) and deliberately **not fixed there**: the terminal panel's split approach is itself under review (see the full-screen panel idea above), so effort spent on the current geometry may be wasted. Revisit if the panel survives in its present form.

- **three capability specs still reference `glow.nvim`, which no longer exists.** Found while implementing `replace-glow-renderer` (task 5.9) and deliberately *not* edited there: changing a spec outside a delta is how specs drift from the changes that are supposed to govern them. Each needs its own judgement:

  * `openspec/specs/asciidoc-inbuffer-preview/spec.md:30` — **wrong, needs a delta.** A normative scenario requires that "markdown-preview.nvim / glow.nvim SHALL behave exactly as before this change". glow.nvim is removed, so the scenario is unsatisfiable as written.
  * `openspec/specs/ide-layout/spec.md:70,73` — **wrong, needs a delta.** Names "Glow previews" among the floats the layout must not disturb, and a scenario begins "WHEN a Glow preview ... is triggered". That trigger no longer exists; the intent (floats are unaffected by the layout) is still valid and should be restated against the in-editor popup.
  * `openspec/specs/code-folding/spec.md:48` — **cosmetic only.** glow appears as an illustrative example of a special buffer where treesitter folding errors. The requirement itself (do not use treesitter folding) is unaffected, and the replacement float was checked and does not reproduce the problem. Safe to leave; worth correcting opportunistically.

  Best handled as one small follow-up change covering the two real ones, rather than folded into an unrelated branch.

- **`,sp` looks like it does nothing.** `MdServerPreview` builds the markserv URL and hands it to `util.open_url`, which deliberately skips the browser when `term.is_console` and emits an INFO notification instead (`lua/config/util.lua:51-58`). The reasoning is sound — there is no graphical browser in a console — but an INFO notify is easy to miss entirely, so the command reads as broken when it has in fact worked. Mistaken for a defect during `replace-glow-renderer` validation (RG.9b). Options: put the URL on the clipboard as well, echo it on the command line where it persists, or offer to open it via `wslview`/`explorer.exe` even in console mode, since under WSL a Windows browser *is* usually reachable. Affects any `open_url` caller, not just `,sp`.

- snippet placeholders cannot be navigated. `snippets` is an active completion source
  (`lua/plugins/blink.lua:26`), so snippet completions are offered and expand — but
  `snippet_forward` / `snippet_backward` are bound nowhere in the config, and the insert-mode
  keymap uses `preset = "none"`, so nothing supplies them by default either. Once a snippet is
  accepted there is no way to jump between its placeholders. A pre-existing gap rather than a
  regression; explicitly out of scope for the `fix-blink-completion-keymap` change, which only
  addresses the manual trigger and the cross-mode accept key.
