# Ideas, defects and things to keep an eye on

## Priority order — what to pick up next

Agreed running order. Details live in the sections below; this is just the queue.

1. **Editing at distance — GitHub issues #187–192** — *Things we'd like to add*. Six open enhancements that are really one theme with a dependency order. `#189` is the enabler and should land first; `#191` is a project in its own right and should land last. Two caveats not recorded in the issues themselves make the sequencing matter — see the entry.

Shipped work is **deleted from this file**, not archived in it. The record lives in three places
that are already authoritative: the implementation in `openspec/changes/archive/<date>-<name>/`, the
validation in `openspec/TEST_PLAN.md`, and anything a *user* needs in the Antora docs under
`docs/modules/ROOT/pages/`. A wish list that also serves as a changelog goes stale in both roles —
this file carried two items as shipped *and* pending simultaneously before the 2026-09-09 audit.

Before deleting an entry, check its facts are recorded in one of those three places. If a shipped
entry is the only place something is written down, that thing is in the wrong place: move it, then
delete the entry.

**Declined** — decisions taken, not work waiting:

- ~~Spell suggestions never reach the blink menu~~ — **not applying the fix; current behaviour accepted.** The analysis below stands and the one-line change still works, but it was reviewed and judged not worth its trade-off: `keep_all_entries = true` stops filtering spelling suggestions *at all*, so every word of three or more characters would offer the full `spellsuggest` list while `'spell'` is on. Noisier in exactly the prose buffers where spelling help matters. Native `z=` in normal mode already lists suggestions, and `<C-x>s` is available in insert mode. **Open to revisiting** if the absence starts to bite in practice — the detailed entry is kept below precisely so a change of heart does not have to re-derive it.

  **`<C-x>s` confirmed live:** it opens the native spelling popup as advertised, so blink does not swallow `<C-x>` — which was the one open question and the reason this could not be settled from the config alone (`<C-x>` is bound nowhere in insert mode, and blink binds only `<C-f> <C-p> <C-b> <C-k> <C-n> <C-e> <C-y>`). That makes the decision above better founded than a bare deferral: a working native route exists. Now documented in `editor/code-intelligence.adoc`, `editor/keybindings.adoc` and `cheatsheets/core.md`, none of which mentioned spelling suggestions at all before.

- ~~`open_url` never reaches `open` on macOS~~ — **won't fix. macOS is out of scope for this configuration.** The diagnosis was sound and the fix was a one-line exemption, but nobody here runs macOS and nobody intends to, so it would ship an unverifiable behaviour change to serve a platform this config does not target. Anyone wanting Neovim tooling on a Mac should expect to do their own platform work. Do not re-log this; the `open` entry left in `lua/config/util.lua`'s opener lists is harmless dead weight on Linux and WSL, where `open` is not an executable.

Everything else in this file is unranked and can be picked up opportunistically.

# Things we'd like to add

