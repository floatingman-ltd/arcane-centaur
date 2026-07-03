# Manual Validation Checklist

Steps that require a running Neovim session — cannot be automated by luac or grep.
Run them in order after `:Lazy sync` on the relevant branch before raising a PR.

---

## Change 01 · add-treesitter-textobjects

**Setup:** checkout `feat/01-add-treesitter-textobjects`, launch Neovim.

### 3.1 — Parser install

1. Run `:Lazy sync` and wait for it to complete.
2. Run `:TSUpdate` and wait.
3. Run `:TSInstallInfo`. Scroll to confirm the following parsers show `installed`: `lua`, `fsharp`, `c_sharp`.
   - `haskell` is also in `ensure_installed` but is optional here — skip it if this is not a Haskell development machine (it is validated in Change 07 § 5.5 if needed).
4. Run `:messages` and scan for any `textobjects` or `treesitter` errors. There should be none.
- [ ] `lua`, `fsharp`, and `c_sharp` parsers installed; no treesitter errors in `:messages`.

### 3.2 — Highlight active per filetype

1. Open `lua/plugins/treesitter.lua`. Run `:set ft?` — should print `filetype=lua`.
2. Run `:lua print(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()])` — should print a table (not `nil`).
3. Open an `.fs` or `.fsx` file. Repeat the `:set ft?` check (expect `fsharp`) and the highlighter check.
4. Open a `.cs` file. Repeat both checks (`c_sharp` highlight active).
5. _(Optional — skip if not a Haskell machine)_ Open a `.hs` file. Repeat both checks (`haskell` highlight active).
- [ ] `lua`, `fsharp`, and `c_sharp` files show correct filetype and non-nil highlighter. Haskell optional.

### 3.3 — Textobject motions (non-Lisp buffer)

1. Open `lua/plugins/treesitter.lua` and position the cursor inside a function body.
2. Press `vaf` in normal mode — the entire function including its signature should be selected.
3. Press `vif` — only the body (between `function`/`end` or equivalent) should be selected.
4. Move to a function parameter and press `via` — the argument should be selected.
5. Position on a function and press `daf` — the whole function should be deleted.
6. Undo (`u`). Press `]f` — cursor should jump to the start of the next function. Press `[f` — cursor should jump back.
- [ ] All six sub-steps behave as described.

### 3.4 — Textobjects disabled in Lisp buffers

1. Open a `.clj` (Clojure) file that contains a defn form.
2. Position cursor inside the form and press `vaf`.
3. Confirm the selection is driven by vim-sexp (selects the s-expression) NOT by treesitter (which would select a "function"). The selection boundary should follow parentheses, not an indented block.
4. Repeat with a `.lisp` and a `.janet` file.
- [ ] vim-sexp behaviour unchanged in all three Lisp filetypes.

### 3.5 — Unrelated bracket maps intact

1. In a git repo, open any file with a staged/unstaged hunk. Press `]h` — cursor should jump to the next hunk. Press `[h` — back to previous.
2. Press `]b` and `[b` (vim-unimpaired buffer nav) — should cycle buffers.
3. Press `yos` — spell toggle should flip on/off (check `:set spell?` before and after).
- [ ] All three map groups still work.

---

## Change 02 · enhance-asciidoc-authoring

**Setup:** checkout `feat/02-enhance-asciidoc-authoring`, launch Neovim.

### 4.1 — Plugin installed

1. Run `:Lazy sync`.
2. Open `:Lazy` (press `<CR>` on the lazy.nvim line or run `:Lazy`). Search for `vim-asciidoctor`.
3. Confirm it shows as installed with no error icon.
- [ ] vim-asciidoctor listed as installed, no errors.

### 4.2 — Filetype detection, folding, syntax

1. Open `docs/modules/ROOT/pages/editor/code-intelligence.adoc` cold (e.g. `nvim docs/modules/ROOT/pages/editor/code-intelligence.adoc`).
2. Run `:set ft?` — should print `filetype=asciidoctor`.
3. Move to a section heading line (starts with `==`). Press `za` — the section should fold. Press `za` again — it should unfold.
4. Find a `[source,lua]` fenced block and check that the Lua inside is highlighted in a different colour from the surrounding AsciiDoc text.
- [ ] Filetype correct, fold works, fenced-block highlight active.

### 4.3 — Docker preview maps

