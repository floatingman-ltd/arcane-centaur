# Ideas, defects and things to keep an eye on

## Priority order — what to pick up next

Agreed running order. Details live in the sections below; this is just the queue.

1. **Spell suggestions never reach the blink menu** — *Things that seem broken*. **High priority to review.** The spell source is wired up and works, but every suggestion is filtered out before display, so completing a misspelled word silently does nothing. One-line fix with a real trade-off attached, so it needs a decision rather than just an edit.
2. **F# has no indent support of any kind** — *Things that seem broken*. What is left of the old "servers not installed" entry now that `install-language-servers` has shipped. F# now has an LSP, folds and format-on-save, but pressing Enter after `->` or `=` still copies the previous indent rather than indenting the body. Needs a plugin decision rather than configuration, so it wants a decision before an edit.
3. **Fourteen capability specs have placeholder Purposes** — *Things that seem broken*. Mechanical but wide; best done as one pass.
4. **`open_url` never reaches `open` on macOS** — *Things that seem broken*. Small and well understood, but unverifiable without a Mac.

**Shipped** (2026-08-25 / 27), kept briefly for context:

- ~~`open_url` silently notifies~~ — fixed by `fix-open-url-wsl-opener`. **The diagnosis recorded here was wrong**, and worth remembering as a pattern: the INFO-notify branch it blamed was unreachable, because WSLg exports `DISPLAY=:0` and `is_console` was therefore `false`. The real cause was opener ordering — `xdg-open` won, found no Linux browser, fell through to `w3m` in a detached job with no tty, and exited `0`. Investigating turned up two further defects the entry had no inkling of: `explorer.exe` does not treat a URL containing `=` as a URL and opens a folder window instead (confirmed on a trailing `=` and a mid-query `=`; other positions untested), and WSL without WSLg would notify and open nothing.

- ~~`indentexpr` set without a query~~ and ~~markdown folding on headings~~ — both fixed by `align-treesitter-providers`. C# and Clojure also regained Neovim's own indent scripts, which the blanket override had been suppressing.
- ~~`marksman` and `fsautocomplete` configured but not installed~~ — fixed by `install-language-servers`, along with the three documentation defects (including the `sudo apt install marksman` package that does not exist). Validation turned up two things the entry had no inkling of: **fsautocomplete does not ship Fantomas**, and without it a write does not skip formatting but raises a blocking interactive install prompt on every save; and **a bare `.fs` outside any project can never be answered** — every request fails with `Couldn't find <path> in LoadedProjects`, and merely opening one logs an `UnhandledPromiseRejection`. The F# indent gap is deliberately untouched and is now queue item 2 in its own right.
- ~~Three capability specs still reference `glow.nvim`~~ — `code-folding` was resolved by `align-treesitter-providers`; the remaining two by `retire-glow-spec-references`.

Everything else in this file is unranked and can be picked up opportunistically.

# Things we'd like to add

1. Additional language support
   - javascript
   - typescript
   - assembler
   - terraform
   - lua
   - **F# — bring the existing support up to the level the docs claim.** Unlike the others this is
     not a new language: it is already listed as supported, with a parser, a REPL and easy-dotnet
     integration. But it has no LSP installed, no indent support of any kind, and no fold query, so
     it is the least capable of the "supported" languages in practice. See the entry under *Things
     that seem broken* for the full inventory.
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

- **spell suggestions never reach the blink menu, because blink filters them out.** Typing a misspelled word and pressing `<C-n>` shows nothing. Reported as "worked when the word was incomplete, does nothing once it is complete", which is exactly the shape of the bug.

  The source is wired up correctly and does work: `f3fora/cmp-spell` is bridged through `blink.compat` as the `spell` provider (`lua/plugins/blink.lua:74-84`), enabled whenever `'spell'` is on, and `vim.fn.spellsuggest("recieve")` returns `{ receive, relieve, reserve, receiver, deceive }`. The suggestions are fetched and then discarded.

  `cmp-spell` sets each suggestion's `filterText` to **the suggestion itself** when `keep_all_entries = false` (`cmp-spell/lua/cmp-spell/init.lua:67`), and blink filters candidates on `filterText` (`blink.cmp/lua/blink/cmp/fuzzy/lua/init.lua:56`). A correction is by definition not a fuzzy match of its own misspelling — `receive` is not a subsequence of `recieve`, the transposed `ie`/`ei` breaks the ordering — so every candidate is dropped and the menu closes with nothing in it.

  Measured against blink's own matcher rather than reasoned about:

  ```
  spellsuggest: { "receive", "relieve", "reserve", "receiver", "deceive" }
  keep_all_entries=false (current config)    typed=recieve   kept=0  {}
  keep_all_entries=true  (filterText=input)  typed=recieve   kept=5  { "receive", "relieve", ... }
  control: real prefix, filterText=label     typed=rec       kept=2  { "receive", "receiver" }
  ```

  The control line explains the "worked when incomplete" half: `rec` is a true prefix, so it survives filtering. Finishing the word into a misspelling breaks the match.

  **Fix:** one line — `opts = { keep_all_entries = true }` at `lua/plugins/blink.lua:83`. The menu then opens on a misspelled word and is navigated with the keys that already work: `<C-n>`/`<C-p>` to move, `<C-y>` to accept, `<C-e>` to dismiss. It is the same menu, so no new keymap is needed and nothing has to be routed out of `z=`.

  **The trade-off is why this needs review rather than just applying.** With `keep_all_entries = true`, spelling suggestions stop being filtered *at all*: every word of three or more characters offers the full `spellsuggest` list while `'spell'` is on, not only misspelled ones. That is the documented purpose of the option, but it is materially noisier in prose-heavy buffers. `score_offset = -3` keeps the entries below LSP items, which may or may not be enough. Worth trying live before committing to it.

  **Not a defect, but the thing that made it look like one:** normal-mode `<C-n>` is `:NvimTreeOpen` (`lua/keymaps.lua:99`), and blink's keys are insert-mode and buffer-local (`preset = "none"`). Leave insert mode and `<C-n>` opens the file tree. `<C-t>` is not bound anywhere in the config at all — nvim-tree claims it buffer-locally inside the tree window for *Open: New Tab*. This is the same confusion as `fix-blink-completion-keymap`'s BC.1.

  **Unverified, and left that way deliberately:** native `<C-x>s` (insert-mode spell completion) would give a navigable popup with no config change, and blink binds no `<C-x>`. Whether it coexists cleanly with blink's auto-show could not be tested here — headless Neovim will not drive insert-mode input, which defeated two end-to-end probes before the matcher was called directly instead. Worth thirty seconds in a live session before adopting the config change, since it may make it unnecessary.

  Surfaced while validating `install-language-servers`, and entirely unrelated to it.