1. **Additional language support — JavaScript/TypeScript, assembler, Terraform, Lua.** Expanded 2026-09-11 from a bare list into what each would actually cost. No implementation implied; the point is that these four are not comparable in size, and one of them is nearly done.

   **What "adding a language" means here**, derived from the existing ones rather than invented. Every entry below is measured against this list:

   | Surface | Where |
   |---|---|
   | LSP | `lua/config/lsp.lua` — `vim.lsp.config`/`vim.lsp.enable` with the shared `on_attach` |
   | Formatting | `lua/plugins/conform.lua` — `formatters_by_ft` |
   | Treesitter | `lua/plugins/treesitter.lua` — the `ts.install{...}` list |
   | Filetype maps | `after/ftplugin/<ft>.lua` — `<localleader>` REPL/eval maps, indent |
   | Guide + cheatsheet | `docs/modules/ROOT/pages/languages/<lang>.adoc` and `<lang>-cheatsheet.adoc` |
   | Nav | `docs/modules/ROOT/nav.adoc` — one `xref:` per page |
   | Setup matrix | a row in `languages/setup.adoc`, per the `docs-language-setup` capability |
   | Spec + validation | an OpenSpec change and a `TEST_PLAN.md` section |

   Guides must follow `docs-guide-template`: usage-first, a dynamic jump menu, and Prerequisites distinct from Setup.

   ---

   **1a. JavaScript + TypeScript — one piece of work, and the largest of the four.** Grouped deliberately: for frontend work the toolchain is shared, and splitting them would duplicate every surface above.

   The size comes from breadth rather than difficulty. **Four filetypes** (`javascript`, `typescript`, `javascriptreact`, `typescriptreact`) before counting `json`, `css` and `html`, which frontend work drags in and of which only `html` has an ftplugin today. **Treesitter** needs `javascript`, `typescript`, `tsx` and `jsdoc` at minimum. **Formatting** is a decision, not a default — prettier is conventional, biome is the faster single-binary alternative, and picking one commits the repo to a Node-ecosystem dependency it does not currently carry.

   **The LSP question is the real fork.** `ts_ls` is the direct successor to tsserver; `vtsls` wraps it and is what most large setups have moved to. Either way a second server is usually wanted — `eslint` — and this configuration has never run two servers against one buffer, so `on_attach` sharing and diagnostic precedence would both be exercised for the first time.

   **Not blocked on the containers principle**, though it looks like it should be. Language servers are editor tooling, not services — `fsautocomplete`, `marksman` and `lua_ls` all already run on the host. Node would join them. The principle bites on anything *served*, and there the existing `bracey.vim` live-preview and `http_preview` surfaces already exist to build on.

   Worth noting there is already a frontend foothold: `after/ftplugin/html.lua` and bracey. This would be extending that rather than starting cold.

   **1b. Assembler — the smallest surface and the largest unanswered question.** Everything hinges on something the wish list never said: *which* assembler, and what for.

   Architecture and syntax are not one choice but two — x86-64 versus ARM versus RISC-V, and GAS versus Intel/NASM syntax within x86. They select different tooling. `asm-lsp` covers x86/x86-64/ARM/RISC-V and is the obvious LSP candidate; `nasm_language_server` exists if NASM is the target. nvim-treesitter has an `asm` parser. **There is effectively no formatter** — nothing comparable to stylua or Fantomas exists for assembly, so `conform` would simply have no entry, which is a first for this config.

   The prior question is purpose. Reading compiler output, embedded work, and CTF-style reverse engineering want different things — the first needs little more than highlighting and would be satisfied by treesitter alone, while the last wants a debugger. **Answer that before costing it**, because the honest range runs from "a parser and a guide" to "a DAP integration".

   **1c. Terraform — the cleanest fit of the four.** Every surface has an obvious, official answer, which is unusual.

   `terraformls` is HashiCorp's own server. Formatting is `terraform fmt`, which `conform` already ships as a built-in formatter, so that line is a one-liner. Treesitter needs `terraform` and `hcl`. Filetypes are `terraform`, `hcl` and `terraform-vars`.

   Two things are specific rather than generic. `terraform console` is a genuine REPL and would fit the existing iron.nvim pattern the way `dotnet fsi` does for F# — an unusually good match for a language nobody thinks of as having a REPL. And the `terraform` binary is a prerequisite the docs must state: `terraformls` leans on it, and `terraform fmt` *is* it. It is a CLI tool rather than a service, so it sits with tmux and ripgrep rather than with the Docker-hosted services.

   **1d. Lua — already ~90% done; this is a finishing job, not an addition.** It has `lua_ls` with a full workspace configuration (as of `configure-lua-ls-workspace`), `stylua` in conform, the `lua` treesitter parser, `after/ftplugin/lua.lua`, `docs/.../languages/lua.adoc`, and three capability specs — `lua-lsp`, `lua-ftplugin`, `lua-formatting`.

   **What is actually missing is the cheatsheet.** There is no `lua-cheatsheet.adoc`, and `nav.adoc` shows the gap unambiguously: every other language reads `Guide` then `Cheatsheet`, while Lua reads `Guide` alone. That is a docs task of a few hours with no runtime risk, and it is the single cheapest item in this entire wish list.

   Two smaller gaps behind it. There is **no REPL binding** — Neovim's own `:lua` is always there, and Conjure has a Neovim-Lua client that would fit the existing Conjure setup. And there is **no DAP support**; `jbyuki/one-small-step-for-vimkind` is the standard adapter for debugging Neovim Lua specifically, which is what Lua is used for in this repository.

   ---

   **If these are ever ranked:** Lua's cheatsheet first, because it closes a visible inconsistency for almost nothing. Terraform second, because every answer is official and the REPL fit is genuinely nice. JavaScript/TypeScript third and treated as a project, since it introduces a Node dependency and the first two-server buffer. Assembler last, and not costed at all until the purpose question is answered.

