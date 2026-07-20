## Why

`lua/plugins/treesitter.lua` enables `highlight` and `indent` but has no textobjects module. Lisp-family editing is well-served by vim-sexp (structural s-expression navigation), but **F#, Haskell, C#, and Lua have no structural text objects** beyond vanilla motions. `nvim-treesitter/nvim-treesitter-textobjects` adds semantic objects (`af`/`if` function, `ac`/`ic` class, `aa`/`ia` argument) and structural motion (`]f`/`[f` between functions) — a near-zero-cost complement to the existing treesitter setup.

Cross-validation of the *actual* config surfaced three facts that materially change the plan the evaluation assumed:

1. **nvim-treesitter is pinned to the `main` branch**, but `treesitter.lua` is written in the `master`-style opts API (`ensure_installed` / `highlight = { enable }` / `indent = { enable }`). On `main` those keys are ignored — so the config is in an inconsistent state, and **the textobjects API is branch-coupled**: the legacy `require("nvim-treesitter.configs").setup({ textobjects = ... })` module only exists on `master`. This change must pick a branch and make the setup self-consistent.
2. **The evaluation was wrong about `fsharp`.** `ensure_installed` *already* lists `fsharp` (and `c_sharp`). Only **`haskell`** is actually missing.
3. **vim-sexp owns `af`/`if`.** `guns/vim-sexp` (via vim-sexp-mappings-for-regular-people) provides `af`/`if` "form" text objects in lisp/clojure/scheme/janet. textobjects' `af`/`if` would shadow them there, so textobjects MUST be gated to the non-Lisp filetypes.

## What Changes

- **Pin nvim-treesitter to the `master` branch** (`branch = "master"`) so the existing `opts`-style config (`ensure_installed`/`highlight`/`indent`) is the API that actually runs — making the config self-consistent and the legacy textobjects module available with the smallest, lowest-risk diff.
- **Add** `nvim-treesitter/nvim-treesitter-textobjects` (pinned to `master`) as a dependency, configured through the same `require("nvim-treesitter.configs").setup` call.
- **Add `haskell`** to `ensure_installed` (fsharp / c_sharp already present).
- **Configure select + move text objects** (`af`/`if`, `ac`/`ic`, `aa`/`ia`; `]f`/`[f`, `]F`/`[F`), **gated** to fsharp/haskell/cs/lua and **disabled** for lisp/clojure/scheme/fennel/janet so vim-sexp keeps `af`/`if` there.
- **Use only collision-free motion keys** — `]f`/`[f`/`]F`/`[F` are unused by vim-unimpaired; class motion (`]c`/`[c`) is intentionally *not* mapped (it shadows Vim's diff-mode change navigation).

## Capabilities

### New Capabilities

- `treesitter-textobjects`: Treesitter-based select and move text objects (function/class/argument) for F#, Haskell, C#, and Lua, on a branch-consistent nvim-treesitter setup, gated so vim-sexp retains structural editing in Lisp-family buffers.

### Modified Capabilities

<!-- the existing treesitter setup is not captured as an OpenSpec requirement; this change makes its branch/API self-consistent and adds the textobjects module -->

## Impact

- **`lua/plugins/treesitter.lua`** → modified: add `branch = "master"`, add the textobjects dependency (also `master`-pinned), add `haskell` to `ensure_installed`, add the `textobjects` opts block with per-filetype gating.
- **`lazy-lock.json`** → re-pins nvim-treesitter (and adds nvim-treesitter-textobjects) on `master` after `:Lazy sync` / `:TSUpdate`.
- **vim-sexp** → unaffected; `af`/`if`/`aF`/`iF` remain its form objects in Lisp-family buffers (textobjects disabled there).
- **Highlighting**: pinning to `master` makes `highlight = { enable = true }` actually take effect (it was a no-op on `main`) — a likely *improvement* over the current state. Verify highlight before/after.
- **No keymap changes** in `lua/keymaps.lua`; select objects are operator/visual-mode (`daf`, `vif`), move objects use free `]f`/`[f`/`]F`/`[F`.
- **Independence**: this is the only one of the five changes that touches `treesitter.lua`; none of the three best-of-breed changes touch it — no contention.

## Prerequisites and sequencing

**Sequence position:** 01 of 08 — Wave A (independent).

- **Hard prerequisites:** none. Sole editor of `lua/plugins/treesitter.lua`; no other change touches it.
- **Implementation wave: A** (independent; parallelizable). Note this change re-pins `nvim-treesitter` to `branch = "master"` — a global treesitter behavior change (highlighting starts actually running, where it was a no-op on `main`). If implemented in the same session as other changes, run `:TSUpdate` after the branch flip before validating the others' highlighting.

## Out of scope

- Migrating nvim-treesitter to the `main` branch API (per-buffer `vim.treesitter.start`, the new install + textobjects APIs) — a deliberate larger change deferred to its own proposal; this change deliberately consolidates on `master`.
- Swap text objects (`@parameter` swap) and additional parsers beyond `haskell`.
- Class motion maps (`]c`/`[c`) — withheld to avoid shadowing diff-mode change navigation.
- textobjects for Lisp-family filetypes — vim-sexp owns that.
