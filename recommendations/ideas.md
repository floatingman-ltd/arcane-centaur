# Ideas, defects and things to keep an eye on

## Priority order — what to pick up next

Agreed running order. Details live in the sections below; this is just the queue.

1. **`marksman` and `fsautocomplete` are configured but not installed** — *Things that seem broken*. Both are `vim.lsp.enable`d and fail silently, so markdown and F# have no LSP at all: no hover, references, folding ranges or real completion. Three documentation defects compound it, including an install command naming a package that does not exist. Now also carries the F# support gap: F# has no indent support of any kind and no fold query either, making it the least capable of the "supported" languages.
2. **Fourteen capability specs have placeholder Purposes** — *Things that seem broken*. Mechanical but wide; best done as one pass.
3. **`open_url` never reaches `open` on macOS** — *Things that seem broken*. Small and well understood, but unverifiable without a Mac.

**Shipped** (2026-08-25 / 27), kept briefly for context:

- ~~`open_url` silently notifies~~ — fixed by `fix-open-url-wsl-opener`. **The diagnosis recorded here was wrong**, and worth remembering as a pattern: the INFO-notify branch it blamed was unreachable, because WSLg exports `DISPLAY=:0` and `is_console` was therefore `false`. The real cause was opener ordering — `xdg-open` won, found no Linux browser, fell through to `w3m` in a detached job with no tty, and exited `0`. Investigating turned up two further defects the entry had no inkling of: `explorer.exe` does not treat a URL containing `=` as a URL and opens a folder window instead (confirmed on a trailing `=` and a mid-query `=`; other positions untested), and WSL without WSLg would notify and open nothing.

- ~~`indentexpr` set without a query~~ and ~~markdown folding on headings~~ — both fixed by `align-treesitter-providers`. C# and Clojure also regained Neovim's own indent scripts, which the blanket override had been suppressing.
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

- **two language servers are configured and enabled but not installed, and their documentation is wrong.** `lua/config/lsp.lua` calls `vim.lsp.enable` for `marksman` (markdown) and `fsautocomplete` (F#), but neither binary is on `$PATH`. Both fail silently — the filetype simply gets no LSP, so no hover, no references, no folding ranges, and no completion beyond buffer words.

  Three documentation defects compound it:

  * `docs/.../editor/code-intelligence.adoc:32` and `docs/.../content/diagrams.adoc:394` both say `sudo apt install marksman`. **That package does not exist** in the configured repos — `apt-cache policy marksman` returns nothing. Following the instruction produces "unable to locate package".
  * `docs/.../other/architecture.adoc:100` lists **✅ marksman**, implying it is active. It is not installed.
  * Neither server appears in `getting-started.adoc`'s prerequisite table, though every other required binary does. Same class as the ripgrep/fzf gap.

  Fix direction: install both from their GitHub release binaries, matching how every other language server here is installed (`lua-language-server` in `~/.local/bin`, `janet-lsp` in `/usr/local/bin`, roslyn under `~/.local/share/roslyn`). Note LSP servers are the deliberate exception to keeping dependencies in Docker — they are editor subprocesses over stdio with direct filesystem access, and containerising them fights the design. Then correct the install instructions, drop or qualify the ✅, and add both to the prerequisite table.

  Surfaced while exploring the treesitter provider sweep: markdown's fold provider list excludes `lsp`, and checking whether marksman could supply heading folds revealed it was never installed.

  **F# is materially less supported than it looks, and `fsautocomplete` is only part of it.** The language table in `CLAUDE.md` lists F# with an LSP and a REPL, which reads as full support. What actually works today is treesitter highlighting, the iron.nvim REPL (`dotnet fsi`), easy-dotnet's test/run/build, and the `tabstop`/`shiftwidth` settings in `after/ftplugin/fsharp.lua`. What does **not** work:

  * **No LSP at all** — `fsautocomplete` is absent, so no hover, completion, references, rename, diagnostics or formatting. `lua/plugins/conform.lua:10` sets `fsharp = { lsp_format = "prefer" }`, which is inert without the server.
  * **No indent support whatsoever.** There is no `indent/fsharp.vim`, no `ftplugin/fsharp.vim`, and nvim-treesitter ships no `indents.scm` for F#. Indenting is plain `autoindent`, so a new line after `| Circle r ->` copies the previous indent rather than indenting the body. `smartindent` cannot help — it keys off `{`, `}` and `cinwords`, none of which F# uses. This also makes `>>`, `<<` and `=` unhelpful as reindent operators.
  * **No fold query either** (`folds.scm` is absent), so F# folds by indentation only — the one language in the sweep that gains nothing from it.

  Fixing the indent half probably means a plugin decision rather than configuration: `ionide/Ionide-vim` ships an `indent/fsharp.vim` that understands the offside rule and constructs like `->`, `=` and `let`. It overlaps with `fsautocomplete` (Ionide bundles its own LSP integration), so the two need reconciling rather than both being added blindly. Installing `fsautocomplete` alone buys formatting on save, not indent-as-you-type.

  Surfaced during `align-treesitter-providers` validation (AT.2), when the expectation that F# was a fully supported language turned out not to hold.

- **newline drops the cursor to column 0 in most languages — treesitter `indentexpr` is set without a query behind it.** Reported in C#: pressing Enter on an indented line puts the cursor at the left margin instead of aligning with the line above. Markdown behaves correctly, which is the clue.

  `lua/plugins/treesitter.lua:50-55` sets `vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"` for **every** filetype in `HIGHLIGHT_FILETYPES`, unconditionally. But nvim-treesitter only ships an `indents.scm` for two of them:

  * **has a query:** `lua`, `markdown`
  * **no query at all:** `commonlisp`, `clojure`, `scheme`, `fennel`, `janet_simple`, `fsharp`, `vim`, `markdown_inline`, `http`, `c_sharp`, `haskell`

  With no query the expression returns 0, and because `indentexpr` **overrides** `autoindent`/`smartindent`, the result is worse than not setting it: Vim's own indent handling is suppressed in favour of something that always answers zero. Verified by `nvim_get_runtime_file("queries/<lang>/indents.scm")` returning 0 files for all eleven.

  Likely fix: set `indentexpr` only when a query exists for the buffer's language — resolve with `vim.treesitter.language.get_lang(ft)` and check `nvim_get_runtime_file` before assigning, letting `autoindent`/`smartindent` (or `cindent` for the C-like ones) handle the rest. Worth checking the Lisp family separately, since `nvim-parinfer` and vim-sexp may already be compensating there.

  Surfaced as an aside during `replace-glow-renderer` validation; unrelated to that change and deliberately not fixed there.

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