2. some sort of visual buffer tabbing:
   - the sidebar panels for claude.cli and avanate.nvim are awkward to read, it seems both would like to be "full screen" 
   - the terminal at the bottom of the screen requires scrolling, it too would like a "full screen"
3. signature help, and a way to browse method overloads. Today there is no way to see a method's
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

4. port the vendored F# indent script from Vimscript to Lua. `add-fsharp-indent` vendors
   `indent/fsharp.vim` from Ionide-vim — 283 lines, ~200 of code, 8 functions — rather than
   installing the plugin. Since we own the file anyway, Lua would match the rest of this
   configuration and, more usefully, would be **unit-testable**: upstream ships no tests at all,
   so today the only safety net is the TEST_PLAN cases.

   **The honest catch is that most of it cannot actually become Lua.** The logic rests on 31
   `=~`/`!~` comparisons across ~21 Vim-flavoured regexes — `'^\(let\|type\).*=\(\s\({\|[\|[|\)\)\?$'`,
   `'\v^\s*(.{-})\s*$'` and the like. Lua patterns have no alternation, no grouped quantifiers,
   no `\v` magic and no `.\{-}`, so every one would have to stay a Vim regex behind
   `vim.regex()` or `vim.fn.match()`. The built-ins are the same story: `shiftwidth()` ×17,
   `indent()` ×10, `getline()` ×7, and one `searchpairpos()` with a skip predicate. And
   `indentexpr` must remain a Vim expression regardless — `vim.bo.indentexpr =
   "v:lua.require'...'.indentexpr()"`, the pattern `lua/plugins/treesitter.lua` already uses.

   So the realistic result is Lua control flow wrapping the same regexes and the same built-ins:
   roughly 85% of the substance unchanged, a syntax change more than an idiom change.

   **Costs, in order.** It kills the upstream diff path, which is the whole maintenance strategy
   recorded in that change's D1 and D5 — refreshing becomes a re-port rather than a diff against
   a known commit. There are 31 branch points to translate with no upstream test suite to check
   the translation against. And it resets the battle-testing on a file whose value is precisely
   that real editing has found and fixed bugs in it since 2014.

   **If it is ever done**, it should be its own change *after* the vendoring has been lived with,
   so a misindent is unambiguously a translation error rather than an inherited one, and so the
   TEST_PLAN corpus from `add-fsharp-indent` exists to port against. Note that the treesitter
   comment/string predicate from that change (`lua/config/fsharp_indent.lua`) is already Lua, so
   the genuinely environment-specific part is Lua either way — which is a reason the rest is less
   urgent than it first looks.

5. report the vendored F# indent script's `synID` problem upstream. Sits next to idea 4 because it
   is the other half of the same question: what our relationship with `ionide/Ionide-vim` should be.

   `add-fsharp-indent` deviates from upstream in exactly one function. Upstream's
   `s:IsInCommentOrString()` detects comments and strings with `synID()`/`synIDattr()`, which
   require a Vim `:syntax` file. Under treesitter highlighting no syntax file is sourced at all —
   measured on `lua` and `markdown` buffers, both of which Neovim *does* ship syntax files for:
   `b:current_syntax` is `nil` and `synID()` returns `0`. So the predicate always answers "not a
   comment", and since it is the skip function handed to `searchpairpos()`, brace, bracket and
   paren matching cannot skip delimiters written inside comments or string literals.

   **Scope it accurately if reporting it.** This is not "every Ionide-vim user" — the plugin ships
   its own `syntax/fsharp.vim`, so anyone relying on that is unaffected. It hits users who
   highlight F# with nvim-treesitter instead, which suppresses the syntax file. Still a real
   population, but the narrower claim is the true one.

   **Why bother, given we have already fixed it locally.** Our fix lives in
   `lua/config/fsharp_indent.lua` and is a declared deviation, which means every future refresh of
   the vendored file has to re-apply it — and would revert it *silently* if it did not, because the
   reverted predicate returns a plausible answer rather than erroring. An upstream fix is the only
   thing that ends that obligation and lets the file go back to byte-identical.

   Deliberately **not** a task in `add-fsharp-indent`. It depends on a third party's review cycle,
   and a change should not sit permanently incomplete waiting on someone else — which is precisely
   the limbo `install-language-servers` was in for weeks. Zero effect on this repository either
   way; it is upstream hygiene with a long-term payoff, so it belongs here rather than in a task
   list.