1. While still in the `.adoc` buffer, press `,p` (`<localleader>p`).
2. Expected outcomes (either is a pass):
   - If Docker is running: a browser tab or terminal output showing the rendered HTML.
   - If Docker is NOT running: a clean warning/error message — no Neovim crash or traceback.
3. Press `,pp` and confirm it triggers the same preview flow.
4. Press `,pa` — expect the Antora build to start (or a clean Docker-offline message).
- [ ] All three maps fire without crashing Neovim.

### 4.5 — Markdown unaffected; markview absent

1. Open `readme.md`. Confirm markdown preview (or glow) still works as before.
2. Run `:Lazy` and search for `markview` — it should NOT appear (deferred: requires `cathaysia/tree-sitter-asciidoc` which is not in nvim-treesitter master).
- [ ] Markdown tooling intact; markview absent from plugin list.

---

## Change 03 · migrate-completion-blink

**Setup:** checkout `feat/03-migrate-completion-blink`, launch Neovim.

### 3.1 — blink installed; nvim-cmp gone

1. Run `:Lazy sync`.
2. Open `:Lazy`. Search for `blink.cmp` — confirm installed.
3. Search in turn for `nvim-cmp`, `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp-cmdline`, `cmp_luasnip` — none should appear.
- [ ] blink.cmp present; all six cmp plugins absent.

### 3.2 — LSP, buffer, and path completions

1. Open `lua/plugins/blink.lua`. Enter insert mode, type `req` — LSP completions for `require` should appear in a popup.
2. Type a partial word that exists elsewhere in the file (e.g. the first few letters of `blink`) — buffer-word completion should appear.
3. Type `./` or `~/` — path completions should appear.
4. Open an `.fs` file with fsautocomplete running. Type `List.` — LSP completions for the `List` module should appear.
- [ ] All three completion sources work in both Lua and F# buffers.

### 3.3 — Keymap behaviour

1. In insert mode with the completion menu open, press `<C-n>` — selection should move down. Press `<C-p>` — selection should move up.
2. Close the menu with `<C-e>`. Confirm the menu dismisses.
3. Press `<CR>` in insert mode with the menu closed (no item highlighted) — should insert a newline, not trigger completion.
4. Open the menu, highlight an item, press `<CR>` — item should be inserted.
- [ ] Navigation, dismiss, and no-preselect newline all behave correctly.

### 3.4 — Command-line completion

1. Press `:` to enter command mode. Type a partial path like `lua/` — file path completions should appear.
2. Type a partial Ex command like `Laz` — `Lazy` and related commands should appear.
3. Press `/` to enter search mode. Type a partial word from the current buffer — buffer-word completions should appear.
- [ ] Both `:` and `/` cmdline sources work.

### 3.5 — Conjure completions (Lisp)

1. Open a `.clj` file and connect Conjure to a running nREPL (or start one with `jack-in`).
2. Enter insert mode and type the first few characters of a var defined in the REPL — Conjure completions should appear in the blink menu.
3. If they do NOT appear: check `:messages` for blink.compat errors and note for follow-up (see `design.md` task 3.5 fallback).
- [ ] Conjure completions appear (or absence is noted for follow-up).

### 3.6 — Spell completions gated by `spell` option

1. Open a markdown file. Run `:set spell`. Type 3+ characters of a misspelled word — spell suggestions should appear in the menu.
2. Open a Lua file where `:set spell?` is `nospell`. Type the same misspelled word — no spell suggestions should appear.
- [ ] Spell completions gated correctly by the `spell` option.

---

## Change 04 · modernize-editing-plugins

**Setup:** checkout `feat/04-modernize-editing-plugins`, launch Neovim.

### 4.1 — Plugin inventory

1. Run `:Lazy sync`.
2. Open `:Lazy`. Confirm `lualine.nvim` and `nvim-surround` are listed as installed.
3. Search for `vim-airline` — should be absent.
4. Search for `vim-surround` — should be absent (nvim-surround replaced it).
5. Search for `vim-sensible` — should be absent.
6. Search for `vim-commentary` — should be absent (native `gc` replaced it).
- [ ] Both new plugins present; all four removed plugins absent.

### 4.2 — Status line

