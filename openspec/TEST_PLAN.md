# Test & Validation Plan

Single source of truth for change validation. Each section covers one change:
prepare the branch → validate → raise PR → merge → confirm post-merge.

**Workflow:** validate on the feature branch **before** raising a PR. Never merge first and test after.

**Step numbering:** validation steps are prefixed with their change number — Change 01 steps are `1.x`, Change 02 are `2.x`, … Change 08 are `8.x`. (Changes 01–03 are all validated under the Change 03 section, since that branch inherits them.)

Sample files for filetype and highlight tests are in `testdocs/` (`hello.hs`, `hello.cs`, `hello.fs`, `hello.fsx`; an existing richer `hello.lua` is also there).

---

## One-Time Test Machine Setup

Complete once before any testing begins.

- [X] Confirm Neovim ≥ 0.12 is installed: `nvim --version`
- [X] Confirm Git is installed: `git --version`
- [X] Confirm Node.js + npm are installed (required by markdown-preview.nvim build): `node --version && npm --version`
- [X] Confirm `dotnet` SDK is installed (required for Change 07 testing): `dotnet --version`
- [X] Install netcoredbg (required for Change 07 debugging tests) — **not** a NuGet tool; install from GitHub releases:
  ```bash
  NCDBG_VER=$(curl -s https://api.github.com/repos/Samsung/netcoredbg/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)
  curl -L "https://github.com/Samsung/netcoredbg/releases/download/${NCDBG_VER}/netcoredbg-linux-amd64.tar.gz" \
    -o /tmp/netcoredbg.tar.gz
  mkdir -p ~/.local/share/netcoredbg
  tar -xzf /tmp/netcoredbg.tar.gz -C ~/.local/share/netcoredbg/
  # Add to ~/.zshrc or ~/.bashrc then source it:
  export PATH=$PATH:$HOME/.local/share/netcoredbg
  ```
- [X] Verify netcoredbg is on PATH: `netcoredbg --version`
- [X] Install the Roslyn C# language server (required by `roslyn.nvim` for the C# LSP in Changes 03 & 07) — **not** a `dotnet tool`; download the native binary. Full steps in `docs/modules/ROOT/pages/languages/dotnet.adoc` § *Installing the Roslyn Language Server*:
  ```bash
  # The Roslyn LSP is NOT on nuget.org — it lives on Microsoft's Azure DevOps
  # "vs-impl" feed, and all releases are prereleases (no stable 5.x; newest is
  # 5.4.0-2.26179.14 as of this writing — there is no 5.5/5.6).
  PKG=microsoft.codeanalysis.languageserver.linux-x64
  FEED="https://pkgs.dev.azure.com/azure-public/vside/_packaging/vs-impl/nuget/v3/flat2/${PKG}"
  VERSION=$(curl -s "${FEED}/index.json" | tr ',' '\n' | grep -oE '[0-9][0-9.]+-[0-9.]+' | sort -V | tail -1)
  echo "Installing Roslyn LSP ${VERSION}"
  mkdir -p ~/.local/share/roslyn
  curl -L "${FEED}/${VERSION}/${PKG}.${VERSION}.nupkg" -o /tmp/roslyn.nupkg
  unzip -o /tmp/roslyn.nupkg -d ~/.local/share/roslyn
  chmod +x ~/.local/share/roslyn/content/LanguageServer/linux-x64/Microsoft.CodeAnalysis.LanguageServer
  # Add to ~/.zshrc or ~/.bashrc then source it:
  export PATH="$HOME/.local/share/roslyn/content/LanguageServer/linux-x64:$PATH"
  ```