6. **editing at distance — the SSH/tmux cluster, GitHub issues #187–192.** Six open `enhancement`
   issues, all raised 2026-09-08. Treat them as one piece of work with an order, not six tickets:
   `#189` enables two of the others, and `#190` and `#191` actively collide.

   Every claim in them was verified against the code on 2026-09-09; they are accurate.

   **Dependency shape.**

   ```
   #189 (is_remote flag)  ─┬─> #187 (lualine refresh)
                           └─> #188 (ttimeoutlen)
   #191 (capability detection)  ─> independent, and the hard one
   #190 (docs)  ─> independent; #192's docs half folds into it
   ```

   | # | Effort | Risk | Grounding |
   |---|---|---|---|
   | `#189` detect remote once in `options.lua` | small, ~3 lines | low | slots into the existing `term.is_wsl` / `term.is_console` pattern at `options.lua:66-96` |
   | `#188` set `ttimeoutlen` explicitly | trivial, 3 lines | low but **felt** | confirmed unset, so on the 50 ms default; 100 ms makes `<Esc>` measurably slower locally, so it needs a live feel-test rather than a headless check |
   | `#187` raise lualine `refresh` when remote | small, ~6 lines in a 39-line file | low | `refresh` confirmed absent. Check first that nothing in `lualine_b` depends on the timer rather than autocommands, or it goes stale at 5000 ms |
   | `#192` preview servers bind to the wrong host | medium, or small if docs-only | low | all three ports confirmed fixed — `mdpreview` 8090, `marp` 8880, `http_preview` 8092 — which is what makes a documented `LocalForward` block sufficient |
   | `#190` document the terminal-side setup | medium, docs only | none | new page plus a `nav.adoc` entry; tmux, `ControlMaster`, mosh. No runtime change, so no TEST_PLAN section |
   | `#191` capability detection fails over SSH and in tmux | **large** | **high** | see below |

   **Why `#191` is the outlier.** `detect()` returns a terminal *name* and the three capabilities are
   derived by membership in name lists. `sshd` forwards none of the identifying variables, so a remote
   session falls to `"unknown"` and `has_nerd_font`, `has_undercurl` and `has_truecolor` all go false
   together — losing the colorscheme on a terminal that renders it perfectly. The issue's framing is
   right and it is architectural: **the capability belongs to the local emulator, not the host Neovim
   runs on.** Fixing it means changing what `terminal.lua` is, from "which terminal" to "what can the
   display do", with per-capability detection. That reaches **10 require sites and 23 flag uses**, and
   `console-detection` is an existing capability spec, so it is spec-affecting and needs its own
   OpenSpec change plus validation across local, WSL, console, SSH and tmux.

   **Two caveats that are not in the issues, and that decide the order.** The first was recorded wrongly on 2026-09-09 and is corrected below; read the correction rather than the claim it replaces.

   - **~~`#190` and `#191` collide.~~ Corrected 2026-09-10 — the collision is far narrower than first recorded, and does not affect this machine.** The original claim was that `detect()` short-circuits on `$TMUX` before identifying the real terminal, and that recommending tmux therefore *costs the colorscheme*. Both halves are wrong. The `$TMUX` test is **sixth of seven** in `detect()` (`lua/config/terminal.lua:43`) — after Alacritty, Windows Terminal, VTE, Apple Terminal and the Linux TTY — so it is a last resort before `"unknown"`, not a short-circuit. Measured on WSL + Windows Terminal, outside and then inside a tmux pane: `name=wt nerd=true undercurl=true truecolor=true` both times, because `WT_SESSION` is inherited by the pane. tmux costs nothing on the machine this config is developed on.

     The real collision is this: tmux rewrites `$TERM` to `tmux-256color`, so a terminal identified **only** by `$TERM` degrades inside it. Alacritty on Linux is the one such case in `detect()` today, since `TERM_PROGRAM` is macOS-only for it (see the comment at `terminal.lua:19`). Terminals that export their own variable — `WT_SESSION`, `VTE_VERSION` — are unaffected. Over SSH the question is moot: bare SSH already lands on `"unknown"` with all three capabilities false, so tmux adds no loss there. `#191` is what costs the colorscheme over SSH; tmux is not.

     **Consequence for the order: `#191` does not block `#190`.** What `#190` needs is not a warning but two tmux settings — `set -g default-terminal "tmux-256color"` and `set -ga terminal-overrides ",*:Tc"`. Without the second, tmux downsamples 24-bit colour even when `has_truecolor` reports true, because that flag is derived from the terminal *name* and not from anything tmux actually passes through. A flag that reads true while the rendering is wrong needs an eyes-on check, not a headless one.

   - **`is_remote` will be wrong in exactly the setup `#190` recommends — but it is resolvable.** `SSH_TTY` and `SSH_CONNECTION` are both absent inside a tmux session started *before* the SSH connection, because tmux cannot update the environment of panes that already exist; `#189`'s own notes say so and propose accepting it. **Verified 2026-09-10 (tmux 3.4):** `SSH_CONNECTION` is in tmux's default `update-environment`, so the server holds the attached client's value even when the pane does not. `tmux show-environment SSH_CONNECTION` returns it, printing a leading `-` when tmux knows the variable to be unset — which makes "unset" and "no answer" distinguishable, and the check reliable. Querying it when `$TMUX` is set closes the gap for one subprocess at startup, inside tmux only. Decide this before `#187` and `#188` are built on the flag, or remote behaviour applies in some remote sessions and not others.

   **Suggested order:** `#189`, then `#188`+`#187` bundled as one change with a shared TEST_PLAN section, then `#190` with `#192`'s `LocalForward` table folded into it, then `#191` alone. The first four are plausibly an afternoon and two OpenSpec changes; the last is its own project. The correction above frees `#190` to be picked up independently of `#191` if convenient, provided it carries the two tmux settings.

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

  Worth noting if this is revisited: **the tree role is the cheapest to give up.** Since
  `fix-tree-terminal-keymaps` landed (2026-08-24), the tree answers to `<leader>t` (toggle), `<C-t>` (toggle),
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

