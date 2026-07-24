## Context

Treesitter in this config is pinned to `nvim-treesitter`'s `master` branch and configured with the master module API (`require("nvim-treesitter.configs").setup{ highlight, indent, textobjects, ensure_installed }`). `master` is frozen (backward-compat only; the maintainers direct all work to `main`, which will become the default branch). On Neovim 0.12 the frozen branch breaks:

- Text objects call `nvim-treesitter/tsrange.lua` → `:start()`, an API 0.12 removed, so `vaf`/`vif`/`daf`/`]f`/`[f` silently no-op (their `pcall` swallows the error).
- The master `opts` were being dropped entirely because lazy's default `opts` path calls a zero-arg `require("nvim-treesitter").setup()`; a `configs.setup(opts)` shim was needed to make highlight work.
- Markdown highlight had to be force-disabled to avoid a nil-range error.

Change 01 was re-scoped to highlight-only on `master` and the text objects were backed out. This change moves treesitter to the maintained `main` branch, which targets Neovim's built-in treesitter APIs, and restores text objects that work on 0.12.

## Goals / Non-Goals

**Goals:**
- Run `nvim-treesitter` + `nvim-treesitter-textobjects` on `main`.
- Preserve treesitter highlight for F#/C#/Haskell/Lua.
- Restore selection (`af`/`if`, `ac`/`ic`, `aa`/`ia`) and motion (`]f`/`[f`/`]F`/`[F`) text objects, gated off for Lisp.
- Remove `master`-specific workarounds where `main` makes them unnecessary.

**Non-Goals:**
- Changing Lisp structural editing (vim-sexp stays authoritative there).
- Changing code folding (nvim-ufo).
- Adding new languages or parsers beyond the current set.

## Decisions

- **Move to `main`, not stay on `master`.** `master` is frozen and already broken on 0.12; `main` is the maintained, core-API-aligned branch. Alternative (stay on `master`, keep text objects backed out) is a known dead end that diverges further with each Neovim release.
- **Highlight via a `FileType` autocmd calling `vim.treesitter.start()`.** `main` has no highlight module. Alternative considered: rely on Neovim core auto-start — rejected because core only auto-starts bundled parsers (lua/markdown), not F#/C#/Haskell. The autocmd targets the config's parser set and skips markdown if the nil-range issue persists.
- **Parser install via `main`'s mechanism.** `ensure_installed` is not a `setup` key on `main`; install the required parsers via `main`'s install list / `:TSInstall` (`commonlisp`, `clojure`, `scheme`, `lua`, `fsharp`, `c_sharp`, `vim`, `markdown`, `markdown_inline`, `http`, `haskell`). A C compiler remains required.
- **Text objects via `nvim-treesitter-textobjects` `main` + manual keymaps.** `main` exposes `require('nvim-treesitter-textobjects').setup{}` and a select/move API that queries Neovim core (works on 0.12). Keymaps are set in a `FileType`/ftplugin-scoped fashion and skipped for Lisp filetypes. Do NOT map `]c`/`[c` (diff-mode collision).
- **Re-evaluate the markdown disable.** On `main` the highlight path is plain `vim.treesitter.start()`; test whether markdown still triggers the nil-range error. Keep the `after/ftplugin/markdown.lua` `vim.treesitter.stop()` only if still needed.

## Risks / Trade-offs

- [`main` API churn — it is pre-1.0 and evolving] → Pin an exact commit in `lazy-lock.json`; validate on Neovim 0.12 before merge.
- [Manual highlight/textobject wiring is more code than the old module block] → Keep it small and centralized in `treesitter.lua`; document in `architecture.adoc`.
- [Parser install ergonomics differ on `main`] → Document the install step in the guide; a C compiler is still required (already noted in TEST_PLAN).
- [Text-object keymaps could collide with existing bracket maps] → Explicitly exclude `]c`/`[c`; assert gitsigns `]h`/`[h` and unimpaired `]b`/`[b` still work (covered by spec scenarios).
- [Regression risk vs current backed-out state] → This is additive/independent of the blink change; validate standalone on its own branch before merging.

## Migration Plan

1. On its own branch, repin both plugins to `main` in the spec and rewrite `lua/plugins/treesitter.lua`.
2. `:Lazy sync` + install parsers; verify highlight (`vim.treesitter.highlighter.active`) for lua/fsharp/c_sharp/haskell.
3. Verify text objects (`vaf`/`vif`/`via`/`daf`, `]f`/`[f`) in F#/C#/Haskell/Lua; verify vim-sexp unaffected in Lisp buffers.
4. Confirm markdown opens with no nil-range error; drop the disable/stop workaround if clean.
5. Update `lazy-lock.json` and docs; run `luac -p`.
6. Rollback = revert the branch (config is isolated to `treesitter.lua` + lock + docs).

## Open Questions

- Is the markdown nil-range `disable`/`vim.treesitter.stop()` workaround still required on `main`, or can it be removed?
- Should highlight be started for **all** installed parsers generically, or only an explicit allowlist of filetypes?
- Sequencing vs the numbered migration (03–08) and Change 01: this supersedes Change 01's text objects — confirm merge order relative to `main`.
