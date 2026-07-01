# Manual Validation Checklist

Steps that require a running Neovim session — cannot be automated by luac or grep.
Run them after `:Lazy sync` on the relevant branch before raising a PR.

---

## Change 01 · add-treesitter-textobjects

After `:Lazy sync` then `:TSUpdate`:

- [ ] **3.1** `:TSUpdate` completes; `haskell` parser listed as installed; no
  textobjects load errors in `:messages`.
- [ ] **3.2** Open Lua, F#, C#, and Haskell buffers: `:set ft?` correct;
  `:lua print(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()])` non-nil.
- [ ] **3.3** In an F#/Haskell/C#/Lua buffer: `vaf` selects outer function;
  `vif` selects body; `via` selects an argument; `daf` deletes function; `]f`/`[f` jump.
- [ ] **3.4** In `.clj`/`.lisp`/`.janet`: `vaf` selects s-expression (vim-sexp),
  NOT a treesitter function.
- [ ] **3.5** `]h`/`[h` (gitsigns hunks) and vim-unimpaired `]b`/`[b`/`yos` etc. still work.

---

## Change 02 · enhance-asciidoc-authoring

After `:Lazy sync`:

- [ ] **4.1** `:Lazy` shows vim-asciidoctor installed with no errors.
- [ ] **4.2** Open a `.adoc` cold: `:set ft?` → `asciidoctor`; sections fold
  (`za`); a `[source,lua]` block is highlighted as Lua.
- [ ] **4.3** `<localleader>p` / `<localleader>pp` → Docker HTML preview fires
  (or warns cleanly if Docker is not running). `<localleader>pa` → Antora build.
- [ ] **4.5** Open a `.md` file: markdown-preview / glow still work; markview is
  absent from `:Lazy` (deferred — needs `cathaysia/tree-sitter-asciidoc`).

---

## Change 03 · migrate-completion-blink

After `:Lazy sync`:

- [ ] **3.1** `:Lazy` shows blink.cmp installed; nvim-cmp, cmp-nvim-lsp,
  cmp-buffer, cmp-path, cmp-cmdline, cmp_luasnip absent.
- [ ] **3.2** LSP, buffer, and path completions appear in a Lua and an F# buffer.
- [ ] **3.3** `<C-n>`/`<C-p>` navigate; `<CR>` in insert mode with no item highlighted
  inserts a newline (no accidental first-item accept); `<C-e>` closes menu.
- [ ] **3.4** `:` cmdline: path and Ex command completions appear. `/` cmdline:
  buffer word completions appear.
- [ ] **3.5** Open `.clj` / `.lisp` / `.janet` with REPL connected; Conjure
  symbol completions appear in blink menu. If absent: add explicit
  `require("cmp_conjure")` load in the conjure ft event (see design.md).
- [ ] **3.6** In a markdown buffer, `:set spell`; type 3+ chars of misspelled
  word; spell suggestions appear in menu. In a Lua buffer with spell off: no
  spell suggestions.

---

## Change 04 · modernize-editing-plugins

After `:Lazy sync`:

- [ ] **4.1** `:Lazy` shows lualine.nvim and nvim-surround installed;
  vim-airline, vim-surround, vim-sensible, vim-commentary absent.
- [ ] **4.2** Status line renders: mode indicator, git branch + diff hunk counts,
  diagnostics count, filetype, cursor position.
- [ ] **4.3** Surround ops: `ysiw"` adds quotes around word; `cs"'` changes to
  single quotes; `ds"` removes; `.` repeats.
- [ ] **4.4** `gcc` toggles the current line comment; `gc` + motion toggles a
  range; both dot-repeatable.
- [ ] **4.5** vim-unimpaired: `yos` toggles spell; `]q`/`[q` walk quickfix; all
  still work and dot-repeat with vim-repeat.
- [ ] **4.6** No startup errors; no option regressions from removing vim-sensible.

---

## Change 05 · upgrade-avante-drop-dressing

After `:Lazy update` + build step:

- [ ] **4.1** `:Lazy` shows avante.nvim at the new version; build successful; no
  `release not found` error.
- [ ] **4.2** `<leader>aa` opens Avante; session responds.
- [ ] **4.3** `<leader>ao` switches to ollama and opens (clean error if service
  offline; no crash).
- [ ] **4.4** `<leader>ac` switches to Claude API (requires `ANTHROPIC_API_KEY`).
- [ ] **4.5** `:DiffviewOpen` still works (plenary intact).
- [ ] **4.6** Trigger a code action or `vim.ui.select` prompt; native fallback
  works (no crash) now that dressing is gone.

---

## Change 06 · add-diagnostics-todo-panel

After `:Lazy sync`:

- [ ] **4.1** `:Lazy` shows trouble.nvim and todo-comments.nvim installed cleanly.
- [ ] **4.2** In a file with LSP diagnostics: `<leader>xx` opens project panel;
  `<leader>xX` opens buffer view; selecting an entry jumps to it.
- [ ] **4.3** `[d`/`]d` (LSP) and `<leader>e` (float) still behave as before.
- [ ] **4.4** Add `-- TODO:` and `-- FIXME:` comments; confirm highlighting and
  sign-column markers appear.
- [ ] **4.5** `<leader>xT` lists todos via fzf-lua; `<leader>xt` lists in Trouble.
- [ ] **4.6** vim-unimpaired `]t`/`[t` still do tag navigation (not todo-comments).

---

## Change 07 · add-dotnet-debug-test

After `:Lazy sync`:

- [ ] **5.1** `:Lazy` shows nvim-dap, nvim-dap-ui, nvim-nio, easy-dotnet installed.
- [ ] **5.2** Open a `.cs` file; `:lua =vim.lsp.get_clients({ name = "roslyn" })`
  shows exactly one client (easy-dotnet did NOT start a second Roslyn server).
- [ ] **5.3** In a runnable .NET project: `<F9>` sets a breakpoint; `<F5>` starts;
  dap-ui opens; breakpoint is hit; `<F10>`/`<F11>`/`<F12>` step.
- [ ] **5.4** `<localleader>tt` runs tests; `<localleader>tr` runs the project —
  in both `.cs` and `.fsharp` buffers.
- [ ] **5.5** Open a Haskell project: `:lua =require("dap").configurations.haskell`
  non-nil (or haskell-tools registers a config); note result for follow-up.
- [ ] **5.6** iron REPL `<localleader>sl`/`sc` and LSP `gd`/`K`/`gr` still work.

---

## Change 08 · add-claudecode-session

After `:Lazy sync`:

- [ ] **3.1** `:Lazy` shows claudecode.nvim installed; snacks.nvim is NOT pulled
  in (confirm absent from `:Lazy` list).
- [ ] **3.2** `<leader>gcc` opens a native terminal running `claude`; the CLI
  connects to the MCP server (run `/ide` in the Claude session if needed).
- [ ] **3.3** Visually select lines; `<leader>gcv` sends selection to session;
  `<leader>gcb` adds current file.
- [ ] **3.4** Ask Claude to edit a file; `<leader>gca` accepts the diff;
  `<leader>gcr` rejects it.
- [ ] **3.5** `<leader>gcs` / `<leader>gce` (claude_cli one-shot) still work.
- [ ] **3.6** `<leader>aa` / `<leader>ao` / `<leader>ac` (avante) unaffected.