- **spell suggestions never reach the blink menu, because blink filters them out.** **Reviewed and accepted as-is — see *Declined* above. Kept for the analysis, not as pending work.** Typing a misspelled word and pressing `<C-n>` shows nothing. Reported as "worked when the word was incomplete, does nothing once it is complete", which is exactly the shape of the bug.

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

  **Fix, if revisited:** one line — `opts = { keep_all_entries = true }` at `lua/plugins/blink.lua:84`. The menu then opens on a misspelled word and is navigated with the keys that already work: `<C-n>`/`<C-p>` to move, `<C-y>` to accept, `<C-e>` to dismiss. It is the same menu, so no new keymap is needed and nothing has to be routed out of `z=`.

  **The trade-off is why this was reviewed rather than just applied, and is the reason it was declined.** With `keep_all_entries = true`, spelling suggestions stop being filtered *at all*: every word of three or more characters offers the full `spellsuggest` list while `'spell'` is on, not only misspelled ones. That is the documented purpose of the option, but it is materially noisier in prose-heavy buffers. `score_offset = -3` keeps the entries below LSP items, which may or may not be enough. Worth trying live before committing to it.

  **Not a defect, but the thing that made it look like one:** normal-mode `<C-n>` is `:NvimTreeOpen` (`lua/keymaps.lua:99`), and blink's keys are insert-mode and buffer-local (`preset = "none"`). Leave insert mode and `<C-n>` opens the file tree. `<C-t>` is not bound anywhere in the config at all — nvim-tree claims it buffer-locally inside the tree window for *Open: New Tab*. This is the same confusion as `fix-blink-completion-keymap`'s BC.1.

  **Unverified, and left that way deliberately:** native `<C-x>s` (insert-mode spell completion) would give a navigable popup with no config change, and blink binds no `<C-x>`. Whether it coexists cleanly with blink's auto-show could not be tested here — headless Neovim will not drive insert-mode input, which defeated two end-to-end probes before the matcher was called directly instead. Worth thirty seconds in a live session before adopting the config change, since it may make it unnecessary.

  Surfaced while validating `install-language-servers`, and entirely unrelated to it.