1. Open any file. Look at the bottom of the screen.
2. Confirm the left section shows the current mode (e.g. `NORMAL`).
3. In a git repo, confirm the branch name and diff counts (+/-) appear in the status line.
4. Introduce a diagnostic error (e.g. add a syntax error to a Lua file) and confirm the diagnostic count updates in the status line.
5. Confirm the right section shows the filetype, scroll percentage, and cursor line:column.
- [ ] All five status line elements render correctly.

### 4.3 — Surround operations

1. Open any file. Position the cursor on a word. In normal mode, type `ysiw"` — the word should be wrapped in double quotes.
2. With the cursor on the `"`, type `cs"'` — double quotes should change to single quotes.
3. With the cursor on the `'`, type `ds'` — the single quotes should be removed.
4. Undo all three changes. Re-run `ysiw"`. Then press `.` — the surround operation should repeat.
- [ ] Add, change, delete, and dot-repeat all work.

### 4.4 — Comment operator

1. Open `lua/plugins/treesitter.lua`. Position on any line. Press `gcc` — the line should be commented (prefixed with `--`). Press `gcc` again — it should be uncommented.
2. Select three lines in visual mode. Press `gc` — all three should be commented. Press `gc` again — uncommented.
3. Undo to restore. Run `gcc` on a line, then move to a different line and press `.` — the comment toggle should repeat.
- [ ] Toggle, visual range, and dot-repeat all work.

### 4.5 — vim-unimpaired + vim-repeat intact

1. Press `yos` — spell should toggle. Check `:set spell?` before and after.
2. Open the quickfix list with `:copen` (or any command that populates it). Press `]q` to move to the next entry, `[q` to go back.
3. Press `]b` and `[b` to cycle through open buffers.
- [ ] All three vim-unimpaired map groups work correctly.

### 4.6 — Clean startup

1. Restart Neovim. Run `:messages` — no errors or warnings about missing plugins or removed options.
2. Check that indentation, `'backspace'`, `'incsearch'` and other settings that vim-sensible used to set are still sensible defaults (they should be — Neovim ships these as defaults).
- [ ] No startup errors; expected defaults present.

---

## Change 05 · upgrade-avante-drop-dressing

**Setup:** checkout `feat/05-upgrade-avante-drop-dressing`, launch Neovim.

### 4.1 — Avante at new version; build succeeded

1. Run `:Lazy sync`, then `:Lazy update avante.nvim`. Wait for the update to complete.
2. If the build step (`make`) did not run automatically, run `:AvanteBuild` and wait.
3. Open `:Lazy`. Find `avante.nvim` — confirm the version shown starts with `v0.1.` and there is no `release not found` or build error.
- [ ] Version is v0.1.x, build clean.

### 4.2 — Avante opens with current provider

1. Press `<leader>aa`. The Avante panel should open on the right.
2. Type a short prompt and press `<CR>`. Confirm a response is received (requires the active provider to be reachable).
- [ ] Avante opens and responds.

### 4.3 — Ollama provider switch

1. Press `<leader>ao`. Avante should switch to the Ollama provider and open.
2. If Ollama is not running: expect a clean connection-refused error message — no Neovim crash or traceback.
- [ ] Ollama switch fires cleanly (response or clean error).

### 4.4 — Claude API provider switch

1. Ensure `ANTHROPIC_API_KEY` is set in the environment.
2. Press `<leader>ac`. Avante should switch to the Claude API provider and open.
3. Type a short prompt and confirm a response arrives.
- [ ] Claude API provider works (skip if no API key available; note).

### 4.5 — Diffview still works (plenary intact)

1. In a git repo with uncommitted changes, run `:DiffviewOpen`.
2. The side-by-side diff view should open without errors.
3. Close it with `:DiffviewClose`.
- [ ] DiffviewOpen and DiffviewClose work.

### 4.6 — Native vim.ui fallback (dressing gone)

1. Run a command that triggers `vim.ui.select`, e.g. `<leader>ca` (code action) on a line with an available LSP code action.
2. A native select prompt should appear (Neovim's built-in, not dressing's custom UI). Select an option.
3. Confirm no error about missing `dressing.nvim`.
- [ ] vim.ui.select works via native fallback; no dressing errors.

---

## Change 06 · add-diagnostics-todo-panel

**Setup:** checkout `feat/06-add-diagnostics-todo-panel`, launch Neovim.

### 4.1 — Plugins installed