- [X] Verify the Roslyn server is on PATH: `Microsoft.CodeAnalysis.LanguageServer --version`
- [X] Confirm a C compiler is available (nvim-treesitter compiles `fsharp`/`c_sharp` parsers from source): `cc --version` (install `build-essential` on Debian/Ubuntu if missing)
- [ ] Install **lua-language-server** (Lua LSP completions, Change 03 §3.2) — not in apt/snap on Ubuntu 24.04; download from https://github.com/LuaLS/lua-language-server/releases, extract, and put `bin/lua-language-server` on PATH. Verify: `lua-language-server --version`
- [ ] Install **fsautocomplete** (F# LSP completions, Change 03 §3.2): `dotnet tool install -g fsautocomplete` (needs the dotnet SDK above; ensure `~/.dotnet/tools` is on PATH). Verify: `fsautocomplete --version`
- [X] Confirm `claude` CLI is installed and authenticated (required for Change 08): `claude --version`
- [X] Clone the repo: `git clone git@github.com:floatingman-ltd/arcane-centaur.git ~/.config/nvim`
- [X] Confirm initial main state loads: `nvim` → `:Lazy sync` → no errors in `:messages`

### Troubleshooting — `:Lazy sync` fails on `bracey.vim` / `markdown-preview.nvim` (dirty tree)

The build fix (`--no-package-lock`, on `main` and this branch) stops bracey.vim's
`npm install` from rewriting its tracked `server/package-lock.json` **going forward**.
On a machine that already ran the old build, the plugin's git tree is already dirty,
so `:Lazy sync`/`:Lazy update` keeps failing with local-changes errors until you
reset it **once**:

```bash
# Discard the dirtied lockfile in the installed plugin, then re-sync in Neovim
git -C ~/.local/share/nvim/lazy/bracey.vim checkout -- .
# then in Neovim: :Lazy sync
```

Alternatively, in Neovim: `:Lazy clean` then `:Lazy sync` (removes and reinstalls
the plugin cleanly). After this one-time reset the `--no-package-lock` build keeps
the tree clean on every future sync.

**`markdown-preview.nvim`** has the same failure: its old `cd app && npm install` build
left `app/package-lock.json` (untracked) and modified `app/yarn.lock`. The build now uses
the plugin's own installer (`mkdp#util#install` — downloads a prebuilt binary) which doesn't
touch the tree. On a machine already dirtied by the old build, reset it once:

```bash
git -C ~/.local/share/nvim/lazy/markdown-preview.nvim checkout -- .
git -C ~/.local/share/nvim/lazy/markdown-preview.nvim clean -fd app/
# then in Neovim: :Lazy sync   (or :Lazy clean && :Lazy sync)
```

---

## Per-Branch Sync & Sanity Check

_Run this on the test machine before validating each change (Change 03 onward)._

### Update the branch — reset, don't pull, after a force-push

Feature branches here are sometimes **rebased and force-pushed** (e.g. to stay current
with `main`). That rewrites the branch's history, so a plain `git pull` on the test
machine will **diverge or fail**. **Reset to the remote instead of pulling:**

```bash
git fetch origin
git checkout <branch>                 # e.g. feat/03-migrate-completion-blink
git reset --hard origin/<branch>      # discards local branch state — `git stash` first if you need it
```

### Confirm the machine is in the expected state

- [ ] **On the expected branch, in sync** — `git status -sb` first line shows `## <branch>...origin/<branch>` with **no** `[ahead N]` / `[behind N]`
- [ ] **Clean working tree** — the same `git status -sb` lists no modified/untracked files (no stray edits, no dirty plugin lockfile)
- [ ] **Right commit** — `git log -1 --oneline` matches the latest commit shown on the branch's GitHub page
- [ ] **Plugins synced** — launch Neovim, `:Lazy sync` completes with no errors; `:Lazy` shows no error icons or pending updates
- [ ] **Clean startup** — `:messages` shows no plugin / treesitter / LSP load errors

---

## Hotfix · treesitter-markdown-highlight-disable ✓

Merged as PR #134. No further action needed.

- [X] `after/ftplugin/markdown.lua` calls `vim.treesitter.stop()` on buffer open
- [X] `lua/plugins/treesitter.lua` disables TS highlight and indent for `markdown`/`markdown_inline`
- [X] Opening a `.md` file produces no `nil range` / `languagetree` error in `:messages`

---

## Change 03 · migrate-completion-blink

**Branch:** `feat/03-migrate-completion-blink`

This branch includes Changes 01 (treesitter highlight — text objects backed out) and 02 (asciidoc authoring) — both were merged
to main before this branch was created and are inherited here. Validate all three on this branch
before raising the PR.

### Prepare

> Run the **Per-Branch Sync & Sanity Check** above first. This branch has been
> **rebased/force-pushed** — on a machine that already had it, `git reset --hard
> origin/feat/03-migrate-completion-blink` (do **not** `git pull`).

1. `git fetch origin && git checkout feat/03-migrate-completion-blink`
2. Launch Neovim: `:Lazy sync` — wait for completion
3. `:TSUpdate` — wait for completion

- [X] Branch checked out, `:Lazy sync` and `:TSUpdate` complete with no errors

---

### Validate — Change 01: treesitter highlight  _(text objects backed out — see 1.3)_

#### 1.1 — Parser install

1. Run `:TSInstallInfo`. Confirm the following parsers show `installed`: `lua`, `fsharp`, `c_sharp`.
   - **`lua` is bundled with Neovim** (`$VIMRUNTIME/parser/lua.so`) — it always shows installed and highlights even with zero nvim-treesitter parsers, so it is **not** proof the plugin compiled anything. `fsharp` and `c_sharp` are the meaningful checks.
   - `haskell` is in `ensure_installed` but optional — skip if not a Haskell dev machine.
   - Compiling `fsharp`/`c_sharp` requires a **C compiler on PATH** (`cc`/`gcc`; `build-essential` on Debian/Ubuntu). Without it the install fails silently and 1.2 will show a `nil` highlighter.
   - If `fsharp` or `c_sharp` show **not installed** after `:TSUpdate`:
     a. Run `:TSInstall fsharp c_sharp` explicitly and wait.
     b. Run `:messages` — look for any compile or download error.
     c. Re-run `:TSInstallInfo` to check status again.
2. Run `:messages` — scan for any `treesitter` errors. There should be none.

- [X] `lua`, `fsharp`, and `c_sharp` parsers installed; no treesitter errors in `:messages`
      _(Note: the underlying cause was a config bug — `ensure_installed` was being ignored, so parsers never auto-installed. Fixed in commit `8080040`; after `git pull` + `:Lazy sync` they install automatically when a C compiler is present. See the 1.2 diagnosis.)_

#### 1.2 — Highlight active per filetype

1. Open `lua/plugins/treesitter.lua`. Run `:set ft?` — expect `filetype=lua`.
2. Run `:lua print(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()])` — should print a table (not `nil`).
3. Open `testdocs/hello.fsx`. Run `:set ft?` (expect `fsharp`) and repeat the highlighter check.
4. Open `testdocs/hello.cs`. Repeat both checks (`c_sharp` highlight active).
5. _(Optional — skip if not a Haskell machine)_ Open `testdocs/hello.hs`. Repeat both checks.

- [X] `lua`, `fsharp`, and `c_sharp` files show correct filetype and non-nil highlighter
>  - `lua` works as expected
>  - `c_sharp` and `fsharp` resolve to correct file type
>  - `c_sharp` and `fsharp` both return a `nil` table result
>  - `c_sharp`when loaded was unable ot spawn a language server, '... `{"Microsoft.CodeAnalysis.LanguageServer", "--stdio"} failed. The language server is either not installed, missing from PATH, or not executable.'
>
> **Diagnosis / resolution — ROOT CAUSE FOUND & FIXED (commit `8080040`):**
> - Not a missing-parser problem at heart. `lua/plugins/treesitter.lua` passed all its settings via lazy's `opts`, which lazy applies by calling `require("nvim-treesitter").setup(opts)`. On nvim-treesitter **master** that entry point takes **no arguments and discards `opts`** — so `highlight`, `indent`, `textobjects`, **and `ensure_installed`** never took effect. That's why `c_sharp`/`fsharp` had no highlighter *and* why their parsers were never auto-installed (1.3 text objects would have failed for the same reason).
> - `lua` (and `markdown`) appeared to "work" only because **Neovim's core** treesitter highlights them independently of the plugin — masking the bug. A working `lua` highlighter is *not* evidence the plugin is configured.
> - **Fix (highlight, kept):** route opts through `require("nvim-treesitter.configs").setup(opts)` via an explicit `config` function; corrected invalid `ensure_installed` names (`lisp`→`commonlisp`, dropped `plantuml` — both threw "Parser not available" once opts applied); disabled markdown TS highlight to preserve the markdown hotfix. Verified: `c_sharp`/`fsharp`/`lua` highlighters non-nil, markdown opens with no nil-range/languagetree error (baseline unchanged).
> - **Text objects (backed out):** the keymaps registered but silently no-op on Neovim 0.12 — frozen `master` calls a removed API (`tsrange.lua` → `:start()`). They were **removed** (commit `e2b5a7f`); restoring them requires moving to the `main` branch, tracked by the `migrate-treesitter-main` OpenSpec change. So step 1.3 below no longer applies.
> - **To re-validate here:** `git pull`, then `:Lazy sync` — `ensure_installed` now auto-installs the parsers (a **C compiler** must be on PATH; see One-Time Setup). Then re-run steps 1–5.
> - The `Microsoft.CodeAnalysis.LanguageServer` error is **separate/unrelated** — the Roslyn C# LSP server isn't installed (see the Roslyn step in *One-Time Test Machine Setup*). C# LSP is not required for this highlight check.

#### 1.3 — ~~Text object motions (non-Lisp buffer)~~ — REMOVED, not tested

> Struck through because the feature was **backed out** with the reverted `master`-branch
> decision: on Neovim 0.12 the frozen `master` text-object query path crashes
> (`tsrange.lua` → `:start()`), so the objects silently no-op. These steps were **never
> tested and never passed**. Restoring text objects is tracked by the
> `migrate-treesitter-main` OpenSpec change (moves nvim-treesitter to the maintained `main` branch).

~~1. Inside a function body, `vaf` selects the whole function; `vif` selects the body.~~
~~2. On a parameter, `via` selects the argument.~~
~~3. `daf` deletes the whole function.~~
~~4. `]f`/`[f` jump to next/previous function start; `]F`/`[F` to function ends.~~

- [ ] ~~All text-object motions behave as described~~ — N/A, feature removed

#### 1.4 — vim-sexp still works in Lisp buffers

Sanity check that the treesitter changes did not disturb Lisp structural editing
(vim-sexp was never driven by treesitter text objects).

1. Open a `.clj` file with a `defn` form. Press `vaf`.
2. Confirm the selection follows the s-expression (vim-sexp), as before.
3. Repeat with a `.lisp` and a `.janet` file.

- [X] vim-sexp behaviour unchanged in all three Lisp filetypes

> During testing it was discovered that visual highlighting was disabled, it has been re-enabled with:
> `:highlight Visual cterm=reverse ctermbg=None guibg=Grey`
> not sure where or when it was disabled but this does need to be enabled.  The command above does not
> need to be the definitive answer.

> The sample `hello.janet` file in the testdocs is missing ther required `defn` block to test.
>
> **Resolved:** Visual was invisible because the truecolor-first TokyoNight theme
> renders poorly in a non-truecolor console (`TERM=linux`, no `COLORTERM`). Fixed — the
> config detects real truecolor capability (`term.has_truecolor`); in a non-truecolor
> console it **skips TokyoNight** (default 16-color scheme), sets `termguicolors` off, and
> gives **Visual and Cursor an explicit uniform grey background + black text** (the colours
> are named constants at the top of `lua/plugins/colorscheme.lua`). `hello.janet` now has
> real `defn` forms.

#### 1.5 — Bracket maps unaffected (gitsigns / vim-unimpaired)

Confirms the treesitter changes did not clobber other plugins' bracket mappings.

1. **gitsigns `]h` / `[h`** — open a *tracked* file in this repo (e.g. `lua/options.lua`), change a couple of separate lines (no need to save; gitsigns marks the buffer against the index). Change-signs appear in the gutter. With the cursor above the first change, press `]h` → cursor jumps to the next changed hunk; `[h` → jumps to the previous one.
2. **buffer cycle `]b` / `[b`** — open two buffers: `:e testdocs/hello.lua` then `:e testdocs/hello.cs`. Press `]b` → the current buffer changes to the next one (confirm with `:ls` — the `%` current-buffer marker moves); `[b` → previous; it wraps around.
3. **spell toggle `yos`** — in any buffer press `yos`; `:set spell?` flips between `spell` and `nospell` on each press.

- [X] gitsigns `]h`/`[h`, buffer `]b`/`[b`, and spell `yos` all behave as described

> _(Clarified per test feedback: filetype/how-to-create-hunks/pass-criteria now specified above.)_

---

### Validate — Change 02: asciidoc authoring

#### 2.1 — Plugin installed

1. Open `:Lazy`. Search for `vim-asciidoctor` — confirm installed with no error icon.

- [X] vim-asciidoctor listed as installed, no errors

#### 2.2 — Filetype detection, folding, syntax

1. Open `docs/modules/ROOT/pages/editor/code-intelligence.adoc` cold.
2. Run `:set ft?` — expect `filetype=asciidoctor`.
3. Move to a section heading (`==` line). Press `za` — section folds. Press `za` — unfolds.
4. Find a `[source,lua]` block — Lua inside should be highlighted differently from surrounding AsciiDoc.

- [X] Filetype correct, fold works, fenced-block highlight active — **confirmed working after pull** (E484 fix + ufo yields folding to vim-asciidoctor)

> - The fold/unfold does not work.
> - There does not appear to be any text change to the `[source,lua]` block
>
> **Diagnosis:** the source-block highlight failed because vim-asciidoctor errored with
> `E484: Can't open file syntax/fsharp.vim` on every `.adoc` open — `fsharp` has no Vim
> syntax file. **Fixed** by dropping `fsharp` from `asciidoctor_fenced_languages`.
> **Fold:** on the dev machine `foldmethod=expr` / `foldexpr=AsciidoctorFold()` is set
> correctly — cursor on a `==` heading gives `foldlevel=1` and `zc` closes the fold, so
> folding **works**. Two changes make it robust: `fsharp` removed from
> `asciidoctor_fenced_languages` (the E484 error may have interrupted fold setup), and
> **nvim-ufo now yields folding to vim-asciidoctor** for the `asciidoctor` filetype
> (`provider_selector` returns `""`). **Re-test after pull** with the cursor **on a `==`/`===`
> heading line** and press `za`. If it still fails there, run `:verbose set foldmethod?`
> (expect `expr`, from vim-asciidoctor) and `:echo foldlevel('.')` (expect ≥1 on a heading).

#### 2.3 — Docker preview maps

1. In the `.adoc` buffer press `,p` (`<localleader>p`).
   - Docker running: browser tab or terminal output showing rendered HTML.
   - Docker not running: clean warning/error — no Neovim crash.
2. Press `,pp` — same preview flow.
3. Press `,pa` — Antora build starts (or clean Docker-offline message).

- [ ] All three maps fire without crashing Neovim

> - This does nothing in the pure tty terminal on a linux server and responds "Antora preview rtequires a graphical environment."
>
> **Expected — PASS on a headless server.** The `,p`/`,pp`/`,pa` maps deliberately check
> for a graphical environment (`term.is_console`) and emit that clean WARN instead of
> trying to launch a browser. On a pure TTY there is no browser to open, so the warning
> **is** the correct no-crash behaviour. Full browser preview can only be validated on a
> machine with a GUI. On a headless server, treat "clean WARN, no crash" as the pass.
>
> **Starting the Docker daemon** (only needed to render an actual preview, i.e. on a GUI
> machine — not on a pure TTY):
> ```bash
> sudo systemctl start docker      # systemd; or: sudo service docker start
> docker info                      # confirm the daemon is reachable
> # run docker without sudo: add your user to the group, then re-login:
> sudo usermod -aG docker "$USER"
> ```
> The first `,p`/`,pa` also pulls the `asciidoctor/docker-asciidoctor` / `antora/antora`
> images (needs network), so the first run is slow.
>
> **Finding (GUI machine): Firefox shows "Access to the file was denied".** Docker generates
> the HTML fine, but the preview is written to `~/.cache/nvim/asciidoc-preview-<n>.html` (a
> hidden dir) and opened as a `file://` URL. **snap-packaged Firefox** (the Ubuntu default)
> is sandboxed and cannot read `file://` paths under hidden/`.cache` dirs — hence the denial.
> The Neovim side works (no crash). **Fixed:** `,p`/`,pp` now convert with Docker as before,
> then serve the HTML over `http://127.0.0.1:8092` using a tiny **built-in libuv** server
> (`lua/config/http_preview.lua` — no python/node) and open that URL, so snap browsers can
> load `http://` (no more "access denied"). The server runs in-process (dies with Neovim) and
> is reused across previews. Re-test `,p` and expect the rendered page to open over http.

#### 2.4 — Markdown unaffected; markview absent

1. Open `readme.md`. Confirm markdown preview / glow still works.
2. Run `:Lazy` — search for `markview`. It should NOT appear.

- [X] Markdown tooling intact; markview absent from plugin list

> - Not related this defect directly, but the block cursor has an extended character in reverse - could this be related to the `:hightlight ...` set earlier?
>
> **Cursor:** `guicursor` is left at Neovim's default (per-mode block/bar). On the bare
> Linux VT console the block cursor inverts each cell, so over a **coloured** character the
> colored glyph shows through the block (it's clean over default-grey text). This is a
> console rendering limitation: making the cursor a solid, uniformly-coloured block needs a
> cursor-colour OSC escape the console mangles into a stray glyph — so we don't set one.
> A real terminal emulator (SSH client) renders the cursor cleanly. Not blocking.

---

### Validate — Change 03: blink completion

#### 3.1 — blink installed; nvim-cmp gone

1. Open `:Lazy`. Search for `blink.cmp` — confirm installed.
2. Search in turn for `nvim-cmp`, `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp-cmdline`, `cmp_luasnip` — none should appear.

- [X] blink.cmp present; all six cmp plugins absent

#### 3.2 — LSP, buffer, and path completions

1. Open `lua/plugins/blink.lua`. Enter insert mode, type `req` — LSP completions for `require` should appear.
2. Type a partial word present elsewhere in the file — buffer-word completion should appear.
3. Type `./` or `~/` — path completions should appear.
4. Open `testdocs/hello.fsx` with fsautocomplete running. Type `List.` — LSP completions should appear.

- [ ] All three completion sources work in both Lua and F# buffers

> **Confirmed on the test machine: buffer + path completion work; LSP (`req` in Lua, `List.`
> in F#) does not** — which is exactly the signature of the `lsp` source having **no attached
> server**. It needs the language servers installed (see *One-Time Setup*): Lua →
> `lua-language-server` on PATH; F# → `fsautocomplete`. Verify attachment from inside an open
> `.lua`/`.fsx` buffer: `:lua =vim.lsp.get_clients({ bufnr = 0 })` — an empty result means no
> server attached (so no LSP completions — not a blink defect). Install the servers, reopen
> the file, confirm a client attaches, then re-test steps 1 and 4.

#### 3.3 — Keymap behaviour

1. With completion menu open, press `<C-n>` / `<C-p>` — selection moves down/up.
2. Press `<C-e>` — menu dismisses.
3. In insert mode with menu closed (no item highlighted), press `<CR>` — inserts a newline, does not accept a completion.
4. Open menu, highlight an item, press `<CR>` — item is inserted.

- [X] Navigation, dismiss, and no-preselect newline all behave correctly

#### 3.4 — Command-line completion

blink provides completion for the **`:` command line** (sources: `cmdline` + `path`).
`/` and `?` are Vim's incremental **search** — that search is the primary, expected
behaviour there (a buffer-word menu may also appear, but the search is not a "failure").
Navigate the menu with `<Tab>`/`<C-n>`/`<C-p>` and accept with `<CR>` (blink `cmdline`
keymap preset).

1. Press `:` then type `Laz` — a menu appears listing `Lazy` and related commands; `<Tab>`
   selects, `<CR>` accepts.
2. Press `:` then type `e lua/` — file/directory path completions under `lua/` appear.
3. Press `/` then type a few characters — Neovim performs an incremental search (expected).
   A buffer-word menu may also show; either way, search working is the pass here.

- [X] `:` shows command + path completion (menu appears and accepts); `/` searches normally

#### 3.5 — Conjure completions (Lisp)

Conjure auto-connects to an nREPL via the `.nrepl-port` file the REPL writes into the
project dir. You need a real Clojure project (a bare `.clj` has no REPL).

1. Start an nREPL from a terminal, in a project dir:
   - **Leiningen** (`project.clj`): `lein repl` — writes `.nrepl-port` automatically.
   - **deps.edn**: `clojure -Sdeps '{:deps {nrepl/nrepl {:mvn/version "1.3.0"}}}' -M -m nrepl.cmdline` — add `--port 0` to auto-pick a port and write `.nrepl-port`.
2. Open a `.clj` file in that project — Conjure auto-connects (or run `:ConjureConnect`); the
   HUD shows the connection.
3. In insert mode, type the first characters of a REPL-defined var (e.g. `pri` for
   `println`) — Conjure completions appear in the blink menu.
4. If absent: check `:messages` for blink.compat errors and note for follow-up.

- [ ] _(Deferred — Clojure is not in scope right now; revisit when actually needed. Steps above kept for that point.)_

#### 3.6 — Spell completions gated by `spell` option

The `spell` completion source (dictionary words) is enabled **only when `spell` is on** and
only after **3+ characters** typed (`min_keyword_length = 3` in `lua/plugins/blink.lua`).
Markdown buffers have `spell` on by default; code filetypes set `nospell` (see
`after/ftplugin/*.lua`).

1. Open `testdocs/test.md`. Confirm `:set spell?` prints `spell`. In insert mode type
   `helllo` (misspelled, 6 chars). **Expected:** the blink menu includes dictionary
   suggestions such as `hello` / `hallo`; accepting one replaces the word.
2. In that same buffer run `:set nospell`, then type `helllo` again. **Expected:** *no*
   dictionary suggestions in the menu (spell source disabled).
3. Open `testdocs/hello.lua` (`:set spell?` prints `nospell`). Type `helllo`. **Expected:**
   no dictionary suggestions (only lsp/buffer/path/snippet items).

- [X] Dictionary suggestions appear only with `spell` on (3+ chars) and are absent when `spell` is off

---

### Raise PR & merge

- [ ] All validation steps above pass
- [ ] Raise PR: `feat/03-migrate-completion-blink` → `main`
- [ ] Review and approve PR
- [ ] Merge PR

### Post-merge

- [ ] `git checkout main && git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — confirm clean with no errors

---

## Change 04 · modernize-editing-plugins

**Branch:** `feat/04-modernize-editing-plugins`

### Prepare

1. `git fetch origin && git checkout feat/04-modernize-editing-plugins`
2. Launch Neovim: `:Lazy sync` — wait for completion

- [ ] Branch checked out, `:Lazy sync` complete with no errors

### Validate

#### 4.1 — Plugin inventory

1. Open `:Lazy`. Confirm `lualine.nvim` and `nvim-surround` are listed as installed.
2. Confirm the following are absent: `vim-airline`, `vim-surround`, `vim-sensible`, `vim-commentary`.

- [ ] Both new plugins present; all four removed plugins absent

#### 4.2 — Status line

1. Open any file. Confirm the left section shows the current mode (e.g. `NORMAL`).
2. In a git repo, confirm branch name and diff counts (+/-) appear.
3. Introduce a diagnostic error (e.g. a syntax error in a Lua file) — diagnostic count updates.
4. Confirm the right section shows filetype, scroll percentage, and cursor line:column.

- [ ] All four status line elements render correctly

#### 4.3 — Surround operations

1. Position cursor on a word. Type `ysiw"` — word wraps in double quotes.
2. With cursor on `"`, type `cs"'` — double quotes change to single.
3. With cursor on `'`, type `ds'` — quotes removed.
4. Undo all. Re-run `ysiw"`. Press `.` — surround repeats.

- [ ] Add, change, delete, and dot-repeat all work

#### 4.4 — Comment operator

1. Open `lua/plugins/treesitter.lua`. Press `gcc` — line commented. Press `gcc` — uncommented.
2. Select three lines in visual mode. Press `gc` — all commented. Press `gc` — uncommented.
3. Run `gcc`, move to another line, press `.` — comment toggle repeats.

- [ ] Toggle, visual range, and dot-repeat all work

#### 4.5 — vim-unimpaired + vim-repeat intact

1. Press `yos` — spell toggles (verify with `:set spell?`).
2. Open quickfix with `:copen`. Press `]q` / `[q` — walk entries.
3. Press `]b` / `[b` — cycles through open buffers.

- [ ] All three vim-unimpaired map groups work correctly

#### 4.6 — Clean startup

1. Restart Neovim. Run `:messages` — no errors or warnings about missing plugins or removed options.

- [ ] No startup errors; expected defaults present

### Raise PR & merge

- [ ] All validation steps above pass
- [ ] Raise PR: `feat/04-modernize-editing-plugins` → `main`
- [ ] Review and approve PR
- [ ] Merge PR

### Post-merge

- [ ] `git checkout main && git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — confirm clean

---

## Change 05 · upgrade-avante-drop-dressing

**Branch:** `feat/05-upgrade-avante-drop-dressing`

### Prepare

1. `git fetch origin && git checkout feat/05-upgrade-avante-drop-dressing`
2. Launch Neovim: `:Lazy update avante.nvim` — wait for update and build step
3. If build did not run automatically: `:AvanteBuild` — wait for completion

- [ ] Branch checked out, avante updated and built with no errors

### Validate

#### 5.1 — Avante at new version; build succeeded

1. Open `:Lazy`. Find `avante.nvim` — confirm version starts with `v0.1.` and no build error.

- [ ] Version is v0.1.x, build clean

#### 5.2 — Avante opens with current provider

1. Press `<leader>aa` — Avante panel opens on the right.
2. Type a short prompt and press `<CR>` — a response is received.

- [ ] Avante opens and responds

#### 5.3 — Ollama provider switch

1. Press `<leader>ao` — Avante switches to Ollama and opens.
2. If Ollama is not running: clean connection-refused error — no crash.

- [ ] Ollama switch fires cleanly (response or clean error)

#### 5.4 — Claude API provider switch

1. Ensure `ANTHROPIC_API_KEY` is set. Press `<leader>ac` — Avante switches to Claude API.
2. Type a short prompt — response arrives.

- [ ] Claude API provider works (skip and note if no API key available)

#### 5.5 — Diffview still works (plenary intact)

1. In a git repo with uncommitted changes, run `:DiffviewOpen` — side-by-side diff opens.
2. Run `:DiffviewClose` — closes cleanly.

- [ ] DiffviewOpen and DiffviewClose work

#### 5.6 — Native vim.ui fallback (dressing gone)

1. Trigger a code action (`<leader>ca`) on a line with an available LSP code action.
2. A native select prompt appears (not dressing). Select an option.
3. Confirm no error about missing `dressing.nvim`.

- [ ] vim.ui.select works via native fallback; no dressing errors

### Raise PR & merge

- [ ] All validation steps above pass
- [ ] Raise PR: `feat/05-upgrade-avante-drop-dressing` → `main`
- [ ] Review and approve PR
- [ ] Merge PR

### Post-merge

- [ ] `git checkout main && git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — confirm clean

---

## Change 06 · add-diagnostics-todo-panel

**Branch:** `feat/06-add-diagnostics-todo-panel`

### Prepare

1. `git fetch origin && git checkout feat/06-add-diagnostics-todo-panel`
2. Launch Neovim: `:Lazy sync` — wait for completion

- [ ] Branch checked out, `:Lazy sync` complete; trouble.nvim and todo-comments.nvim listed in `:Lazy`

### Validate

#### 6.1 — Plugins installed

1. Open `:Lazy`. Search for `trouble.nvim` — confirm installed.
2. Search for `todo-comments.nvim` — confirm installed.

- [ ] Both plugins listed as installed with no errors

#### 6.2 — Trouble diagnostic panels

1. Open `lua/plugins/trouble.lua`. Press `<leader>xx` — Trouble project diagnostics panel opens at the bottom.
2. Move cursor to an entry and press `<CR>` — jumps to that file and line.
3. Press `<leader>xX` — panel filters to current buffer only.
4. Press `<leader>xx` again — panel closes.

- [ ] Project panel opens, entry navigation works, buffer filter works

#### 6.3 — Native diagnostic maps unchanged

1. In a file with an LSP error, press `]d` / `[d` — jumps between diagnostics.
2. Position cursor on a diagnostic. Press `<leader>e` — floating window with diagnostic text appears.

- [ ] `[d`, `]d`, and `<leader>e` all behave as before

#### 6.4 — TODO/FIXME highlighting

1. Open `lua/plugins/treesitter.lua`. Add `-- TODO: test this`.
2. Confirm `TODO:` is highlighted with a distinct colour and a sign appears in the sign column.
3. Change `TODO` to `FIXME` — highlighted in a different colour.
4. Undo both additions.

- [ ] TODO and FIXME highlighted with distinct colours and signs

#### 6.5 — Todo list views

1. With the `-- TODO:` line present, press `<leader>xT` — fzf-lua picker opens listing todo comments.
2. Press `<Esc>` to close.
3. Press `<leader>xt` — Trouble panel opens showing todo comments. Entry from step 1 appears.

- [ ] fzf-lua picker and Trouble panel both list todo comments

#### 6.6 — vim-unimpaired tag maps intact

1. Ensure a `tags` file exists (or run `ctags -R`). Press `]t` / `[t` — jumps between tags.
2. Confirm `]t` / `[t` do tag navigation, NOT todo-comment navigation.

- [ ] `]t` / `[t` do tag navigation, not todo navigation

### Raise PR & merge

- [ ] All validation steps above pass
- [ ] Raise PR: `feat/06-add-diagnostics-todo-panel` → `main`
- [ ] Review and approve PR
- [ ] Merge PR

### Post-merge

- [ ] `git checkout main && git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — confirm clean

---

## Change 07 · add-dotnet-debug-test

**Branch:** `feat/07-add-dotnet-debug-test`

**Prerequisites** (confirm before switching branch):
- `netcoredbg --version` responds (installed in one-time setup above)
- A runnable .NET solution is available on the test machine
- A Haskell project is available (for DAP discovery check — optional)

### Prepare

1. `git fetch origin && git checkout feat/07-add-dotnet-debug-test`
2. Launch Neovim: `:Lazy sync` — wait for completion

- [ ] Branch checked out; nvim-dap, nvim-dap-ui, nvim-nio, easy-dotnet all listed in `:Lazy`

### Validate

#### 7.1 — Plugins installed

1. Open `:Lazy`. Confirm `nvim-dap`, `nvim-dap-ui`, `nvim-nio`, and `easy-dotnet.nvim` are all installed with no errors.

- [ ] All four plugins installed cleanly

#### 7.2 — Exactly one Roslyn LSP client

1. Open a `.cs` file from a .NET solution. Wait for roslyn.nvim to attach.
2. Run `:lua =vim.lsp.get_clients({ name = "roslyn" })` — expect exactly one table entry.
   If two entries appear, easy-dotnet has started a second Roslyn server — configuration error.

- [ ] Exactly one Roslyn client returned

#### 7.3 — Breakpoint and step debugging

1. Open a `.cs` file in a runnable .NET project. Press `<F9>` on a line — breakpoint sign appears.
2. Press `<F5>` — easy-dotnet project picker appears; select the project.
3. nvim-dap-ui panel opens automatically. Execution pauses at the breakpoint.
4. Press `<F10>` (step over), `<F11>` (step into), `<F12>` (step out) — cursor follows.
5. Press `<S-F5>` — session terminates and dap-ui closes.

- [ ] Full debug cycle (set breakpoint → start → pause → step → stop) works

#### 7.4 — easy-dotnet test and run maps

1. Open a `.cs` file. Press `,tt` — test runner opens and runs tests.
2. Press `,tr` — project runner fires (picker appears if multiple projects).
3. Open `testdocs/hello.fsx`. Confirm `,tt` and `,tr` are active in F# buffers too.

- [ ] Test and run maps work in both C# and F# buffers

#### 7.5 — Haskell DAP config discovery

1. Open `testdocs/hello.hs` (or any `.hs` file).
2. Run `:lua =require("dap").configurations.haskell`.
3. Non-nil table = haskell-tools registered a config (pass). `nil` = note for follow-up (not blocking).

- [ ] Result noted (non-nil = pass; nil = follow-up required)

#### 7.6 — Existing .NET maps unaffected

1. Open a `.cs` file. Connect the iron.nvim REPL (`<localleader>si`). Press `<localleader>sl` — line sent to REPL.
2. Confirm `gd`, `K`, and `gr` all work via the Roslyn LSP.

- [ ] iron REPL and LSP navigation intact

### Raise PR & merge

- [ ] All validation steps above pass
- [ ] Raise PR: `feat/07-add-dotnet-debug-test` → `main` (confirm `lsp = { enabled = false }` in easy-dotnet opts)
- [ ] Review and approve PR
- [ ] Merge PR

### Post-merge

- [ ] `git checkout main && git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — confirm clean

---

## Change 08 · add-claudecode-session

**Branch:** `feat/08-add-claudecode-session`

**Prerequisites** (confirm before switching branch):
- `claude --version` responds and is authenticated
- Run `claude` in a terminal — CLI launches without error

### Prepare

1. `git fetch origin && git checkout feat/08-add-claudecode-session`
2. Launch Neovim: `:Lazy sync` — wait for completion

- [ ] Branch checked out; claudecode.nvim listed in `:Lazy`; snacks.nvim absent

### Validate

#### 8.1 — Plugin installed; snacks absent

1. Open `:Lazy`. Search for `claudecode.nvim` — confirm installed.
2. Search for `snacks.nvim` — it should NOT appear.

- [ ] claudecode.nvim installed; snacks.nvim absent

#### 8.2 — Session terminal opens and connects

1. Press `<leader>gcc` — native terminal split opens running the `claude` CLI.
2. Wait for the Claude Code prompt. If MCP does not connect automatically, type `/ide` and press Enter.
3. No errors about missing providers or snacks.

- [ ] Native terminal opens, `claude` CLI runs, MCP connects

#### 8.3 — Send selection and add buffer

1. Return to the editor (`<C-\><C-n>` then move to an editor window).
2. Open `lua/plugins/claudecode.lua`. Select two or three lines in visual mode (`V`).
3. Press `<leader>gcv` — selected lines appear in the Claude session.
4. Press `<leader>gcb` — current buffer file path added to Claude's context.

- [ ] Selection send and buffer add both reach the session

#### 8.4 — Diff accept and reject

1. In the Claude session, ask Claude to add a comment to `lua/plugins/claudecode.lua`.
2. Neovim opens a diff view. Press `<leader>gca` — change is accepted and written.
3. Undo (`u`). Ask for another edit. Press `<leader>gcr` — diff rejected, file unchanged.

- [ ] Accept diff and reject diff both work correctly

#### 8.5 — One-shot claude_cli maps still work

1. Press `<leader>gcs` — floating window appears with a shell command suggestion.
2. Select a function in visual mode. Press `<leader>gce` — floating window with code explanation.
3. Press `q` or `<Esc>` to close each.

- [ ] `<leader>gcs` and `<leader>gce` (claude_cli) still work alongside the session

#### 8.6 — Avante maps unaffected

1. Press `<leader>aa` — Avante opens normally.
2. Press `<leader>ao` — switches to Ollama (or clean error if offline).
3. Press `<leader>ac` — switches to Claude API provider.
4. Confirm no `<leader>gc*` map bleeds into the `<leader>a*` namespace.

- [ ] All three Avante maps unaffected; no namespace collision

### Raise PR & merge

- [ ] All validation steps above pass
- [ ] Raise PR: `feat/08-add-claudecode-session` → `main` (confirm snacks.nvim is NOT in dependencies)
- [ ] Review and approve PR
- [ ] Merge PR

### Post-merge

- [ ] `git checkout main && git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — confirm clean

---

## All Changes Complete

- [ ] All changes (hotfix + 03–08) validated on branch and merged to main
- [ ] No open issues from validation runs
- [ ] lazy-lock.json committed on main reflects the final plugin state