- **two spec requirements are out of date, found while writing the Purposes on 2026-09-11.** Neither is a code defect; both are specs that describe a state the repository has moved on from, and correcting a requirement needs its own change rather than a prose edit.

  **`treesitter-textobjects` — *Branch-consistent treesitter setup* requires the `master` branch.** Both plugins are pinned to `main` (`lua/plugins/treesitter.lua`), changed by `align-treesitter-providers` because the master-branch API crashes on Neovim 0.12. The requirement's *intent* is still exactly right — the two plugins must share a branch so the configured API is the one that runs — so this is a one-word correction to the branch it names, not a rethink.

  **`asciidoc-inbuffer-preview` specifies a capability that does not exist.** markview is not installed and there is no `<localleader>mv` toggle; it needs `cathaysia/tree-sitter-asciidoc`, absent from nvim-treesitter. The deferral is recorded at `lua/plugins/asciidoc.lua` and in `CLAUDE.md`, but the spec reads as though the feature shipped. Its Purpose now says plainly that the requirements describe intent rather than behaviour, which is the honest stopgap; the real question is whether an unimplemented capability should hold a spec at all.

- **`is_console` answers the wrong question.** `M.is_console` is derived solely from `$DISPLAY`/`$WAYLAND_DISPLAY` (`lua/config/terminal.lua:77`), which asks "is a display exported?" when most callers want "can a browser be reached?". `open_url` already carries a narrow WSL exemption for exactly this reason, and the macOS case that exposed the same flaw has been declined as out of scope.

  The flag itself is used at six other call sites, where "no display" means something different in each, so widening the definition is not a one-line change. The narrow exemptions are probably right, but the `console-detection` capability deserves a look eventually. Recorded here because the underlying confusion outlived the macOS bug that surfaced it.

- snippet placeholders cannot be navigated. `snippets` is an active completion source
  (`lua/plugins/blink.lua:26`), so snippet completions are offered and expand — but
  `snippet_forward` / `snippet_backward` are bound nowhere in the config, and the insert-mode
  keymap uses `preset = "none"`, so nothing supplies them by default either. Once a snippet is
  accepted there is no way to jump between its placeholders. A pre-existing gap rather than a
  regression; explicitly out of scope for the `fix-blink-completion-keymap` change, which only
  addresses the manual trigger and the cross-mode accept key.

- **eight real Lua diagnostics, six of them newly visible.** Surfaced on 2026-09-11 by `configure-lua-ls-workspace`, which gave `lua_ls` the workspace configuration it had never had. **Not introduced by that change** — it touched none of these files; they were simply invisible underneath 659 `Undefined global` reports. Recorded here rather than fixed there, because they are unrelated to each other and to the configuration that hid them.

  | File | Line | Finding |
  |---|---|---|
  | `lua/config/http_preview.lua` | 99, 103, 110, 115 | `Need check nil` ×4 |
  | `lua/config/http_preview.lua` | 115 | `Cannot assign (uv.uv_tcp_t)? to parameter uv.uv_stream_t` |
  | `lua/config/claude_cli.lua` | 61 | `Cannot assign (integer\|unknown)? to parameter integer` |
  | `lua/plugins/fzf-lua.lua` | 8 | `Undefined type or alias fzf-lua.Config` — **pre-existing**, visible before the fix |
  | `testdocs/hello.lua` | 13 | `Unused local x` — **pre-existing**, and only a fixture |

  The five `http_preview.lua` entries are worth taking first: four missing nil checks and an optional-type assignment, all in the same file, all in socket-handling code where a nil is precisely what you would expect to have to handle. That those two pre-existing entries were the *only* findings visible beforehand is the measure of what the noise was costing.

  **Do not let the count grow back.** `openspec/TEST_PLAN.md` § `Change · configure-lua-ls-workspace` records the expected total so a later reader has something to compare against.