1. Run `:Lazy sync`.
2. Open `:Lazy`. Search for `trouble.nvim` — confirm installed.
3. Search for `todo-comments.nvim` — confirm installed.
- [ ] Both plugins listed as installed with no errors.

### 4.2 — Trouble diagnostic panels

1. Open `lua/plugins/trouble.lua` (or any file where the Lua LSP is active and may report issues).
2. Press `<leader>xx`. The Trouble project diagnostics panel should open at the bottom showing all diagnostics across the project.
3. Move the cursor to an entry in the panel and press `<CR>` — Neovim should jump to that file and line.
4. Press `<leader>xX`. The panel should filter to show only diagnostics for the current buffer.
5. Press `<leader>xx` again to close the panel.
- [ ] Project panel opens, entry navigation works, buffer filter works.

### 4.3 — Native diagnostic maps unchanged

1. In a file with an LSP error, press `]d` — cursor should jump to the next diagnostic. Press `[d` — back to previous.
2. Position cursor on a diagnostic. Press `<leader>e` — a floating window with the diagnostic text should appear.
3. Confirm these behave identically to how they did before change 06 (Trouble is additive, not a replacement).
- [ ] `[d`, `]d`, and `<leader>e` all behave as before.

### 4.4 — TODO/FIXME highlighting

1. Open `lua/plugins/treesitter.lua`. Add a line `-- TODO: test this`.
2. Confirm the `TODO:` text is highlighted with a distinct colour and a sign appears in the sign column.
3. Change `TODO` to `FIXME` — confirm `FIXME` is highlighted in a different colour.
4. Undo both additions when done.
- [ ] TODO and FIXME annotations highlighted with distinct colours and signs.

### 4.5 — Todo list views

1. With the `-- TODO:` line still present, press `<leader>xT`. An fzf-lua picker should open listing all todo comments in the project.
2. Press `<Esc>` to close the picker.
3. Press `<leader>xt`. The Trouble panel should open showing todo comments. Confirm the entry from step 1 appears.
- [ ] fzf-lua picker and Trouble panel both list todo comments.

### 4.6 — vim-unimpaired tag maps intact

1. Ensure there is a `tags` file in the project (or run `ctags -R` to generate one).
2. Press `]t` — cursor should jump to the next tag. Press `[t` — back to previous.
3. Confirm these are NOT remapped to todo-comment navigation (that would be `<leader>xt` / `<leader>xT`).
- [ ] `]t` / `[t` do tag navigation, not todo navigation.

---

## Change 07 · add-dotnet-debug-test

**Setup:** checkout `feat/07-add-dotnet-debug-test`, launch Neovim. Requires a .NET solution on disk and `netcoredbg` on `$PATH` (install from GitHub releases — see `openspec/TEST_PLAN.md` § One-Time Test Machine Setup).

### 5.1 — Plugins installed

1. Run `:Lazy sync`.
2. Open `:Lazy`. Confirm `nvim-dap`, `nvim-dap-ui`, `nvim-nio`, and `easy-dotnet.nvim` are all listed as installed with no errors.
- [ ] All four plugins installed cleanly.

### 5.2 — Exactly one Roslyn LSP client

1. Open a `.cs` file from a .NET solution (roslyn.nvim should attach).
2. Wait a few seconds for the LSP to start, then run:
   `:lua =vim.lsp.get_clients({ name = "roslyn" })`
3. The output should show exactly one table entry. If two entries appear, easy-dotnet has started a second Roslyn server (configuration error).
- [ ] Exactly one Roslyn client returned.

### 5.3 — Breakpoint and step debugging

1. Open a `.cs` file in a runnable .NET project (one with a `Program.cs` or test entry point).
2. Move the cursor to a line inside a method body (e.g. a `Console.WriteLine`). Press `<F9>` — a red dot (breakpoint sign) should appear in the sign column.
3. Press `<F5>`. easy-dotnet's project picker should appear — select the runnable project.
4. Confirm the `nvim-dap-ui` panel opens automatically (side panes for variables, stack, etc.).
5. Execution should pause at the breakpoint. Confirm the current line is highlighted.
6. Press `<F10>` — step over to the next line. Press `<F11>` — step into a called function. Press `<F12>` — step out. Confirm the cursor follows.
7. Press `<S-F5>` — the debug session should terminate and the dap-ui should close.
- [ ] Full debug cycle (set breakpoint → start → pause → step → stop) works.