- **F# has no indent support of any kind.** `install-language-servers` gave F# a working LSP (`fsautocomplete`), LSP-backed folds and Fantomas format-on-save. It deliberately did **not** fix indentation, and this is what remains.

  There is no `indent/fsharp.vim`, no `ftplugin/fsharp.vim`, and nvim-treesitter ships no `indents.scm` for F#. Indenting is plain `autoindent`, so a new line after `| Circle r ->` or `let inner y =` copies the previous indent rather than indenting the body. `smartindent` cannot help — it keys off `{`, `}` and `cinwords`, none of which F# uses. This also makes `>>`, `<<` and `=` unhelpful as reindent operators. Confirmed again under `install-language-servers` LS.7: a line indented 4 and ending in `=` yields a new line indented 4, not 8, with `indentexpr` empty.

  Fixing it probably means a plugin decision rather than configuration: `ionide/Ionide-vim` ships an `indent/fsharp.vim` that understands the offside rule and constructs like `->`, `=` and `let`. It overlaps with `fsautocomplete` (Ionide bundles its own LSP integration), so the two need reconciling rather than both being added blindly.

  Note that Fantomas will reformat the whole file on save, which papers over indentation mistakes after the fact but does nothing for indent-as-you-type.

  Surfaced during `align-treesitter-providers` validation (AT.2); carried forward through `install-language-servers`, which measured it but left it alone.

- **fourteen capability specs have placeholder Purposes.** `openspec archive` writes `TBD - created by archiving change <name>. Update Purpose after archive.` whenever a change creates a new capability, and relies on someone circling back. Nobody has, going back to changes 01-08: `asciidoc-inbuffer-preview`, `asciidoc-syntax`, `avante-runtime`, `claudecode-session`, `completion-engine`, `diagnostics-panel`, `dotnet-debugging`, `dotnet-test-runner`, `editor-commenting`, `markdown-native-rendering`, `statusline`, `surround-text-objects`, `todo-comments`, `treesitter-textobjects`.

  The Purpose is the one part of a spec that says *what the capability is for*, so anyone arriving at these gets requirements with no framing. It also cannot be fixed by a delta — deltas operate on requirements, not Purpose prose — so `openspec archive` will never resolve it and each needs a direct edit.

  Best as a single pass rather than piecemeal: fourteen short paragraphs, each derivable from the requirements already in the spec, and the context is cheapest read together. Surfaced during `retire-glow-spec-references`, where `markdown-native-rendering` was deliberately left in this state rather than becoming the one exception.

- **`open_url` never reaches `open` on macOS.** `M.is_console` is derived solely from `$DISPLAY`/`$WAYLAND_DISPLAY` (`lua/config/terminal.lua:77`), and macOS sets neither unless XQuartz is running. So `is_console` is `true` there, the console branch short-circuits, and `open` — which sits in the opener list specifically for macOS — is never reached. The same one-line exemption that fixed the equivalent WSL case would fix it: `if term.is_console and not (term.is_wsl or vim.fn.has("mac") == 1)`. Deliberately not applied during `fix-open-url-wsl-opener`, because there is no macOS here to validate against and shipping an unverifiable behaviour change is worse than logging it. Anyone with a Mac can close this in minutes.

  Worth noting the root cause is `is_console` answering "is a display exported?" when callers want "can a browser be reached?". Fixing the flag itself would touch six other call sites, where "no display" means something different in each — so the narrow exemptions are probably right, but the `console-detection` capability deserves a look eventually.

- snippet placeholders cannot be navigated. `snippets` is an active completion source
  (`lua/plugins/blink.lua:26`), so snippet completions are offered and expand — but
  `snippet_forward` / `snippet_backward` are bound nowhere in the config, and the insert-mode
  keymap uses `preset = "none"`, so nothing supplies them by default either. Once a snippet is
  accepted there is no way to jump between its placeholders. A pre-existing gap rather than a
  regression; explicitly out of scope for the `fix-blink-completion-keymap` change, which only
  addresses the manual trigger and the cross-mode accept key.