### 5.4 — easy-dotnet test and run maps

1. Open a `.cs` file. Press `<localleader>tt` (`,tt`) — easy-dotnet's test runner should open and run the tests for the selected project, showing pass/fail output.
2. Press `<localleader>tr` (`,tr`) — easy-dotnet should run the project (picker appears if multiple runnable projects exist).
3. Open an `.fsx` or `.fs` file. Repeat both `<localleader>tt` and `<localleader>tr` — confirm the maps are active in F# buffers too.
- [ ] Test and run maps work in both C# and F# buffers.

### 5.5 — Haskell DAP config discovery

1. Open a `.hs` file from a Haskell project that uses haskell-tools.nvim.
2. Run `:lua =require("dap").configurations.haskell`.
3. Note the result: if a table with at least one entry is returned, haskell-tools has auto-registered a configuration. If `nil`, no config was registered — note this for a potential follow-up.
- [ ] Result noted (pass = non-nil table; nil = follow-up required, not a blocking failure).

### 5.6 — Existing .NET maps unaffected

1. Open a `.cs` file. Connect the iron.nvim REPL with `<localleader>si` (or open csharprepl). Press `<localleader>sl` on a line — confirm the line is sent to the REPL.
2. Confirm `gd` (go to definition), `K` (hover), and `gr` (find references) all work via the Roslyn LSP.
- [ ] iron REPL and LSP navigation intact.

---

## Change 08 · add-claudecode-session

**Setup:** checkout `feat/08-add-claudecode-session`, launch Neovim. Requires the `claude` CLI on `$PATH` and an active Claude Code authentication.

### 3.1 — Plugin installed; snacks absent

1. Run `:Lazy sync`.
2. Open `:Lazy`. Search for `claudecode.nvim` — confirm installed.
3. Search for `snacks.nvim` — it should NOT appear (claudecode uses the native terminal provider; snacks was not declared as a dependency).
- [ ] claudecode.nvim installed; snacks.nvim absent.

### 3.2 — Session terminal opens and connects

1. Press `<leader>gcc`. A native terminal split should open running the `claude` CLI.
2. In the terminal, wait for the Claude Code prompt to appear.
3. If the MCP server does not connect automatically, type `/ide` in the Claude session and press Enter.
4. Confirm no errors about missing providers or snacks.
- [ ] Native terminal opens, `claude` CLI runs, MCP connects.

### 3.3 — Send selection and add buffer

1. Return to the editor (press `<C-\><C-n>` if in terminal mode, then move to an editor window).
2. Open `lua/plugins/claudecode.lua`. In visual mode (`V`), select two or three lines.
3. Press `<leader>gcv` — the selected lines should appear in the Claude session terminal.
4. Press `<leader>gcb` — the current buffer's file path should be added to Claude's context (confirm in the Claude session output).
- [ ] Selection send and buffer add both reach the session.

### 3.4 — Diff accept and reject

1. In the Claude session, ask Claude to make a small edit to a file (e.g. "add a comment to the first line of `lua/plugins/claudecode.lua`").
2. Claude should propose a diff and Neovim should open a diff view.
3. Press `<leader>gca` — the change should be accepted and written to the file.
4. Undo (`u`) to restore. Ask Claude for another small edit. This time press `<leader>gcr` — the diff should be rejected and the file left unchanged.
- [ ] Accept diff and reject diff both work correctly.

### 3.5 — One-shot claude_cli maps still work

1. Open any file. In normal mode, press `<leader>gcs` — a floating window should appear with a shell command suggestion from Claude.
2. In visual mode, select a function. Press `<leader>gce` — a floating window should appear with a code explanation.
3. Press `q` or `<Esc>` to close each window.
- [ ] `<leader>gcs` and `<leader>gce` (claude_cli) still work alongside the session.

### 3.6 — Avante maps unaffected

1. Press `<leader>aa` — Avante should open as normal.
2. Press `<leader>ao` — Avante should switch to the Ollama provider (or give a clean error if offline).
3. Press `<leader>ac` — Avante should switch to the Claude API provider.
4. Confirm none of the `<leader>gc*` claudecode maps bleed into the `<leader>a*` Avante namespace.
- [ ] All three Avante maps unaffected; no namespace collision.
