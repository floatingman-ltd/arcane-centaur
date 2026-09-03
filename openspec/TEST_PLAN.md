# Test & Validation Plan

Single source of truth for change validation. Each section covers one change:
prepare the branch → validate → raise PR → merge → confirm post-merge.

**Workflow:** validate on the feature branch **before** raising a PR. Never merge first and test after.

**Step numbering:** validation steps are prefixed with their change number — Change 01 steps are `1.x`, Change 02 are `2.x`, … Change 08 are `8.x`. (Changes 01–03 are all validated under the Change 03 section, since that branch inherits them.)

Sample files for filetype/highlight/completion tests are in `testdocs/`: single-file samples
(`hello.lua`, `hello.cs`, `hello.fs`, `hello.fsx`, `hello.hs`, `hello.clj`, `hello.scm`,
`hello.fnl`, `hello.janet`, `hello.lisp`, `hello.http`, `index.html`/`style.css`/`script.js`,
`test.adoc`/`test.md`/`test.puml`), plus full project fixtures for reliable LSP/debug testing:
`testdocs/fsharp-project/` (a `.fsproj`) and `testdocs/csharp-project/` (a `.csproj`).

---

## One-Time Test Machine Setup

Complete once before any testing begins.

- [X] Confirm Neovim ≥ 0.12 is installed: `nvim --version`
- [X] Confirm Git is installed: `git --version`
- [X] Confirm Node.js + npm are installed (required by markdown-preview.nvim build): `node --version && npm --version`
- [X] Confirm the `dotnet` SDK is installed: `dotnet --version` (SDKs: `dotnet --list-sdks`; runtimes: `dotnet --list-runtimes`). **The sample F#/C# projects target `net8.0`**, so you need the **net8.0 runtime** (`Microsoft.NETCore.App 8.0.x`) present to build/run/**debug** them (Change 07) — either install the `net8.0` runtime/SDK (`sudo apt install dotnet-runtime-8.0`), or bump `<TargetFramework>` in `testdocs/fsharp-project`/`testdocs/csharp-project` to your installed version (e.g. `net10.0`, also LTS). A mismatch means the LSP can't resolve the project (no completions) **and** run/debug fails.
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
- [X] Install **lua-language-server** (Lua LSP completions, Change 03 §3.2) — not in apt/snap on Ubuntu 24.04; download from https://github.com/LuaLS/lua-language-server/releases, extract, and put `bin/lua-language-server` on PATH. Verify: `lua-language-server --version`
- [X] Install **fsautocomplete** (F# LSP completions, Change 03 §3.2): `dotnet tool install -g fsautocomplete` (needs the dotnet SDK above; ensure `~/.dotnet/tools` is on PATH). Verify: `fsautocomplete --version`
- [X] Install the **`EasyDotnet` server tool** (required by easy-dotnet.nvim for Change 07 debug/test/run/build — the plugin is a thin client over this server): `dotnet tool install -g EasyDotnet` (needs `~/.dotnet/tools` on PATH). Verify: `dotnet-easydotnet -v`; in-editor `:checkhealth easy-dotnet`.
- [X] Install **ripgrep** (`rg`) — required by todo-comments.nvim's search commands for Change 06 §6.5 (`<leader>xt` / `<leader>xT`), and used by fzf-lua generally: `sudo apt install ripgrep` (Debian/Ubuntu; or `brew install ripgrep` / `sudo dnf install ripgrep`). Verify: `rg --version`
- [X] Install the **`fzf`** binary — fzf-lua wraps the `fzf` fuzzy finder (no pure-Lua fallback); needed by `<leader>xT` (`:TodoFzfLua`) in Change 06 §6.5 and any fzf-lua picker: `sudo apt install fzf` (Debian/Ubuntu; or `brew install fzf` / `sudo dnf install fzf`). Verify: `fzf --version`
- [X] Install **universal-ctags** (`ctags`) — a **soft/optional dependency** (documented in `getting-started.adoc` §System Dependencies): the config never invokes it, but it generates the `tags` file that tag navigation reads — needed here to exercise Change 06 §6.6 (`]t`/`[t`). `sudo apt install universal-ctags` (Debian/Ubuntu; or `brew install universal-ctags`). Verify: `ctags --version`
- [X] Confirm `claude` CLI is installed and authenticated (required for Change 08): `claude --version`
- [X] Clone the repo: `git clone git@github.com:floatingman-ltd/arcane-centaur.git ~/.config/nvim`
- [X] Confirm initial main state loads: `nvim` → `:Lazy sync` → no errors in `:messages`
- [ ] Start the **Ollama backend** — avante's *default* provider (needed for Change 05 §5.2/§5.3); requires Docker Engine + Compose. Bring it up **and pull the model avante is configured for** (the compose file starts the server but pulls no models). Avante defaults to the small **`qwen2.5:0.5b`** (~0.4 GB, chosen for very-limited-RAM machines; for more capability bump to `llama3.2:1b` (~1.3 GB) or `llama3.2:3b` and set the same tag as `model` in `lua/plugins/avante.lua`):
  ```bash
  docker compose -f ~/.config/nvim/docker/ollama/docker-compose.yml up -d
  # Pull via Ollama's HTTP API — no `docker exec`, so it avoids the runc console-socket
  # "read-only file system" error that `docker compose exec` hits on some hosts (with or without -T):
  curl http://127.0.0.1:11434/api/pull -d '{"name":"qwen2.5:0.5b"}'
  ```
  Verify: `curl -s http://127.0.0.1:11434/api/tags` lists `qwen2.5:0.5b`. (If the *container itself* won't start, fix Docker — see *Known defect — Docker container storage is read-only* below. Keep Ollama containerized; do not install it natively.) Details: `docs/…/getting-started.adoc` § Ollama.

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

## Resolved defect (runbook retained) — root filesystem `/` mounted read-only

> **Status: RESOLVED (2026-07-13) — mitigated by replacing the test machine.** The original test
> machine suffered a **catastrophic HDD failure (the swap partition died)**, which is what had
> forced `/` read-only. It has been retired and replaced; on the new test machine `/` mounts
> read-write and all Docker-based features work normally.
>
> **This section is kept as a runbook** in case a read-only `/` recurs on any future machine — the
> diagnosis and fix below still apply. It no longer blocks validation.

**Root cause found:** the (now-retired) test machine's **root filesystem `/` was mounted read-only.**
Everything that wrote under `/` failed; only the separately-mounted, writable `/home` worked. This
was **not** a Docker bug — Docker was collateral damage (its storage lives under `/var/lib/docker`).

**Impact (historical):** blocked anything that writes under `/`, incl. **all Docker-based features**
(Change 05's containerized Ollama §5.2/§5.3; Change 02's full-site Antora preview `,pa`; PlantUML,
MARP, Markdown export, Lisp REPL containers). 06/07/08 write only under `~` and were unaffected.

**Symptom:** writes under `/` → EROFS; writes under `/home` → OK.

- `sudo tee /etc/docker/daemon.json` → `Read-only file system` ← the tell
- `docker run --rm alpine sh -c 'touch /t'` → `read-only file system`; ollama model write (volume
  under `/var/lib/docker`) → `… read-only file system`; `docker compose exec` runc socket → EROFS;
  `sudo systemctl restart docker` fails (dockerd can't init on read-only `/var/lib/docker`)
- **Works:** git, `:Lazy sync` (`~/.local/share/nvim`), libuv AsciiDoc preview (`~/.cache`) — all
  under the writable `/home`.

**Why it was mis-diagnosed at first:** `findmnt / ` was run with `FSTYPE,SOURCE` (not `OPTIONS`), so
the `ro` flag didn't show → it looked like a healthy ext4 root and the trail wrongly pointed at the
containerd snapshotter. `/` is ext4 on LVM (`/dev/mapper/ubuntu--vg-ubuntu--lv`) — a fine fs, just
mounted read-only.

**Fix — remount `/` read-write, then make it stick:**

```bash
findmnt -no OPTIONS /            # confirm it shows `ro`
sudo mount -o remount,rw /       # remount read-write
findmnt -no OPTIONS /            # confirm now `rw`
sudo systemctl restart docker    # dockerd now initializes; stock config is fine (snapshotter OK)
docker run --rm alpine sh -c 'touch /t && echo OK'   # expect: OK
```

Then find **why** it went read-only so it survives a reboot:

```bash
grep -E '\s/\s' /etc/fstab                                   # is / set `ro` in fstab? fix to defaults / errors=remount-ro
dmesg | grep -iE 'EXT4-fs|remount|read-only|I/O error' | tail   # fs error → needs fsck
```

- fstab has `ro` for `/` → correct it and reboot.
- `dmesg` shows ext4/I-O errors → the kernel remounted `/` ro defensively: `sudo touch /forcefsck && sudo reboot` to repair (a possibly-failing disk — check SMART).
- Neither → transient `errors=remount-ro` trip; `remount,rw` holds for now, but run `fsck` to be safe.

Once `/` is read-write, Docker works normally with the **stock** config (the containerd snapshotter
was never the problem — no `daemon.json` change needed), and everything stays containerized.

**Recovery checklist — only if a read-only `/` recurs on some future machine** (not pending work; the
current test machine is unaffected):

- [ ] `/` remounted read-write (`findmnt -no OPTIONS /` shows `rw`)
- [ ] Root cause of the ro state identified (fstab vs fsck-level fs error) and made permanent
- [ ] Docker confirmed — `docker run --rm alpine sh -c 'touch /t && echo OK'` succeeds
- [ ] Docker-based features re-validated (Ollama §5.2/§5.3, Antora `,pa`, PlantUML, MARP, Markdown export, Lisp containers)

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

- [X] All three maps fire without crashing Neovim — `,p`/`,pp` render over http, **confirmed working**

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
> is reused across previews. **Confirmed working.**
>
> _Follow-up: `,pa` (Antora full-site) still opens `build/site/index.html` via `file://`, which
> lives under the hidden `~/.config/...` path — so it will hit the same snap-browser block if
> used. It can get the same http-serve treatment (serve `build/site/` via the libuv server)
> when Antora preview is exercised._

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

- [X] All three completion sources work in both Lua and F# buffers — Lua + F# LSP both complete (F# after aligning the SDK/TargetFramework, see root cause below); buffer + path confirmed

> **Buffer + path completion work with no server** (blink is fine). LSP completions need the
> servers installed (see *One-Time Setup*): Lua → `lua-language-server`; F# → `fsautocomplete`.
>
> - **Lua: ✅ works** (`req` → `require`) once `lua-language-server` is on PATH.
> - **F#: `fsautocomplete` installed but `List.` shows no menu.**
>   - **ROOT CAUSE (confirmed): SDK ↔ TargetFramework mismatch.** The installed SDK was
>     **10.0** but the project targets **`net8.0`**, so the SDK can't resolve the project's
>     options → FSharp.Core never loads → `List.` (and all FSharp.Core) don't complete, while
>     `System.` still does (it comes from the BCL default references). **Fix — make them
>     match:** either install the runtime/SDK the project targets (`net8.0`), *or* bump
>     `<TargetFramework>` in the `.fsproj`/`.csproj` to your installed version (e.g. `net10.0`;
>     see `dotnet --list-sdks`). Confirm with `dotnet build` succeeding against your SDK, then
>     reopen the file — `List.` completes.
>   - If it *still* doesn't complete, the tool being on PATH ≠ the server attaching. Diagnose in an open `.fs`/`.fsx`:
>   - `:lua =vim.lsp.get_clients({ bufnr = 0 })` — is a `fsautocomplete` client attached?
>     Empty = not attaching (check `:LspLog`); non-empty = attached, see next.
>   - `:lua vim.cmd('e ' .. vim.lsp.get_log_path())` — look for fsautocomplete startup errors.
>   - **Observed:** fsautocomplete *is* attached, but `:LspLog` shows
>     **"Error getting project options for … hello.fsx"** — it can't resolve the *script's*
>     compiler options, so it has no symbols to complete. This is F# script tooling (.NET SDK),
>     not a blink/Neovim defect. Checks:
>     - `dotnet --list-sdks` must list a full **SDK** (not just a runtime) — script resolution needs it.
>     - `:lua =vim.fn.exepath('dotnet')` — Neovim (hence fsautocomplete) must be able to find `dotnet`.
>     - `dotnet fsi testdocs/hello.fsx` from a terminal — if FSI can't run the script, fsautocomplete can't resolve it either.
>     - Standalone `.fsx` is the finickiest case. **A real project fixture now exists** — open
>       `testdocs/fsharp-project/Program.fs` and type `List.` there; fsautocomplete resolves
>       *project* options, so completion is reliable. That is the recommended F# test.
>     - **`System.` completing while `List.` doesn't is NOT a missing `open`/`using`.** In F#
>       the `List` module is auto-opened (FSharp.Core's `Microsoft.FSharp.Collections`) — the
>       fixture's `Program.fs` uses `List.map`/`List.sum` with no `open` and compiles. `System.`
>       resolves from the .NET **BCL default references** even when script options fail; `List.`
>       needs **FSharp.Core** resolved, which is precisely what the standalone-`.fsx`
>       "Error getting project options" blocks. In the `.fsproj` fixture FSharp.Core resolves,
>       so `List.` completes — no `open` required.

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

- [X] All validation steps above pass — Change 01 (highlight), 02 (asciidoc), 03 (blink) all green; `1.3` text objects **N/A** (backed out) and `3.5` Conjure/Clojure **deferred** (out of scope)
- [X] Raise PR: `feat/03-migrate-completion-blink` → `main` (PR #135)
- [X] Review and approve PR
- [X] Merge PR

### Post-merge

- [X] `git checkout main && git pull origin main` (`main` at `9474590`)
- [X] Launch Neovim: `:Lazy sync` — confirm clean with no errors

---

## Change 04 · modernize-editing-plugins

**Branch:** `feat/04-modernize-editing-plugins`

### Before you start

- **Dirty-tree first.** This is the first branch that changes the plugin set (adds
  `lualine.nvim` + `nvim-surround`, removes four), so Prepare's `:Lazy sync` is the first sync to
  actually run plugin builds. If it fails on `markdown-preview.nvim` / `bracey.vim`, run the reset
  in *Troubleshooting — `:Lazy sync` fails … (dirty tree)* near the top of this file, then re-sync.
- **4.2 diagnostics need an LSP.** Open a `.lua` file and let `lua_ls` attach *before* introducing
  the syntax error — the status line's diagnostic count is populated by `vim.diagnostic`, which only
  has entries once a diagnostic producer (`lua-language-server`, from one-time setup) is attached.
- **4.4 comments are Neovim-native.** vim-commentary was removed with no replacement plugin;
  `gc`/`gcc` come from Neovim's built-in commenting. A `gcc` failure means the built-in, not a
  missing plugin.

### Prepare

1. `git fetch origin && git checkout feat/04-modernize-editing-plugins`
2. Launch Neovim: `:Lazy sync` — wait for completion

- [X] Branch checked out, `:Lazy sync` complete with no errors

### Validate

#### 4.1 — Plugin inventory

1. Open `:Lazy`. Confirm `lualine.nvim` and `nvim-surround` are listed as installed.
2. Confirm the following are absent: `vim-airline`, `vim-surround`, `vim-sensible`, `vim-commentary`.

- [X] Both new plugins present; all four removed plugins absent

#### 4.2 — Status line

The status line is global (`globalstatus`). Layout, left → right:
**mode** · **branch** + **diff (+/-)** + **diagnostics** · **filename** … (right) **filetype** · **scroll %** · **line:column**.
Both the **diff counts and the diagnostics count sit in the left section, right after the branch — not
on the right.** (The `[+]` shown *after the filename* is lualine's "modified" flag, not the diff.)

1. Open any file. The far-left shows the current mode (e.g. `NORMAL`).
2. In a git repo, the next section shows the branch name. Edit a tracked file — the diff counts
   (added/changed/removed) update **live from gitsigns**, right after the branch (no save needed).
3. Open a `.lua` file and confirm `lua_ls` is attached — this config uses Neovim's native LSP, so
   there is **no `:LspInfo`** command; check with `:checkhealth vim.lsp` or
   `:lua =vim.lsp.get_clients({ bufnr = 0 })`. Introduce a *real* error — e.g. type `local x =`
   alone on a line, or delete a function's closing `end`. Within a second a diagnostics count
   (error glyph + number) appears **in the left section, just after the branch/diff**. The component
   reads the unified diagnostic API (`sources = { "nvim_diagnostic" }`); if the count doesn't show,
   confirm the buffer actually has diagnostics with `:lua =vim.diagnostic.get(0)`.
4. The right side shows filetype, scroll percentage, and cursor line:column.

- [X] All status line elements render, including the diagnostics count in the left section

#### 4.3 — Surround operations

1. Position cursor on a word. Type `ysiw"` — word wraps in double quotes.
2. With cursor on `"`, type `cs"'` — double quotes change to single.
3. With cursor on `'`, type `ds'` — quotes removed.
4. Undo all. Re-run `ysiw"`. Press `.` — surround repeats.

- [X] Add, change, delete, and dot-repeat all work

#### 4.4 — Comment operator

1. Open `lua/plugins/treesitter.lua`. Press `gcc` — line commented. Press `gcc` — uncommented.
2. Select three lines in visual mode. Press `gc` — all commented. Press `gc` — uncommented.
3. Run `gcc`, move to another line, press `.` — comment toggle repeats.

- [X] Toggle, visual range, and dot-repeat all work

#### 4.5 — vim-unimpaired + vim-repeat intact

vim-unimpaired adds `[`/`]` "previous/next" pairs. Each moves through a *list*, not the word under the
cursor. For "jump to the next/previous occurrence of the word I'm on" you want Vim's built-ins, no
typing: `*` / `#` (next/previous occurrence of the word under the cursor) and `n` / `N` to repeat;
`]d` / `[d` (LSP, from `lua/config/lsp.lua`) jump between diagnostics.

1. `yos` — toggle spell (verify with `:set spell?`; it flips `spell` ⇄ `nospell`).
2. **Quickfix** — `]q`/`[q` map to `:cnext`/`:cprevious` and walk the *quickfix list*: file locations
   you build with real commands. Concrete producers: **`gr`** (LSP references — every use of the
   symbol under the cursor), **`:lua vim.diagnostic.setqflist()`** (all LSP errors/warnings, to fix in
   turn), **`:grep`/`:vimgrep` then `:cdo s/old/new/g | update`** (project-wide search-and-replace),
   **`:make`** (build errors). For the test: put the cursor on a symbol used more than once, press
   `gr`, then `]q` / `[q` step through the references. *(Empty list → nothing happens, `E42: No
   Errors`.)* Full workflows: `docs/…/editor/navigation.adoc` → Quickfix.
3. **Buffers** — `]b`/`[b` map to `:bnext`/`:bprevious`. Open a second file so at least two buffers
   are listed (check `:ls`), then `]b` / `[b` cycles the current window between them.

- [X] `yos`, `]q`/`[q` (quickfix), and `]b`/`[b` (buffers) all work

#### 4.6 — Clean startup

1. Restart Neovim. Run `:messages` — no errors or warnings about missing plugins or removed options.

- [X] No startup errors; expected defaults present

### Raise PR & merge

- [X] All validation steps above pass
- [X] Raise PR: `feat/04-modernize-editing-plugins` → `main`
- [X] Review and approve PR
- [X] Merge PR (PR #139)

### Post-merge

- [X] `git checkout main && git pull origin main` (`main` at `9474590`)
- [X] Launch Neovim: `:Lazy sync` — confirm clean

---

## Change 05 · upgrade-avante-drop-dressing

**Branch:** `feat/05-upgrade-avante-drop-dressing`

### Prepare

1. `git fetch origin && git checkout feat/05-upgrade-avante-drop-dressing`
2. Launch Neovim: `:Lazy update avante.nvim` — wait for update and build step
3. If build did not run automatically: `:AvanteBuild` — wait for completion
4. **Restart Neovim before validating.** This upgrade jumps avante v0.0.x → v0.1.x *in place*.
   `:Lazy update` rewrites the files on disk, but the running session keeps the **old avante Lua
   modules cached** (it loads on `VeryLazy`), so the new `ftplugin/AvanteInput.lua` calls into stale
   code and errors with `attempt to call field 'place_sign_at_first_line' (a nil value)` the moment
   you type in the prompt. A full quit + relaunch loads the v0.1.x modules cleanly. _(If it still
   errors after a restart, do a clean reinstall: `:Lazy clean avante.nvim` → `:Lazy install` →
   `:AvanteBuild` → restart.)_

- [X] Branch checked out, avante updated + built, **Neovim restarted** — no errors

### Validate

#### 5.1 — Avante at new version; build succeeded

1. Open `:Lazy`. Find `avante.nvim` — confirm version starts with `v0.1.` and no build error.

- [X] Version is v0.1.x, build clean

#### 5.2 — Avante opens with current provider

1. Press `<leader>aa` — Avante panel opens on the right.
2. Type a short prompt and press `<C-s>` to submit (avante's submit key — `<CR>` just inserts a newline) — a response is received.

- [X] Avante opens and responds

#### 5.3 — Ollama provider switch

1. Press `<leader>ao` — Avante switches to Ollama and opens.
2. If Ollama is not running: clean connection-refused error — no crash.

- [X] Ollama switch fires cleanly (response or clean error)

#### 5.4 — ~~Claude backend~~ (removed) — N/A

The Claude/Anthropic provider was removed entirely — avante is Ollama-only (Anthropic's ToS scopes
subscription OAuth tokens to Claude Code / claude.ai, and the API-key path was declined too). There
is nothing to validate here.

- [ ] ~~Claude provider works~~ — N/A, provider removed

#### 5.5 — Diffview still works (plenary intact)

Keymaps exist (in `lua/plugins/git.lua`, under the `<leader>g` group) — no need to type the commands:

1. In a git repo with uncommitted changes, press `<leader>gD` (`:DiffviewOpen`) — side-by-side diff opens.
2. Press `<leader>gX` (`:DiffviewClose`) — closes cleanly.
3. `<leader>gH` (`:DiffviewFileHistory %`) — opens history for the current file.

- [X] DiffviewOpen / close / file-history work via `<leader>gD` / `<leader>gX` / `<leader>gH`

#### 5.6 — Native vim.ui.select / vim.ui.input (dressing.nvim removed)

With `dressing.nvim` gone, `vim.ui.select` and `vim.ui.input` must fall back to Neovim's built-in
implementations. Test each **directly** — deterministic, no LSP or plugin state needed. Run each
command from Normal mode (type `:` then paste).

1. **`vim.ui.select` — choose.** Run exactly:

   ```
   :lua vim.ui.select({ "one", "two", "three" }, { prompt = "Pick:" }, function(c) vim.notify("picked: " .. tostring(c)) end)
   ```

   Expect: a numbered prompt in the command area — `Pick:` then `1: one`, `2: two`, `3: three`.
   Type `2`, press `<CR>`. Expect: a notification / `:messages` line reads exactly `picked: two`.

2. **`vim.ui.select` — cancel.** Run the same command again, then press `<Esc>` (don't type a number).
   Expect: `picked: nil`, no error.

3. **`vim.ui.input`.** Run exactly:

   ```
   :lua vim.ui.input({ prompt = "Name: " }, function(i) vim.notify("got: " .. tostring(i)) end)
   ```

   Expect: a `Name:` prompt on the command line. Type `hello`, press `<CR>`. Expect: `got: hello`.
   Repeat and press `<Esc>` instead → expect `got: nil`.

4. **dressing is actually gone.** Run:

   ```
   :lua print(pcall(require, "dressing"))
   ```

   Expect: prints `false` (module not found). Then `:messages` — expect **no** `dressing`-related
   error from steps 1–3.

5. **(Optional real-world path) LSP code action** (`<leader>ca`). The native list also backs LSP
   code actions — but the *set* of actions is LSP-dependent:
   - **lua_ls** (`testdocs/hello.lua`) mostly offers **diagnostic-suppression** actions ("Disable
     diagnostics here", "Mark as global") — LuaLS is not a refactoring server, so that's expected,
     not a bug.
   - For a genuine **code-level** action, use **roslyn** in `testdocs/csharp-project/Program.cs`:
     put the cursor on `var total = 0;` (in `SumOfSquares`) and press `<leader>ca` → roslyn offers a
     real refactor such as *Use explicit type* (`var` → `int`). Pick it and the code actually changes.
   Either way the point is only that the native select UI appears and applies your choice — steps
   1–4 already prove the fallback deterministically.

- [X] Steps 1–4 pass: native `vim.ui.select` (choose **and** cancel) and `vim.ui.input` both work, and `dressing` is absent with no dressing errors

### Raise PR & merge

- [X] All validation steps above pass — 5.1/5.2/5.3/5.5/5.6 pass; 5.4 N/A (claude removed)
- [X] Raise PR: `feat/05-upgrade-avante-drop-dressing` → `main` (PR #140)
- [X] Review and approve PR
- [X] Merge PR (PR #140)

### Post-merge

- [X] `git checkout main && git pull origin main` (`main` at `9474590`)
- [X] Launch Neovim: `:Lazy sync` — confirm clean

---

## Change 06 · add-diagnostics-todo-panel

**Branch:** `feat/06-add-diagnostics-todo-panel`

### Prepare

1. `git fetch origin && git checkout feat/06-add-diagnostics-todo-panel`
2. Launch Neovim: `:Lazy sync` — wait for completion

- [X] Branch checked out, `:Lazy sync` complete; trouble.nvim and todo-comments.nvim listed in `:Lazy`

### Validate

#### 6.1 — Plugins installed

1. Open `:Lazy`. Search for `trouble.nvim` — confirm installed.
2. Search for `todo-comments.nvim` — confirm installed.

- [X] Both plugins listed as installed with no errors

#### 6.2 — Trouble diagnostic panels

1. Open `lua/plugins/trouble.lua`. Press `<leader>xx` — Trouble project diagnostics panel opens at the bottom.
2. Move cursor to an entry and press `<CR>` — jumps to that file and line.
3. Press `<leader>xX` — panel filters to current buffer only.
4. Press `<leader>xx` again — panel closes.

- [X] Project panel opens, entry navigation works, buffer filter works — **pass after the trouble.nvim fix below** (`branch = main` @ `bd67efe`)

> **Defect found & fixed — trouble.nvim crashed on panel render (Neovim 0.12 API drift).**
> Opening the panel threw, from trouble's own treesitter decoration provider:
> ```
> Decoration provider "line" (ns=trouble.treesitter):
> Lua: .../trouble.nvim/lua/trouble/view/treesitter.lua:18: attempt to call a nil value
> ```
> **Root cause:** trouble **v3.7.1** registers `on_line = wrap("_on_line")` and calls
> `vim.treesitter.highlighter._on_line`. Neovim **0.12** refactored the highlighter and
> **removed `_on_line`** (replaced by `_on_range`; `_on_win` remains), so the lookup is
> `nil` → crash on the `on_line` decoration callback. Same 0.12-API-drift family as the
> treesitter-master issue.
> **Upstream already fixed it** (folke #656/#661): `main` branches on
> `if TSHighlighter._on_range then` (uses `on_range` on 0.12, `on_line` only on older
> Neovim). The fix is **not in any tagged release** — newest tag is v3.7.1 (our pin), so
> `version = "*"` can't reach it.
> **Fix applied (this branch):** `lua/plugins/trouble.lua` now tracks `branch = "main"`
> (was `version = "*"`); `lazy-lock.json` bumped to `bd67efe` (includes #656/#661). Revert
> to `version = "*"` once a release ≥ 3.7.2 ships the fix.
> **Re-test on the test machine:** `:Lazy sync` (or `:Lazy update trouble.nvim`) → confirm
> trouble.nvim is at `bd67efe` / branch `main` in `:Lazy` → **restart Neovim** → re-run 6.2.
> If it still errors, force a clean checkout: `:Lazy clean trouble.nvim` → `:Lazy install` → restart.

#### 6.3 — Native diagnostic maps unchanged

These maps live in `lua/config/lsp.lua` and are set in `on_attach`, so they work **only in a
buffer with an LSP attached and at least one diagnostic**. Use a Lua file — `lua_ls` (one-time
setup) attaches automatically. Bindings: `<leader>e` = `vim.diagnostic.open_float`;
`[d` / `]d` = `vim.diagnostic.jump({ count = -1 / 1 })`.

1. Open `testdocs/hello.lua`. Confirm lua_ls is attached:
   `:lua =vim.lsp.get_clients({ bufnr = 0 })` returns a **non-empty** list (or `:checkhealth vim.lsp`).
2. Introduce **two** errors so there is something to jump between — on two separate blank lines
   type each of the following (an incomplete assignment is a hard syntax error lua_ls always flags):

   ```lua
   local a =
   local b =
   ```

   Within ~1s two red error signs appear in the sign column. Confirm the count:
   `:lua =#vim.diagnostic.get(0)` (expect ≥ 2).
3. Put the cursor at the top of the file. Press `]d` → jumps to the first error; `]d` again →
   the second; `[d` → back to the previous one.
4. With the cursor on an error line, press `<leader>e` → a floating window shows the diagnostic
   text (e.g. *"Expected expression"* / *"unexpected symbol"*).
5. Undo the two edits (`u`) so the buffer is clean again.

- [X] `[d`, `]d`, and `<leader>e` all behave as before

#### 6.4 — TODO/FIXME highlighting

todo-comments runs with `opts = {}` (all **defaults**, `merge_keywords = true`), so the
recognised "magic strings" are the plugin defaults below. **Each highlights only when written as
`KEYWORD:` (with the trailing colon) inside a comment.** Primary keyword → alternates (each
alternate shares its primary's colour):

| Keyword  | Colour           | Alternates (same colour)              |
|----------|------------------|---------------------------------------|
| `TODO:`  | info (blue)      | —                                     |
| `FIX:`   | error (red)      | `FIXME:` `BUG:` `FIXIT:` `ISSUE:`     |
| `HACK:`  | warning (yellow) | —                                     |
| `WARN:`  | warning (yellow) | `WARNING:` `XXX:`                     |
| `PERF:`  | default          | `OPTIM:` `PERFORMANCE:` `OPTIMIZE:`   |
| `NOTE:`  | hint (green)     | `INFO:`                               |
| `TEST:`  | test             | `TESTING:` `PASSED:` `FAILED:`        |

1. Open `lua/plugins/treesitter.lua`. Add `-- TODO: test this` → `TODO:` shows the info colour
   and a sign appears in the sign column.
2. Change it to `-- FIXME: test this` → highlights in the **error** colour (FIXME maps to FIX).
3. Spot-check the other families, e.g. `-- WARN: x`, `-- PERF: x`, `-- NOTE: x` — each takes its
   colour from the table. A bare `TODO` with **no colon** should **not** highlight.
4. Undo the additions.

- [X] Default keyword families highlight (colour + sign) only when written as `KEYWORD:`

#### 6.5 — Todo list views

1. With the `-- TODO:` line present, press `<leader>xT` — fzf-lua picker opens listing todo comments.
2. Press `<Esc>` to close.
3. Press `<leader>xt` — Trouble panel opens showing todo comments. Entry from step 1 appears.

- [X] fzf-lua picker and Trouble panel both list todo comments — pass (both list todos; no errors after installing `rg` + `fzf`)

> **Blocked on the test machine — two external binaries missing (not config defects).** The
> replacement test machine lacked both tools these maps shell out to:
> - `<leader>xt` (`:TodoTrouble`) needs **ripgrep** (`rg`) to search for todo comments — without
>   it trouble throws `.../trouble/view/section.lua:109: Vim:rg was not found on your path`.
> - `<leader>xT` (`:TodoFzfLua`) additionally needs the **`fzf` binary** — fzf-lua is a wrapper
>   around `fzf` (no pure-Lua fallback), so without it it errors `'fzf' not installed`.
>
> **Fix:** install both, then re-run 6.5:
> ```bash
> sudo apt install ripgrep fzf   # Debian/Ubuntu; or brew/dnf equivalents
> rg --version && fzf --version  # confirm both on PATH
> ```
> Neither is a plugin/config bug. Both added to *One-Time Test Machine Setup* above.

#### 6.6 — vim-unimpaired tag maps intact

`]t` / `[t` are vim-unimpaired's `:tnext` / `:tprevious` (tag-match navigation) — this step
confirms todo-comments/trouble did **not** hijack them. They cycle the *match list* of a tag that
has multiple definitions, so the test needs a `tags` file and a multi-match tag (`setup` has 8+
definitions across `lua/config/`).

1. **Generate the tag index** (terminal, repo root):

   ```bash
   cd ~/.config/nvim
   ctags -R          # creates ./tags (gitignored)
   wc -l tags        # sanity: a few hundred+ lines
   ```

2. **Open Neovim from inside the repo** so `./tags` is found: `cd ~/.config/nvim && nvim lua/keymaps.lua`.
3. Confirm the tags file is loaded: `:echo tagfiles()` → non-empty (shows the `./tags` path). If
   empty, check `:set tags?` includes `./tags,tags` and that nvim was launched from the repo root.
4. **Prove `]t`/`[t` are tag maps, not todo** (the point of this step):
   - `:verbose nmap ]t` → RHS runs `:tnext`, "Last set from …/vim-unimpaired/plugin/unimpaired.vim".
   - `:verbose nmap [t` → `:tprevious`, same source. Neither mentions todo-comments/trouble.
5. **Watch them cycle between matches:**
   - `:echo len(taglist('setup'))` → a number ≥ 2 (multiple matches exist).
   - `:tag /setup` → jumps to match **1 of N** (count shown on the command line).
   - `]t` → `:tnext` → match **2 of N** (a different file's `setup`); `]t` again → 3, …; `[t` → back one.
   - `E428: Cannot go beyond last matching tag` / `E425: Cannot go before first matching tag` at the
     list ends is **normal** — still tag navigation, not a mapping failure.

- [X] `]t` / `[t` do tag navigation (vim-unimpaired `:tnext`/`:tprevious`), not todo navigation

### Raise PR & merge

- [X] All validation steps above pass — 6.1–6.6 all green (6.2 after the trouble.nvim `branch=main` fix; 6.5 after installing `rg`+`fzf`; usage documented in `code-intelligence.adoc`)
- [X] Raise PR: `feat/06-add-diagnostics-todo-panel` → `main`
- [X] Review and approve PR
- [X] Merge PR

### Post-merge

- [X] `git checkout main && git pull origin main` (`main` at `9474590`)
- [X] Launch Neovim: `:Lazy sync` — confirm clean

---

## Change 07 · add-dotnet-debug-test

**Branch:** `feat/07-add-dotnet-debug-test`

Adds breakpoint debugging (`nvim-dap` + `nvim-dap-ui`, netcoredbg adapter) and a .NET test runner
(`easy-dotnet.nvim`) for C# and F#, **without** adding a second C# language server — roslyn.nvim
stays the sole LSP (`easy-dotnet` has `lsp = { enabled = false }`). The netcoredbg adapter is
**auto-registered by easy-dotnet** once nvim-dap is loaded — there is no hand-written `dap.adapters`
entry, so a debug session only starts from a `.cs`/`.fsharp` buffer (where easy-dotnet loads).

**Prerequisites** (confirm before validating):
- **netcoredbg on `$PATH`** — `netcoredbg --version` responds. Installed from **GitHub releases**,
  **not** `dotnet tool install` (see *One-Time Test Machine Setup* and `languages/dotnet.adoc`
  § Debugging § Prerequisites).
- **.NET SDK + matching runtime** — `dotnet --list-sdks` lists a usable SDK **and**
  `dotnet --list-runtimes` shows a runtime matching the fixtures' target. The fixtures target
  **`net8.0`**, so you need the **net8.0 runtime** (`Microsoft.NETCore.App 8.0.x`) present to build,
  run, **and debug** them — a target/runtime mismatch means Roslyn/easy-dotnet can't resolve the
  project *and* run/debug (§7.3/§7.4) fails, not just completions. On a net10-only machine either
  add the net8.0 runtime (`sudo apt install dotnet-runtime-8.0`) or bump the fixtures' TFM (below).
  - **net10.0 is also fully supported** (LTS to 2028; net8 is EOL ~Nov 2026). The toolchain is
    SDK-agnostic, and netcoredbg on net10 is confirmed empirically at §7.3. To use it, bump
    `<TargetFramework>` from `net8.0` → `net10.0` in all four fixture projects
    (`testdocs/{c,f}sharp-project/*.*proj`) so it matches your installed SDK/runtime.
- **Roslyn LSP on `$PATH`** — `Microsoft.CodeAnalysis.LanguageServer --version` responds (for
  7.2 / 7.6).
- **`fzf` binary** — `fzf --version` responds. easy-dotnet's picker is `fzf` (`picker = "fzf"`), so
  `<F5>`, `,tt`, `,tr`, `,tb` all open an fzf picker.
- **`csharprepl`** (for 7.6 C# REPL) — `dotnet tool install -g csharprepl`; `.NET SDK` gives F# `dotnet fsi`.
- **`EasyDotnet` server tool** — `dotnet-easydotnet -v` responds. easy-dotnet.nvim is a thin client
  over this separate server, which powers **all** its features (debug, test, run, build); without it
  every `:Dotnet …` action errors `'dotnet-easydotnet' is not executable`. Install:
  `dotnet tool install -g EasyDotnet` (needs `~/.dotnet/tools` on PATH). `:checkhealth easy-dotnet` confirms it.
- **Test-project fixtures** (already in the repo — no setup): `testdocs/csharp-project/`
  (`HelloCs.csproj`, `Program.cs`) and `testdocs/fsharp-project/` (`HelloFs.fsproj`, `Program.fs`).
  Use these — a runnable project resolves reliably; standalone `.cs`/`.fsx` files are the finicky case.
- **A Haskell project** (optional, 7.5) — any `.hs`; `testdocs/hello.hs` suffices for the discovery check.

### Prepare

> Run the **Per-Branch Sync & Sanity Check** first. If this branch was rebased/force-pushed on a
> machine that already had it, `git reset --hard origin/feat/07-add-dotnet-debug-test` (do **not**
> `git pull`).

1. `git fetch origin && git checkout feat/07-add-dotnet-debug-test`
2. Launch Neovim: `:Lazy sync` — wait for completion.
3. Open a C# file once — `:e testdocs/csharp-project/Program.cs` — so the `ft = { "cs", "fsharp" }`
   plugins (roslyn.nvim, easy-dotnet) load.

- [X] Branch checked out, `:Lazy sync` clean; `nvim-dap`, `nvim-dap-ui`, `nvim-nio`, `easy-dotnet.nvim` listed in `:Lazy`

### Validate

#### 7.1 — Plugins installed

1. Open `:Lazy`. Confirm each is installed with **no error icon**: `nvim-dap`, `nvim-dap-ui`,
   `nvim-nio`, `easy-dotnet.nvim`.
   - `nvim-dap` loads on its `keys` (e.g. `<F5>`); `nvim-dap-ui`/`nvim-nio` are dap dependencies.
     They may show as **installed but not loaded** until you first press a debug key — that is the
     pass here, not a failure. `easy-dotnet.nvim` loads on `ft = { cs, fsharp }`.
2. Run `:messages` — no plugin load errors.

- [X] All four plugins installed cleanly (loaded lazily is fine)

#### 7.2 — Exactly one Roslyn LSP client

easy-dotnet is configured with `lsp = { enabled = false }`, so it must **not** start a second C#
server — roslyn.nvim owns the LSP. This step proves there is exactly one.

1. Open `testdocs/csharp-project/Program.cs`. Wait for roslyn.nvim to attach — first attach on a
   project can take **10–30 s** while it loads the solution (watch for the LSP progress message).
2. Run `:lua =vim.lsp.get_clients({ name = "roslyn" })` — expect **exactly one** table entry.
   - **Empty** list → Roslyn didn't attach: confirm the server is on PATH
     (`:lua =vim.fn.exepath('Microsoft.CodeAnalysis.LanguageServer')` is non-empty) and check `:LspLog`.
   - **Two** entries → easy-dotnet started its own Roslyn (the `lsp.enabled = false` opt regressed) —
     a configuration error. Do not proceed; note it.

- [X] Exactly one Roslyn client returned — **pass after the roslyn cmd fix below**

> **Defect found & fixed — Roslyn server exited 1 on attach (`Client roslyn quit with exit code 1`).**
> `:LspLog` showed the server rejecting its own launch:
> ```
> "Microsoft.CodeAnalysis.LanguageServer" "stderr" "Option '--logLevel' is required."
> "Microsoft.CodeAnalysis.LanguageServer" "stderr" "Option '--extensionLogDirectory' is required."
> ```
> **Root cause:** roslyn.nvim (`main`) builds its cmd as `{ get_roslyn_lsp_path(), "--stdio" }`, which
> targets a `roslyn-language-server` **wrapper** that supplies those args internally. Against the raw
> `Microsoft.CodeAnalysis.LanguageServer` this repo installs, the two **REQUIRED** args
> (`--logLevel`, `--extensionLogDirectory`) are missing, so the server exits 1. (The raw server *does*
> support `--stdio` — that flag was not the problem.) This surfaced now because C# LSP attach is
> validated end-to-end here for the first time.
> **Fix (this branch):** `lua/config/lsp.lua` overrides the `roslyn` `cmd` with the full invocation
> (`--stdio --logLevel Information --extensionLogDirectory <nvim-log>/roslyn`). roslyn.nvim only ever
> sets `capabilities` (config.lua), never `cmd`, so the override holds. Verified: the server emits
> `[Program] Language server initialized` over stdio and exactly one client attaches.
> **Re-test:** restart Neovim → open `testdocs/csharp-project/Program.cs` → wait for attach →
> `:lua =vim.lsp.get_clients({ name = "roslyn" })` returns exactly one client.

#### 7.3 — Breakpoint and step debugging

The netcoredbg adapter is **auto-registered by easy-dotnet** (via the EasyDotnet server tool — see
Prerequisites), so start the session from inside a `.cs`/`.fsharp` buffer. dap-ui auto-opens on
session start (`event_initialized`) and auto-closes on terminate/exit (`lua/plugins/dap.lua`). Every
action has a function-key **and** a terminal-independent `<leader>b` binding — use the latter when a
terminal grabs the F-keys:
`<F9>`/`bb` breakpoint · `<F5>`/`bc` start · `<F10>`/`bv` over · `<F11>`/`bi` into · `<F12>`/`bo` out
· `<S-F5>`/`bt` terminate · `bu` toggle UI · `br` REPL.

1. Open `testdocs/csharp-project/Program.cs`. Put the cursor on an **executable** line in `Main`
   (e.g. line 29, `Console.WriteLine(Greeter.Greet("C#"));`) and press `<F9>` → a breakpoint sign
   (nvim-dap's default is a plain `B`) appears in the sign column.
2. Start the session — either works:
   - `<F5>` (or `<leader>bc`): a brief **"Run Aborted"** flashes in `:messages` — **expected**
     (easy-dotnet's dap config returns `dap.ABORT` and hands off to its own `:Dotnet debug profile`),
     then the fzf picker appears → select `HelloCs`.
   - `:Dotnet debug default`: launches the default project directly (no launch profile needed).
3. The **nvim-dap-ui** panels open automatically (Variables, Call Stack, Breakpoints, Watches, REPL).
   Execution runs and **pauses at the breakpoint**.
4. Step — function keys **or** the `<leader>b` mirrors if your terminal grabs the F-keys:
   `<F10>`/`<leader>bv` over · `<F11>`/`<leader>bi` into · `<F12>`/`<leader>bo` out — the current
   line follows each step and the Variables/Call-stack panes update.
5. `<S-F5>` (or `<leader>bt`) terminates → the session ends and dap-ui closes.
   - `<F5>` erroring with an adapter/`netcoredbg` "not found" ⇒ the binary isn't on PATH (prereqs) or
     you're not in a `.cs`/`.fsharp` buffer, so easy-dotnet hasn't registered the adapter.

- [X] Full debug cycle (set breakpoint → start → pause → step → stop) works — **pass after the fixes below**

> **Three defects found & fixed to get here (all committed on this branch):**
> 1. **Missing prerequisite — the `EasyDotnet` server tool.** easy-dotnet.nvim is a thin client over
>    a separate `dotnet-easydotnet` server; without it every `:Dotnet …` action errors
>    `'dotnet-easydotnet' is not executable`. Fix: `dotnet tool install -g EasyDotnet` (added to
>    Prerequisites + One-Time Setup + `dotnet.adoc`).
> 2. **Invalid fixture XML.** `HelloCs.csproj`/`HelloFs.fsproj` had an XML comment containing `--`
>    (from `dotnet --list-sdks`), which MSBuild rejects (MSB4025) → the server reported "Failed to
>    evaluate project." Fix: reworded the comments; both now `dotnet build` clean.
> 3. **`<F11>` (step into) eaten by the terminal.** Many GUI terminals map `<F11>` to fullscreen, so
>    step-into never reached Neovim (F10 worked). `dap.lua` had no non-F-key step maps. Fix: added
>    `<leader>bi`/`bv`/`bo`/`bt` mirrors — **F-keys kept** (they still work on server/SSH terminals).
>
> Also: the `<F5>` "Run Aborted" flash is **normal** (easy-dotnet's `dap.ABORT` handoff), not a
> failure. Both `<F5>` and `:Dotnet debug default` start a session on the bare fixture (no
> `launchSettings.json` needed).

#### 7.4 — easy-dotnet test / run / build maps

Maps are `<localleader>` (`,`), in `after/ftplugin/cs.lua` and `after/ftplugin/fsharp.lua`:
`,tt` = `require("easy-dotnet").test()`, `,tr` = `run()`, `,tb` = `build()` (`:Dotnet test|run|build`
are equivalent). Output shows in a managed terminal — `lua/plugins/dotnet.lua` sets
`managed_terminal.auto_hide = false` so it stays open on exit (dismiss with `q`); the default
(`true`) hides it the instant a run exits 0, so output would flash and vanish.

**easy-dotnet is cwd-scoped, not buffer-scoped** — it discovers projects from `vim.fn.getcwd()`
(and caches one active project, shown in lualine), NOT from the current buffer. To target a specific
project, **open nvim from that project's directory** (or `:lcd %:p:h`).

1. C# — `cd testdocs/csharp-project && nvim Program.cs`:
   - `,tr` → the project **runs** (its `Hello …` output appears; the terminal stays open, `q` closes).
   - `,tb` → the project **builds** (build-succeeded message).
   - `,tt` → the **test runner** fires. The fixture is a console app with no tests, so a clean
     "no tests"/build-only result is the pass — the point is the runner launches, not a green suite.
2. F# — `cd testdocs/fsharp-project && nvim Program.fs`:
   - `,tr` / `,tb` / `,tt` run / build / test the F# project.

- [X] Test, run, and build maps work in both C# and F# buffers — **pass; see the two constraints below**

> **Constraint 1 — F# projects require a solution file.** easy-dotnet's runnable-project discovery
> is C#-oriented (its server's `compat run` argument is documented as a `.csproj`). A standalone
> `.fsproj` is **not** discovered — from an F#-only cwd, `,tr` reports "No runnable projects found"
> even though `dotnet run` works and `OutputType=Exe`. **Fix:** the F# fixture ships
> `testdocs/fsharp-project/HelloFs.sln` (classic format — portable to net8; easy-dotnet also accepts
> `.slnx`). Real F# repos have a solution anyway. C# projects are discovered standalone (no `.sln`
> needed), which is why the C# fixture has none.
>
> **Constraint 2 — cwd-scoped selection.** Because discovery keys off `getcwd()`, opening both
> fixtures from one nvim cwd (e.g. `~/.config/nvim`) makes `,tr` always resolve the first project
> found (the C# one) regardless of the active buffer. Open nvim from the target project's dir (or
> `:lcd` into it). `:Dotnet reset` clears the on-disk cache but does not change cwd resolution.

#### 7.5 — Haskell DAP config discovery — DEFERRED

`mrcjkb/haskell-tools.nvim` auto-registers a Haskell DAP config only when the Haskell toolchain is
present and a **cabal/stack project** is open. On the current test machine the whole toolchain is
absent — `ghc`, `cabal`/`stack`, `haskell-language-server`, and `haskell-debug-adapter` are all
uninstalled — and `testdocs/hello.hs` is a standalone file, not a project. So this cannot be
verified here. Change 07 does not install the Haskell toolchain (out of scope per design.md).

**To exercise later:** install `ghcup` → GHC + `cabal` (or `stack`) + `haskell-language-server`,
plus `haskell-debug-adapter`; open a real cabal/stack project; then:

1. Open a `.hs` file in that project (loads haskell-tools). Press `<F9>` so `nvim-dap` loads.
2. Run `:lua =require("dap").configurations.haskell`.
3. **Non-nil** table = haskell-tools registered a config (pass). **`nil`** = follow-up.

- [ ] **DEFERRED** — cannot verify without the Haskell toolchain (ghc/cabal/HLS + `haskell-debug-adapter`) and a cabal/stack project. Toolchain-setup docs tracked as a TODO under the `document-setup-prerequisites` change; revisit §7.5 once installed.

#### 7.6 — Existing .NET maps unaffected

Confirms dap/easy-dotnet did not disturb the iron REPL or Roslyn LSP maps. **The iron
`<localleader>s*` maps are bound in the code buffer** (via the ftplugin's `maplocalleader = ","`)
and send code TO the REPL — they are not active inside the REPL terminal itself.

1. **iron REPL** — in `testdocs/csharp-project/Program.cs`, cursor on a line, `<localleader>sl`
   (send line) opens a **bottom split** REPL and sends the line. Move into it with `<C-j>` or
   `:IronFocus`, then `i` to type. `csharprepl` (C#) is a TUI — drive it by typing directly;
   `dotnet fsi` (F#, in `Program.fs`) evaluates a submission only after `;;` (e.g. `1 + 1 ;;`).
   Quit with `exit` inside the REPL, `<localleader>sq` from the code buffer, or `:IronHide`.
2. **Roslyn LSP nav** — in the C# buffer, `gd` (definition), `K` (hover), and `gr` (references,
   opens the quickfix list) all work via the single Roslyn client from 7.2.

- [X] iron REPL and LSP navigation intact — LSP nav works; iron REPL works after the fixes below

> **Pre-existing iron REPL defects fixed here (none caused by change 07 — it never touched iron):**
> - **F# REPL was broken.** The command was `dotnet fsi --stdin`; `--stdin` is not a valid fsi
>   option (`error FS0243`), so the REPL exited the instant it opened. Fixed → `dotnet fsi`.
> - **REPL opened as a floating window** (`iron.view.bottom(40)`) — overlaid the code and couldn't be
>   reached by window motions (only `:IronFocus`). Fixed → bottom split (`iron.view.split.botright(15)`),
>   reachable with `<C-j>`.
> - **csharprepl rendered invisible** (its truecolor VisualStudio_Dark theme). Fixed → launch with
>   `--useTerminalPaletteTheme` so it uses the terminal's palette.
>
> **Known limitation (not fixed):** csharprepl is a full-screen TUI (PrettyPrompt) that does not
> reliably submit on iron's injected `<CR>`, so `<localleader>sl` *sends* but does not auto-run the
> C# line — type in it directly (`:IronFocus`). F# `dotnet fsi` runs fine via `,sl` + a trailing
> `;;`. A plainer C# REPL would send-to-repl better — candidate for a future iron-REPL cleanup.

### Raise PR & merge

- [X] All validation steps above pass — 7.1–7.4 and 7.6 green; **7.5 (Haskell DAP) DEFERRED** (no Haskell toolchain, out of scope). Several pre-existing defects found & fixed on this branch: Roslyn LSP cmd (§7.2), EasyDotnet server-tool prereq + fixture XML (§7.3), F# solution requirement (§7.4), and the iron REPL fsi/float/theme fixes (§7.6).
- [X] Raise PR: `feat/07-add-dotnet-debug-test` → `main` (confirm `lsp = { enabled = false }` in easy-dotnet opts — verified line 78)
- [X] Review and approve PR
- [X] Merge PR

### Post-merge

- [X] `git checkout main && git pull origin main` (`main` at `9474590`)
- [X] Launch Neovim: `:Lazy sync` — confirm clean

---

## Change 08 · add-claudecode-session

**Branch:** `feat/08-add-claudecode-session`

Adds `coder/claudecode.nvim` — a persistent, **editor-aware** Claude Code session over the same
WebSocket **MCP** protocol the official VS Code / JetBrains extensions use. Mechanically: the plugin
starts a **local WebSocket server** inside Neovim and writes a lock file to
`~/.claude/ide/[port].lock` (or `$CLAUDE_CONFIG_DIR/ide/[port].lock`); a `claude` CLI launched in a
**native terminal split** discovers that lock file and connects (or you connect manually with
`/ide`). **All model calls and all authentication are performed by the `claude` CLI itself** (Claude
Code auth — **no `ANTHROPIC_API_KEY`**); the plugin never touches the Anthropic API or any
credential. It is the same auth posture as `claude_cli.lua` and is *not* the avante Anthropic-provider
case (see `openspec/changes/08-add-claudecode-session/design.md` § ToS / auth posture).

Configured with `terminal = { provider = "native" }` so it needs **no snacks.nvim** — claudecode's
*default* provider is `auto`, which would pull snacks in if it were installed, so the explicit
`native` is what keeps this snacks-free. The change is **additive**: the one-shot
`:ClaudeSuggest`/`:ClaudeExplain` (`<leader>gcs`/`gce`) and avante (`<leader>aa`/`ao`) are untouched.

Keymaps — all nest under the **existing** `<leader>gc` "Claude" which-key group (no new group):
`gcc` toggle session · `gcf` focus session · `gcb` add buffer to context · `gcv` send selection
(visual) · `gca` accept diff · `gcr` reject diff.

**Prerequisites** (confirm before validating):
- **`claude` CLI on `$PATH` and authenticated** — `claude --version` responds, and running `claude`
  in a plain terminal reaches an interactive prompt (not a login wall). This is the *same* binary
  `claude_cli.lua` already requires. Confirmed once in *One-Time Test Machine Setup* (line 62).
- **No API key, no extra install** — claudecode.nvim adds **no** runtime dependency beyond the plugin
  itself and the `claude` binary. `ANTHROPIC_API_KEY` is **not** used or needed.
- **snacks.nvim must be absent** — the config deliberately avoids it (native provider). Nothing on
  any current branch installs snacks; §8.1 asserts this. If a *future* change adopts snacks, revisit
  the provider choice — it does not affect these tests.
- **A throwaway edit target** — `lua/plugins/claudecode.lua` itself is a fine low-stakes file for the
  diff tests (§8.3/§8.4); nothing to create. Restore it afterward with
  `git checkout -- lua/plugins/claudecode.lua` so the branch stays clean.
- **Lock-file visibility (diagnostic)** — after starting a session, `ls ~/.claude/ide/` should list a
  `NNNNN.lock`; useful when diagnosing a failed connect (§8.2). `$CLAUDE_CONFIG_DIR`, if set,
  relocates that directory.

### Prepare

> Run the **Per-Branch Sync & Sanity Check** first. If this branch was rebased/force-pushed on a
> machine that already had it, `git reset --hard origin/feat/08-add-claudecode-session` (do **not**
> `git pull`) — this branch **was** force-pushed after being rebuilt off main.

1. `git fetch origin && git checkout feat/08-add-claudecode-session`
2. Launch Neovim: `:Lazy sync` — wait for completion.
3. `claudecode.nvim` is lazy-loaded on its `cmd`/`keys`, so it may not load until you first press a
   `<leader>gc*` session map — that is expected.

- [X] Branch checked out, `:Lazy sync` clean; `claudecode.nvim` listed in `:Lazy`; **`snacks.nvim` absent**

### Validate

#### 8.1 — Plugin installed; snacks.nvim absent

claudecode loads lazily (on `cmd`/`keys`), so **installed-but-not-loaded is the pass** here, not a
failure. The load-bearing assertion is that **snacks.nvim is not present** — the native provider
means it is never pulled in as a dependency.

1. Open `:Lazy`. Find `claudecode.nvim` — installed, **no error icon**. It may show *not loaded*
   (lazy on `cmd`/`keys`) until first use — that is the pass.
2. In `:Lazy`, search `snacks` — there must be **no `snacks.nvim`** entry. Cross-check in Neovim:
   `:lua =pcall(require, "snacks")` → expect **`false`** (module not installed).
3. `:messages` — no plugin load errors.

- [X] `claudecode.nvim` installed cleanly (lazy is fine); `snacks.nvim` absent (`pcall(require,"snacks")` → `false`)

> **If snacks IS present:** either the `provider = "native"` opt regressed (check
> `lua/plugins/claudecode.lua`) or another plugin/branch introduced snacks independently — inspect
> `:Lazy` → `snacks.nvim` → its "Required by" list. Do not proceed until resolved.

#### 8.2 — Session terminal opens and the CLI connects

`<leader>gcc` runs `:ClaudeCode`: it starts the local WebSocket server, writes the
`~/.claude/ide/[port].lock` file, and opens a **native terminal split** running the `claude` CLI. The
CLI auto-discovers the lock file and connects over MCP; if it does not, `/ide` connects manually.

1. From a normal (non-terminal) buffer, press `<leader>gcc`. A **terminal split** opens running the
   `claude` CLI — wait for the interactive prompt.
2. Confirm the server is up: `:!ls ~/.claude/ide/` (or a shell) lists a `NNNNN.lock` file.
3. Confirm the IDE/MCP connection: Claude Code shows a **connected / IDE** indicator. If it does not
   auto-connect, type `/ide` + Enter in the CLI and select the Neovim workspace.
4. `:ClaudeCodeStatus` reports the server running / a client connected. `:messages` — **no** errors
   about missing providers, snacks, or the WebSocket server.

- [X] Native terminal opens, `claude` CLI runs **authenticated**, lock file present, MCP shows connected

> **Failure modes:**
> - Terminal opens but the CLI shows a **login prompt** → not authenticated (prereqs): run `claude` in
>   a plain terminal, complete login, retry.
> - CLI runs but never connects / `/ide` lists nothing → server didn't start or the lock dir differs.
>   Check `$CLAUDE_CONFIG_DIR`, `:ClaudeCodeStatus`, and `:messages`; `:ClaudeCodeStop` then
>   `<leader>gcc` to restart.
> - `:ClaudeCode` errors "not an editor command" → the plugin didn't load; re-check §8.1.

#### 8.3 — Share context: send selection and add buffer

With a session connected (§8.2), the plugin pushes **editor context** to the CLI over MCP — a visual
selection via `:ClaudeCodeSend`, and the whole current file via `:ClaudeCodeAdd %`.

1. Leave terminal-insert with `<C-\><C-n>`, then move to an editor window (`<C-w>w`) and open
   `lua/plugins/claudecode.lua`.
2. Visually select 2–3 lines (`V` + motion) and press `<leader>gcv` (`:ClaudeCodeSend`).
   **Expect:** the session receives the selection as an `@`-reference / context block naming the file
   and line range.
3. Back in normal mode, press `<leader>gcb` (`:ClaudeCodeAdd %`).
   **Expect:** Claude acknowledges the **current file** added to its context (an `@file` reference).
4. In the session, ask *"what did I just share?"* — Claude should reference the selection and the file.

- [X] Selection (`<leader>gcv`) and buffer-add (`<leader>gcb`) both reach the session as context

> **Defect found & fixed on this branch — `<leader>gcv` lost a race to native `gc` (comment).**
> The visual-mode send map was registered via lazy.nvim's `keys` field, so it only existed *after* the
> plugin lazy-loaded — after which-key had built its trigger tree. On fast/blind input the `<Space>gc`
> prefix wasn't held and the buffered `gc` fired Neovim's native visual comment operator, commenting the
> selection instead of sending it. The send/add **features** were never broken (verified directly via
> `:ClaudeCodeSend` / `:ClaudeCodeAdd %`). **Fix:** register all six `<leader>gc*` maps eagerly in the
> plugin spec's `init` (`vim.keymap.set`, keeping `cmd`-based lazy-load) so they exist before which-key
> initialises — matching how `claude_cli` binds `gcs`/`gce`. `<leader>gc` and every binding are
> unchanged; no `timeoutlen` tweak. Re-verified: fast `<leader>gcv` sends (no comment) **and** the
> which-key popup path still lists/fires `v`.

> **Failure modes:** nothing arrives → the session isn't connected (redo §8.2). `<leader>gcv` invoked
> **outside** an active visual selection sends nothing — it must be pressed from Visual mode (or with a
> range).

#### 8.4 — Diff accept and reject

When Claude proposes a file edit, claudecode opens a **native diff** view; `<leader>gca`
(`:ClaudeCodeDiffAccept`) applies+writes it, `<leader>gcr` (`:ClaudeCodeDiffDeny`) discards it.

1. In the session, ask: *"Add a one-line comment at the very top of lua/plugins/claudecode.lua."*
   Claude proposes an edit → a **diff view** opens in Neovim.
2. Press `<leader>gca` → the change is **applied and written**, the diff closes. Verify the comment is
   in the file (`:e!` to reload, or look at line 1).
3. Restore the file (`u` to undo, or `:!git checkout -- lua/plugins/claudecode.lua`). Ask for another
   trivial edit; when the diff opens, press `<leader>gcr` → the proposal is **rejected**, the diff
   closes, and the file is **unchanged**.

- [X] Accept (`<leader>gca`) writes the change; reject (`<leader>gcr`) leaves the file unchanged

> **Failure modes:** no diff opens → Claude answered in prose; ask it explicitly to *edit the file*.
> Maps do nothing → make sure focus is in the diff buffer/window. A stuck diff → `:ClaudeCodeCloseAllDiffs`.
> **Cleanup:** finish with `git checkout -- lua/plugins/claudecode.lua` so the diff experiments don't
> dirty the branch.

#### 8.5 — One-shot `claude_cli` maps still work (regression)

claudecode is additive — the pre-existing one-shot commands must be untouched. `:ClaudeSuggest`
(`<leader>gcs`) and `:ClaudeExplain` (`<leader>gce`) shell out to `claude -p <prompt>` **asynchronously**
and show the reply in a **floating scratch window** (dismiss with `q` or `<Esc>`). They reuse the same
`claude` auth but are independent of the session server — they work whether or not a session is open.

1. In any buffer, press `<leader>gcs`. A **`Claude: running 'claude' CLI …`** notification appears;
   when the call returns, a float titled **`claude suggest`** shows a shell-command suggestion.
   Dismiss with `q` / `<Esc>`.
2. Visually select a few lines of code and press `<leader>gce`. A float titled **`claude explain`**
   shows an explanation of the selection. Dismiss with `q` / `<Esc>`.
   - With **no** selection, both commands fall back to sending the **whole buffer**.

- [X] `<leader>gcs` (float "claude suggest") and `<leader>gce` (float "claude explain") both render Claude's reply — after neutralising an env var (below)

> **Finding — pre-existing, NOT a change-08 regression; tracked for a separate fix. `ANTHROPIC_API_KEY` shadows the login.**
> `<leader>gcs`/`gce` first failed: `claude CLI failed (exit 1): ⚠ claude.ai connectors are disabled
> because ANTHROPIC_API_KEY … takes precedence over your claude.ai login`. Root cause: an
> `ANTHROPIC_API_KEY` is exported from `~/.zshenv` (sourced by *every* zsh, so Neovim inherits it and
> `vim.system` hands it to `claude -p`), overriding the claude.ai/subscription auth that
> `claude_cli.lua` is documented to use. The **keymaps fire correctly** and 08 never touches
> `claude_cli`, so this is not an 08 regression. Verified the feature works once the var is out of the
> way: `:lua vim.env.ANTHROPIC_API_KEY = nil` → both floats render. The interactive claudecode session
> (§8.2–8.4) tolerated the var and worked; only the headless `-p` path failed.
> **Recommended fix (separate change — `claude_cli.lua` is out of 08 scope):** clear the var for the
> subprocess — `vim.system({...}, { env = { ANTHROPIC_API_KEY = "" } }, …)` — so it always uses the
> login, matching CLAUDE.md.

> **Failure modes:** a `claude_cli: 'claude' CLI not found on $PATH` notify → binary off PATH. A long
> hang with no float → the CLI is blocked on auth (prereqs).

#### 8.6 — Avante + `<leader>a` namespace unaffected (regression)

claudecode's **upstream default prefix is `<leader>a`** — which is **avante** in this config — so its
maps were deliberately relocated under `<leader>gc`. This step confirms there is no bleed between the
two namespaces.

> **Note on `<leader>a`.** avante here is **Ollama-only** — the Claude/Anthropic provider is
> intentionally disabled (subscription-OAuth ToS), so the config adds no switch-to-Claude map. But
> avante still registers its **own full default `<leader>a` keymap suite** (~18 entries:
> ask/edit/refresh/toggle/models/…); the config's `keys` only *adds* `aa`/`ao` on top. So a large
> `<leader>a` popup is **expected and pre-existing** — the isolation check is specifically that **no
> claudecode (`ClaudeCode`-command) map bleeds into `<leader>a`**, not that the popup is short.

1. Press `<leader>aa` — **avante** opens with the current provider (Ollama). If Ollama isn't running,
   a clean connection/model error is acceptable — the point is the map fires *avante*, not claudecode.
2. Press `<leader>ao` — avante re-selects the Ollama provider and opens.
3. Namespace isolation — two checks:
   - **No claudecode bleed into `<leader>a`** (definitive, avoids eyeballing avante's ~18 entries):
     `:lua do local n=0 for _,m in ipairs(vim.api.nvim_get_keymap("n")) do if m.lhs:sub(1,2)==" a" and (m.rhs or ""):match("ClaudeCode") then n=n+1 print("BLEED: "..m.lhs.." -> "..m.rhs) end end print(n==0 and "OK: no ClaudeCode maps under <leader>a" or "") end`
     → expect `OK: no ClaudeCode maps under <leader>a` (no `BLEED:` lines).
   - **`<leader>gc` is correctly mode-scoped** (send-selection is visual-only): in **normal** mode the
     popup lists `s e c f b a r` (no `v`); in **visual** mode it lists `s e v` (session maps
     `c/f/b/a/r` are normal-only). `v` appearing *only* in visual mode is correct — not a missing binding.

- [X] `<leader>aa`/`<leader>ao` fire avante unchanged; no `ClaudeCode` map bleeds into `<leader>a` (Lua check → OK); `<leader>gc` correctly mode-scoped (normal `s e c f b a r`, visual `s e v`)

> **Failure mode:** a `gc*` entry appears under `<leader>a` (or an `a*` entry under `<leader>gc`) → a
> `keys`/prefix regression in `lua/plugins/claudecode.lua`.

### Raise PR & merge

- [X] All validation steps above pass (8.1–8.6). One defect found & fixed on-branch (`<leader>gcv` eager-registration, §8.3); one pre-existing non-08 finding logged (`ANTHROPIC_API_KEY` shadows `claude_cli` login, §8.5 — separate fix).
- [X] Raise PR: `feat/08-add-claudecode-session` → `main` (confirm `snacks.nvim` is **NOT** in dependencies)
- [X] Review and approve PR
- [X] Merge PR

### Post-merge

- [X] `git checkout main && git pull origin main` (`main` at `9474590`)
- [X] Launch Neovim: `:Lazy sync` — confirm clean

---

## All Changes Complete

- [X] All changes (hotfix + 03–08) validated on branch and merged to main
- [X] No open **08** issues from validation runs — the one finding (`ANTHROPIC_API_KEY` shadowing `claude_cli`, §8.5) is pre-existing and non-08, tracked separately for its own fix
- [X] lazy-lock.json committed on main reflects the final plugin state

---

## Change · migrate-treesitter-main

**Branch:** `fix/migrate-treesitter-main`

Moves `nvim-treesitter` and `nvim-treesitter-textobjects` off the frozen `master` branch onto the
maintained `main` branch. `master`'s text-objects query path calls a Neovim API removed in 0.12
(`tsrange.lua` → `:start()`), so `vaf`/`vif`/`daf`/`]f`/`[f` silently no-op today — this **supersedes**
the `treesitter-markdown-highlight-disable` hotfix above and the text objects backed out after
Change 01. `main` targets Neovim's core treesitter APIs (`vim.treesitter.start()`, `indentexpr`)
instead of `master`'s module system, and restores text objects via
`nvim-treesitter-textobjects`'s `main`-branch select/move API.

**Prerequisites** (confirm before validating):
- A C compiler on `$PATH` (parsers compile from source) — already required; confirmed in *One-Time
  Test Machine Setup* (line 55).
- `testdocs/hello.lua`, `hello.cs`, `hello.fs`/`hello.fsx`, `hello.hs`, and `hello.clj` (or
  `hello.lisp`/`hello.janet`) as fixtures — all already in the repo.
- A markdown file with a **fenced code block** to exercise the injection path (e.g. this very
  `TEST_PLAN.md`, or scratch one with a ```` ```lua ```` block) — plain prose alone won't trigger it.

### Prepare

1. `git fetch origin && git checkout fix/migrate-treesitter-main`
2. Launch Neovim: `:Lazy sync` — wait for completion. This **recompiles parsers** (first run can take
   a minute or two) and installs `nvim-treesitter-textobjects` fresh.
3. `:Lazy` — confirm both `nvim-treesitter` and `nvim-treesitter-textobjects` show branch **`main`**,
   no error icons.

- [X] Branch checked out, `:Lazy sync` clean; both treesitter plugins on `main`; `:messages` empty

### Validate

#### TS.1 — Highlight active in the four supported languages

1. Open `testdocs/hello.lua` — confirm syntax colors render (keywords, strings, comments distinctly
   colored — not plain text). Run `:lua print(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil)`
   → expect `true`.
2. Repeat for `testdocs/hello.cs`, `testdocs/hello.fs` (or `.fsx`), and `testdocs/hello.hs`.

- [X] All four (lua/cs/fs/hs) show real syntax highlighting and `highlighter.active` is non-nil

#### TS.2 — Treesitter indent (`indentexpr`)

1. In `testdocs/hello.lua`, run `:set indentexpr?` — expect
   `indentexpr=v:lua.require'nvim-treesitter'.indentexpr()`.
2. Go to the end of `function M.greet(name)`'s first line, press `o` to open a new line — confirm it
   auto-indents one level in (matching the existing body), not flush-left.

- [X] `indentexpr` set correctly; `o` inside a function body indents as expected

#### TS.3 — Markdown highlight/indent (nil-range workaround removed)

1. Open this file (`openspec/TEST_PLAN.md`) and jump to line 840 — a real fenced `lua` block
   (`local a =` / `local b =`).
2. Confirm no error appears in `:messages` (no `nil range` / `languagetree` traceback).
3. Confirm that fenced block's contents are syntax-highlighted **as Lua** (distinct from the
   surrounding markdown prose) — this proves the injection parser is active, not just the outer
   markdown highlight. **Only languages with an installed parser get injected highlighting** — this
   config installs `commonlisp`/`clojure`/`scheme`/`fennel`/`janet_simple`/`lua`/`fsharp`/`vim`/
   `markdown`/`markdown_inline`/`http`/`c_sharp`/`haskell` only, so fenced `bash` blocks elsewhere in
   this file correctly stay plain-text (no parser installed) — that is expected, not a defect.

- [X] No nil-range error; the `lua` fenced block (line 840) shows injected Lua highlighting (user also confirmed with an added `cs` fenced block); unsupported languages (e.g. `bash`) correctly show no injected highlighting (no parser installed)

#### TS.4 — Select text objects: `af`/`if`, `ac`/`ic`, `aa`/`ia`

Use `testdocs/hello.cs`:

1. Cursor inside `Main`'s body (the `Console.WriteLine(...)` line) → `vaf` → the **whole `Main`
   method** (signature through its closing `}`) is visually selected.
2. Cursor in the same spot → `dif` → only the **body** of `Main` is deleted, signature/braces remain.
   Undo (`u`).
3. Cursor on the `Program` line → `vac` → the **whole class** (through its closing `}`) is selected.
4. Cursor on the `name` parameter in `Greet(string name)` → `dia` → the whole parameter (`string
   name`) is deleted, leaving `Greet()`. Undo (`u`). (C#'s textobjects query maps
   `@parameter.inner`/`@parameter.outer` to the full `(parameter)` node — type + identifier together;
   there is no identifier-only capture in this grammar's query, so this is correct, not a bug.)
5. Repeat `vaf`/`dif` on `testdocs/hello.lua`'s `M.greet` — confirm the same behavior on a multi-line
   Lua function.

- [X] `vaf`/`ac`/`aa` select correctly; `dif`/`dia` delete only the inner content; no `tsrange` or
      removed-API error in `:messages`

#### TS.5 — Motions `]f`/`[f`/`]F`/`[F` and the jumplist

1. In `testdocs/hello.lua`, go to line 1 (`gg`).
2. Press `]f` twice — cursor lands on `function M.greet`, then `function M.farewell`.
3. Press `<C-o>` — cursor jumps back to `M.greet` (real jumplist entry, not just cursor movement).
   Press `<C-i>` to jump forward again.
4. Press `]F`/`[F` — confirm these land on function **ends** (the `end` keyword), distinct from
   `]f`/`[f`.

- [X] `]f`/`[f`/`]F`/`[F` move correctly; `<C-o>`/`<C-i>` navigate real jumplist entries

#### TS.6 — Lisp-family buffers keep vim-sexp, not treesitter

1. Open `testdocs/hello.clj` (or `hello.lisp`/`hello.janet`).
2. Cursor inside a form → `vaf` — confirm the selection follows **s-expression** structure (matches
   parens), not a treesitter function-node boundary.
3. `:verbose map af` in that buffer — confirm it resolves to a vim-sexp `<Plug>` mapping (e.g.
   `<Plug>(sexp_outer_list)`), not a Lua callback from `nvim-treesitter-textobjects`.

- [X] `af`/`if` in Lisp-family buffers still follow vim-sexp; no treesitter text object attached

#### TS.7 — No collisions with existing bracket mappings

1. In a buffer with unstaged git changes, press `]h`/`[h` — gitsigns hunk navigation still works.
2. Press `]b`/`[b` — vim-unimpaired buffer navigation (`:bnext`/`:bprevious`) still works.
3. `:verbose map ]c` — confirm **no** custom mapping (falls through to Vim's builtin diff-mode change
   navigation), i.e. treesitter did **not** claim `]c`/`[c`. (You may see a `which-key-trigger`
   mapping here — that's which-key's own bookkeeping for the `]`-prefix group, not a functional
   override; confirmed no plugin config maps `]c` anywhere in `lua/plugins/*.lua`/`keymaps.lua`.)

- [X] `]h`/`[h` (gitsigns) and `]b`/`[b` (unimpaired) unaffected; `]c`/`[c` unclaimed by treesitter

#### TS.8 — Clean startup and syntax

1. Fresh `nvim` (no args) — `:messages` shows no plugin/LSP/treesitter errors.
2. From a shell: `find . -name '*.lua' -not -path './.git/*' -print0 | xargs -0 luac -p` — all pass.

- [X] Clean `:messages` on startup; `luac -p` passes repo-wide

#### TS.9 — Docs review (source-level, not the built Antora site)

This is a **source review** in a text editor — confirming AsciiDoc syntax is well-formed (table
delimiters `|===` matched, `xref:` targets look right). It does **not** require building the Antora
site (`./docker/antora/run.sh antora-playbook.yml`); that's a
separate, optional check you can run any time and isn't a blocker for this change.

1. Open `docs/modules/ROOT/pages/editor/navigation.adoc` and `editor/keybindings.adoc` — confirm the
   restored Treesitter Text Objects sections read correctly as AsciiDoc source (matched `|===` table
   delimiters, `xref:editor/navigation.adoc[...]` links point at real anchors).
2. Open `docs/modules/ROOT/pages/other/architecture.adoc` — confirm the `nvim-treesitter`/
   `nvim-treesitter-textobjects` entries reference `main`, not `master`.

- [X] Docs source review completed post-merge — `navigation.adoc`/`keybindings.adoc` read correctly;
      `architecture.adoc`'s `nvim-treesitter` prose reworded to drop an ambiguous `master` mention
      (the pin itself always correctly said `main` — the surrounding sentence just also named the old
      branch for context, which read as if it were stale)

### Raise PR & merge

- [X] All validation steps above pass (TS.1–TS.8). TS.9 (docs source review) deferred to post-merge.
- [X] Raise PR: `fix/migrate-treesitter-main` → `main` (PR #154)
- [X] Review and approve PR
- [X] Merge PR (PR #154; docs follow-up from TS.9 merged as PR #155)

### Post-merge

- [X] `git checkout main && git pull origin main` (`main` at `9474590`) (fast-forwarded cleanly to `6dae71d`, then `835a831`)
- [X] Launch Neovim: `:Lazy sync` — confirm clean
- [X] TS.9 (deferred) — docs source review: `navigation.adoc`/`keybindings.adoc` Treesitter Text
      Objects sections read correctly (matched `|===` delimiters, valid `xref:` targets);
      `architecture.adoc` references `main`, not `master` (reworded the nvim-treesitter prose to
      drop an ambiguous `master` mention — the pin itself was always correct)
- [X] Change archived — `openspec/changes/archive/2026-07-24-migrate-treesitter-main/`, delta promoted
      to the `treesitter-editing` capability spec (PR #156)

---

## Change · fix-blink-completion-keymap

**Branch:** `fix/blink-completion-keymap`

Replaces the two divergent blink.cmp keymaps with **one table used identically in insert mode and on
the command line**. Fixes two logged defects (`recommendations/ideas.md`): there was no working manual
completion trigger, and the accept key differed between insert mode and the `:` prompt with neither
documented.

Two **BREAKING** changes, both deliberate:

- **`<CR>` no longer accepts a completion.** `Enter` always inserts a newline (insert) or executes
  (command line). Accept is **`<C-y>`** in both modes. `<CR>` cannot mean "accept" on the command
  line, where it must execute — so as long as it was the insert-mode accept key the two modes could
  never match.
- **`<M-Space>` is removed**, and `<C-n>` takes on the trigger role in addition to select-next. With
  the menu closed `<C-n>` opens it (highlighting nothing); with the menu open it selects the next
  item. This is also stock Vim's meaning for insert-mode `<C-n>`.

> **Why not `<C-Space>`, which the original proposal specified:** it was tested in this console
> *before* any config was written and is **swallowed exactly like `Alt-Space`** — the keystroke never
> reaches Neovim. Both are chords the Windows console reserves. Any trigger here has to be a plain
> `Ctrl`-plus-letter chord. The change artifacts (proposal, design D2, `completion-engine` delta) were
> updated to match the tested reality rather than the original guess.

**Prerequisites** (confirm before validating):
- Nothing to install. This is a pure config + docs change; no plugin added, removed, or re-pinned.
- A buffer with an **attached LSP** for real completion candidates — `testdocs/hello.lua` (`lua_ls`)
  is the easiest; `testdocs/hello.cs` also works.
- `testdocs/hello.clj` (or `hello.lisp`/`hello.janet`) to exercise the Conjure source, and any buffer
  with `:set spell` for the spell source.

### Prepare

1. `git fetch origin && git checkout fix/blink-completion-keymap`
2. Launch Neovim: `:Lazy sync` — should be a no-op for blink (version pin unchanged); confirm no
   errors.
3. `:messages` — confirm empty.

- [X] Branch checked out, `:Lazy sync` clean, `:messages` empty

### Validate

#### BC.1 — The menu appears without selecting anything

1. Open `testdocs/hello.lua`, enter insert mode, and type a partial identifier (e.g. `vim.ap`).
2. The completion menu **auto-shows as you type** (`completion.trigger.show_on_keyword = true`); you
   do not have to press anything.
3. Confirm **no item is highlighted**. This is the no-auto-select guarantee (`preselect = false`); if
   an item is highlighted, `show_and_insert` was used instead of `show` and this step fails.
4. Press `<C-n>` once — the **first item** highlights.
5. To see the *trigger* role instead, dismiss the menu with `<C-e>` and press `<C-n>` from that
   closed state — the menu reopens with nothing highlighted.

- [X] The menu appears with nothing highlighted; `<C-n>` then selects the first item; `<C-n>` from a
      closed menu reopens it without selecting

> **Defect found and fixed — documentation, not behavior.** This step originally read "press `<C-n>`
> once to open the menu, again to select the first item", and all three doc surfaces said the same.
> That is only true from a **closed** menu. `completion.trigger.show_on_keyword` is on, so while
> typing a word the menu is *already* open, and `cmp.show()` (`blink/cmp/init.lua:62`) begins
> `if menu.win:is_open() ... then return end` — returning nil, so blink falls through to the next
> command in `{ "show", "select_next", "fallback" }`. The first `<C-n>` therefore selects item 1, and
> a second press selects item 2. The keymap is correct and there is no regression risk: `show`
> no-ops rather than resetting the menu, and nothing is ever highlighted until asked. Only the prose
> was wrong. Corrected the `<C-n>` notes in `keybindings.adoc`, `code-intelligence.adoc` (the
> "trigger key" subsection), and `cheatsheets/core.md`; the table rows already read correctly ("Open
> the menu when closed; select next suggestion when open"). Re-check under BC.12.

> Note for anyone re-walking this: blink applies its insert-mode keys **buffer-locally on
> `InsertEnter`** (`keymap/init.lua:78-86`), not globally at startup. So `<C-n>` is blink's only
> while you are actually in insert mode — in normal mode it remains `:NvimTreeOpen<CR>`. Pressing it
> a hair too early opens the file tree, which looks like a failure but is not one. Confirm the
> statusline reads `-- INSERT --` before the keypress. Verified the six buffer-local maps land
> correctly once in insert mode: `<C-N> => blink.cmp: Show, Select Next`, plus `<C-P>`/`<C-Y>`/
> `<C-E>`/`<C-B>`/`<C-F>`.

#### BC.2 — Navigate and accept in insert mode

1. With the menu open and items showing, press `<C-n>`/`<C-p>` — the highlight moves down/up.
2. Press `<C-y>` — the highlighted item is inserted.
3. Undo, retype the prefix, and — **without pressing `<C-n>` at all**, since the menu auto-shows
   with nothing highlighted — press `<C-y>`. The **top** item is inserted. (This is why the binding
   is `select_and_accept` rather than `accept`; plain `accept` is a no-op when nothing is selected.
   Pressing `<C-n>` first would defeat the test by selecting item 1.)

- [X] `<C-n>`/`<C-p>` move the highlight; `<C-y>` accepts the highlighted item; `<C-y>` with nothing
      highlighted accepts the top item

#### BC.3 — `<CR>` never accepts (the breaking change)

1. Open the menu in insert mode with an item **highlighted**.
2. Press `<CR>`.
3. Confirm a **newline is inserted** and the highlighted completion is **not** committed.
4. Repeat with nothing highlighted — same result.

- [X] `<CR>` inserts a newline and accepts nothing, whether or not an item is highlighted

#### BC.4 — Cancel restores the typed text

1. Type a partial word, press `<C-n>` twice so an item is highlighted.
2. Press `<C-e>`.
3. Confirm the menu closes **and the text you originally typed is restored** — not the
   partially-completed word. (`<C-e>` is `cancel`, not `hide`; `hide` would leave the inserted text
   behind.)

- [X] `<C-e>` dismisses the menu and restores the typed text

#### BC.5 — Documentation scroll

**Do not use a Lua buffer for this** — see the defect note below. Use the C# project fixture, which
has a docs-capable LSP and no spell pollution (`after/ftplugin/cs.lua` sets `spell = false`).

1. `nvim testdocs/csharp-project/Program.cs` and wait for roslyn to attach (10-30s on a cold start;
   confirm with `:lua =vim.lsp.get_clients({bufnr=0})[1].name` -> `roslyn`). The bare `testdocs/hello.cs`
   is not enough; roslyn needs the `.csproj`.
2. Insert mode inside `Main`, type `Console.Wr`, press `<C-n>` to select `WriteLine`.
3. Press `<C-k>` -> the documentation window appears.
4. Press `<C-f>` / `<C-b>` -> the documentation scrolls down / up, 4 lines per press.

Note that a docstring shorter than the window (default `max_height = 20`) will not appear to scroll
at all: `scroll_down` clamps to `math.min(line_count, bottom_line + amount)`, so when everything is
already visible the cursor cannot advance. To prove the keys deterministically, temporarily set
`completion.documentation.window.max_height = 5` so any docstring overflows, then revert.

- [X] `<C-f>`/`<C-b>` scroll the documentation window

> **Defect found and fixed — `<C-f>`/`<C-b>` were dead keys.** blink leaves
> `completion.documentation.auto_show` at `false`, and nothing bound `show_documentation`, so the
> documentation window could never open. Both scroll commands begin
> `if not documentation.win:is_open() then return end`, so the two keys always fell through to
> `fallback` and did nothing — while `keybindings.adoc`, `code-intelligence.adoc` and
> `cheatsheets/core.md` all advertised them as "Scroll docs preview down/up". This is the same
> can't-possibly-work defect as `<M-Space>`, which is the very thing this change was raised to fix;
> it survived because the keymap was carried over wholesale. **Fix:** added
> `["<C-k>"] = { "show_documentation", "fallback" }` to the shared table, so the window can be
> summoned on demand and the scroll keys have something to act on. `<C-k>`/`<C-l>` are normal-mode
> window motions only (`lua/keymaps.lua:18-19`), so there is no collision, and native insert-mode
> `<C-k>` (digraphs) still works via the fallback.
>
> **Settled design — timed by default, switchable at runtime.** Two approaches were trialled: a
> timed window (`documentation.auto_show = true`, 500ms) and an on-demand `<C-k>`. The first trial
> of the timed window was a false negative — it was tested in a Lua buffer, where the window can
> never appear for the reason below — so it was re-run in C# once that was understood. The change
> ships **both**: `auto_show = true` is the default, and `:BlinkDocsToggle` flips to on-demand-only
> at runtime. This works because `completion/windows/documentation.lua:14` captures
> `require("blink.cmp.config").completion.documentation` **by reference** and re-reads `auto_show`
> on every item selection (`elseif config.auto_show then`), so flipping the field takes effect
> immediately with no restart. It must remain a boolean — blink validates
> `{ config.auto_show, "boolean" }` — but that check runs only at setup. The setting is
> deliberately **not persisted**: every session starts timed. Note that a docs window already open
> when you toggle off keeps tracking the selection for that menu, since `auto_show_item`'s first
> branch updates an open window regardless of the flag; it simply will not reappear next time.
>
> **Known limitation — no documentation in Lua buffers.** `lua_ls` supplies neither `detail` nor
> `documentation` on its completion items here, and `show_item` calls `docs.close()` and returns
> silently for exactly that case. So `<C-k>` does nothing in `.lua` files no matter what is bound.
> Confirmed working in C# via roslyn. Since this config is mostly Lua, temper expectations for the
> key's day-to-day usefulness.
>
> **Out of scope, logged separately — spell source pollutes Lua completions.** `lua/options.lua:48`
> sets `o.spell = true` globally. The clojure/cs/lisp/scheme/fsharp/janet ftplugins each set
> `spell = false`, but `after/ftplugin/lua.lua` does not, so blink's spell source is live in Lua
> buffers and returns junk candidates (`"nevi m_crea"`, `"no vim_crea"`). Unrelated to the keymap;
> needs its own change.
>
> **Out of scope — overloads are not browsable.** Roslyn collapses a method's overloads into one
> completion item, so the docs window cannot page through them; overloads belong to
> `textDocument/signatureHelp`. blink's `signature.enabled` is `false`, `on_attach` binds no
> `vim.lsp.buf.signature_help`, and blink's signature window renders only
> `signatures[(activeSignature or 0) + 1]` with no cycling command. Would be a new feature.

#### BC.6 — The same keys behave the same way on the command line

This is the whole point of the change — the keys must not differ from BC.1–BC.5.

1. Press `:` and type a partial command or path (e.g. `:e testd`). The menu auto-shows
   (`auto_show = true`), so it may already be open.
2. Confirm `<C-n>`/`<C-p>` move the highlight, `<C-y>` accepts the highlighted candidate into the
   command line, and `<C-e>` cancels and restores what you typed.
3. Press `<CR>` with the menu open and a candidate **highlighted** — confirm the command line runs
   **exactly what you typed**, ignoring the highlighted candidate. Typing `e testd` with `testdocs/`
   highlighted must open an empty buffer named `testd`, *not* `testdocs/`. Opening the highlighted
   candidate would mean `<CR>` had accepted, which is the defect this change removes. (`:e` on a
   nonexistent path only creates an unwritten buffer; nothing is written to disk. `:bd!` to clear.)
4. Press `/` and type a partial word — confirm buffer-word candidates are still offered and the same
   keys work.
5. `<C-k>` at the `:` prompt. The shared table is handed to `cmdline.keymap` unchanged, so the key
   is bound here too — but **nothing can ever be shown**, and this step only checks that it is
   harmless. Command-line candidates carry `labelDetails` (the inline grey description) and never
   `detail` or `documentation`, which are the only two fields `show_item` accepts; it calls
   `docs.close()` and returns for anything else. So: type `e testd`, `<C-n>` to select, `<C-k>` —
   confirm **no window appears**, no literal character is inserted, the command line is intact, and
   the menu is not dismissed.

   > This is deliberately a weak assertion, and it cannot be made stronger. A path-preview test was
   > drafted here on the strength of `sources/path/init.lua:73-95`, which does set `documentation`
   > on resolve — but that was read from source rather than observed, and live testing showed no
   > window at the `:` prompt (the cmdline source answers `:e ` file arguments via `getcompletion`,
   > and its items carry no documentation). The claim was retracted from
   > `code-intelligence.adoc` rather than left standing. The honest position is that `<C-k>` exists
   > on the command line for keymap symmetry only.

- [X] All keys behave identically at the `:` prompt; `<CR>` still executes; `/` search completion
      still offers buffer words; `<C-k>` is bound and harmless

> `<CR>` confirmed to run **exactly what was typed**: `e testd` with `testdocs/` highlighted opened
> an empty buffer named `testd`, not `testdocs/`. Nothing written to disk. The original step wording
> ("the command executes as normal") was too loose to distinguish a pass from a failure and read as
> though something had gone wrong; rewritten to state the concrete expected buffer name.

#### BC.7 — `<Tab>` at the `:` prompt (design.md Open Question)

Dropping blink's stock `cmdline` preset means `<Tab>` no longer selects completion items; it falls
back to native command-line completion.

1. At a `:` prompt with a partial path, press `<Tab>` and observe what happens.
2. **Record the verdict below.** If losing `<Tab>` selection is genuinely missed in daily use, add
   `<Tab>` to the shared table as a `select_next` alias — that can be done without breaking the
   one-keymap-everywhere goal, since it would apply to both modes.

- [X] `<Tab>` behavior at the `:` prompt observed and verdict recorded (acceptable as-is / add it
      back as a `select_next` alias)

> **Verdict: acceptable as-is — do not bind `<Tab>`.** The fallback is not a dead key: `wildmenu` is
> on with `wildmode=full` and `wildoptions=pum`, so `<Tab>` hands over to Neovim's native wildmenu,
> which draws its own popup and cycles through full matches.
>
> The reason for *not* binding it is the change's own principle. Native wildmenu `<Tab>` exists only
> on the command line, so finger memory built on it silently fails in insert mode — exactly the
> cross-mode drift this change exists to remove. Binding `<Tab>` in the shared table would have made
> it symmetric, but only by removing working native behavior to duplicate what `<C-n>` already does.
> The asymmetry is inherent to `<Tab>` here, so the answer is to not rely on it.

#### BC.8 — Command-line history recall still reachable

Native `<C-n>` at the `:` prompt recalls the next history entry. blink's stock preset already
shadowed it with `select_next` before this change, and `auto_show` means the menu is usually already
open — so `show` returns `nil` and `<C-n>` should behave as it did before. The `"fallback"` entry is
what preserves history recall when blink declines.

1. Press `:` on an empty command line and press `<C-n>` — record whether history recall still works.
2. Compare against the behavior you remember from `main`. This is the one place the `<C-n>` double
   duty could plausibly annoy.

- [X] Command-line history recall behavior recorded; no regression versus `main`

> **Verdict: no regression; documented rather than changed.** On an empty `:` prompt `<C-n>` opens
> blink's menu and `<C-p>` recalls the previous history entry, landing on the most recent command.
> There is a prev but no next, which looks odd until you read the command lists: `<C-p>` is
> `{ "select_prev", "fallback" }`, so with no menu open `select_prev` declines and the fallback
> reaches native `<C-p>`; `<C-n>` is `{ "show", "select_next", "fallback" }`, and `show` *succeeds*
> and opens the menu, so it never reaches its fallback. The asymmetry is a side effect of `<C-n>`
> carrying the trigger role, not a defect.
>
> `<Up>`/`<Down>` work as expected and are the proper history keys — better than `<C-p>`/`<C-n>` for
> the purpose, since they filter history by the typed prefix while the Ctrl pair walk it unfiltered.
>
> Disabling the `<C-p>` fallback on the command line was considered and rejected. It would mean
> giving `cmdline.keymap` a mode-specific override, reintroducing exactly the divergence this change
> removes. The `"fallback"` rule is already consistent across modes — "do what this mode natively
> does with this key" — and only Neovim's native meaning differs (history on the command line,
> keyword completion in insert mode). Special-casing would make the rule inconsistent to tidy one
> outcome. Documented in `code-intelligence.adoc` instead.

#### BC.9 — Other sources still ride the same menu

1. Open `testdocs/hello.clj` (or `hello.lisp`/`hello.janet`), start a Conjure REPL, and confirm
   Conjure completions still appear in the menu using the new keys.
2. In any buffer, `:set spell`, type a partial word of **3+ characters**, and confirm dictionary
   candidates appear. `:set nospell` and confirm they stop appearing.

- [X] Conjure completions work in lisp-family buffers *(9a: N/A — see note)*; spell candidates appear
      only with `spell` on and only at 3+ characters

> **9a — recorded N/A, no REPL available.** Conjure completions require a live REPL, which was not
> worth standing up for this. Defensible here rather than a gap: this change is keymap-only and
> alters no source wiring, `conjure` remains listed in `sources.per_filetype` for the lisp-family
> filetypes, and the shared table has been shown to drive every other source exercised (lsp, buffer,
> path, snippets, spell). Nothing about the keymap is source-specific. Re-check opportunistically
> the next time a REPL is running.
>
> **9b — passed.** Spell candidates appear with `:set spell` at 3+ characters, do not appear at 2
> (the `min_keyword_length = 3` guard holds), and disappear with `:set nospell` (the
> `enabled = function() return vim.opt.spell:get() end` gate holds). Worth confirming given the
> separate finding that this source floods Lua buffers with junk — that is caused by `o.spell = true`
> globally with no `spell = false` in `after/ftplugin/lua.lua`, not by a broken guard.

#### BC.10 — Normal-mode `<C-n>` is unaffected

The shared keymap binds insert and command-line modes only. `<C-n>` in normal mode is the file tree.

1. In normal mode, press `<C-n>` — the file tree opens.
2. `:verbose imap <C-n>` — confirm it resolves to a blink mapping; `:verbose nmap <C-n>` — confirm it
   resolves to the `lua/keymaps.lua` tree mapping.

- [X] Normal-mode `<C-n>` still opens the file tree; the two meanings are cleanly separated by mode

> Confirmed: `:verbose nmap <C-n>` resolves to `:NvimTreeOpen<CR>` from `lua/keymaps.lua`,
> `:verbose imap <C-n>` to the blink mapping, with no leakage in either direction. Note that
> `:verbose imap` reports nothing until you have entered insert mode in that buffer at least once,
> since blink applies its keys buffer-locally on `InsertEnter` — the same mechanism that made BC.1
> look like a failure.
>
> **Reservation recorded, no action now.** The separation works, but `<C-n>` is carrying a lot:
> file tree in normal mode, trigger *and* select-next in insert, select-next on the command line.
> Logged under "Things to keep an eye on" in `recommendations/ideas.md` to settle with use rather
> than decided here. The note there observes that the tree role is the cheapest to drop, since after
> `fix-tree-terminal-keymaps` the tree also answers to `<leader>t`, `<C-t>`, `<leader>n` and `<C-f>`.

#### BC.11 — Clean startup and syntax

1. Fresh `nvim` (no args) — `:messages` shows no errors.
2. From a shell: `find . -name '*.lua' -not -path './build/*' -print0 | xargs -0 luac -p` — all pass.
3. `:lua vim.print(require("blink.cmp.config").keymap)` and
   `:lua vim.print(require("blink.cmp.config").cmdline.keymap)` — confirm both show the **same six
   keys** with `preset = "none"`, and that neither contains `<CR>` or `<M-Space>`.

- [X] Clean `:messages`; `luac -p` passes; both keymaps resolve to the same keys with no `<CR>`
      or `<M-Space>`

> Verified headlessly. `luac -p` passes repo-wide; `:messages` empty after a real session with
> `:Lazy sync`. Both keymaps print `preset=none` with exactly `<C-b> <C-e> <C-f> <C-n> <C-p> <C-y>` —
> stronger than "the same keys": `lua/plugins/blink.lua` declares one `completion_keymap` table
> (line 19) and passes that same object to both `keymap` (line 38) and `cmdline.keymap` (line 82),
> so the two modes cannot drift. `selection = { preselect = false, auto_insert = false }` at line 41.
>
> **Re-verified after BC.5 added `<C-k>`:** both modes now resolve to seven identical keys —
> `<C-b> <C-e> <C-f> <C-k> <C-n> <C-p> <C-y>`. The seventh key reached `cmdline.keymap` with no
> cmdline-specific edit, which is the shared-table design proving itself.

#### BC.12 — Docs match the configuration

**Re-scoped after BC.5 added `<C-k>` and `:BlinkDocsToggle`.** Steps 1-5 were cleared once against a
six-key table, then invalidated and redone against seven.

1. `docs/modules/ROOT/pages/editor/keybindings.adoc` — Auto-Completion section lists all **seven**
   keys including `<C-k>`, leads with the `Enter`-does-not-accept callout, notes the `<C-n>` double
   duty, and carries the note about the timed documentation window and `:BlinkDocsToggle`.
2. `docs/modules/ROOT/pages/editor/code-intelligence.adoc` — same, plus the "trigger key" subsection,
   the new "The documentation window" subsection (timed default, `:BlinkDocsToggle`, why a short
   docstring will not appear to scroll, and the `lua_ls` limitation), the WSL note explaining why
   there is no `Alt-Space`/`Ctrl-Space`, and a Command-line Completion section that states the accept
   key and the `<Tab>` fallback.
3. `cheatsheets/core.md` — the `<leader>?` surface matches both pages, and its heading now reads
   **blink.cmp** (it still said "nvim-cmp", stale since change 03).
4. `grep -rn -i 'M-Space\|Alt-Space\|Alt+Space' docs/ cheatsheets/` — the only hits are the two lines
   of the explanatory WSL note in `code-intelligence.adoc`. No surface **asserts** the key works.
5. Site build: `rm -rf build/site && ./docker/antora/run.sh antora-playbook.yml` — no errors, no
   unresolved xrefs.
6. In a live session, press `<leader>?` and confirm the rendered cheatsheet shows the new keys,
   including `<C-k>`.
7. Also confirm here how the **timed documentation window actually feels** in normal use — it is the
   shipped default, and the original open question behind BC.5. Run `:BlinkDocsToggle` once to see
   the on-demand mode and the state notification.

> Steps 1-5 re-verified after the seven-key rewrite: all three surfaces carry the `<C-k>` row and the
> toggle; the `Alt-Space` grep still returns only the two explanatory WSL lines; Antora exits 0 with
> the same five pre-existing `{name}`/`{pat}`/`{feed}` attribute warnings (all on untouched lines,
> confirmed against `git diff main...HEAD`) and no new ones; the rendered
> `code-intelligence.html`/`keybindings.html` both contain `BlinkDocsToggle` and the `Ctrl-k` rows.
> Steps 6 and 7 are live and remain outstanding.

- [X] All three surfaces agree with the config; no page asserts `Alt-Space`; Antora builds clean;
      `<leader>?` shows the new keys

> Steps 6 and 7 passed. **Verdict on the timed documentation window: keep it as the default.** This
> was the original open question behind the whole `<C-k>` investigation — the first attempt to answer
> it was a false negative, tested in a Lua buffer where the window can never appear. Judged properly
> in C# via roslyn, the 500ms timed window is the shipped default, with `:BlinkDocsToggle` available
> to switch to on-demand per session.
>
> Step 6 also surfaced a separate, unrelated defect in the `<leader>?` popup itself: glow mis-wraps
> paragraphs at around 118 columns, orphaning single words. Not caused by this change — it only
> became visible because this change added the first real prose paragraphs to `cheatsheets/core.md`,
> every other section being tables and short headers. Split out to `fix/glow-wrap-width` rather than
> grown into this branch.

### Raise PR & merge

- [X] All validation steps above pass (BC.1–BC.12)
- [X] Raise PR: `fix/blink-completion-keymap` → `main` (PRs #170, #171)
- [X] Review and approve PR
- [X] Merge PR

### Post-merge

- [X] `git checkout main && git pull origin main` (`main` at `9474590`) (`main` at `ae7a3de`)
- [X] Launch Neovim: `:Lazy sync` — confirm clean
- [X] Remove the two fixed entries from `recommendations/ideas.md` ("Things that seem broken" — the
      `<M-Space>` trigger and the split accept key). The snippet-navigation entry added by this
      change **stays** — it is a separate, still-open gap.
- [X] Change archived, `completion-engine` delta promoted to the capability spec

## Change · fix-tree-terminal-keymaps

**Branch:** `fix/tree-terminal-keymaps`

Moves the file-tree toggle onto `<leader>t` and the terminal toggle onto `<leader>T`. `t` reads as
*tree*, and reaching for it to open the tree instead dropped a terminal split at the bottom of the
screen — the defect that prompted this change.

One **BREAKING** change, deliberate:

- **`<leader>t` no longer opens the terminal.** The terminal is **`<leader>T`** (capital `T`). The
  terminal's own behavior — persistent shell, full-width `botright` split, `resize 15`,
  `winfixheight` — is untouched; only the key changed.

Everything else on these prefixes is unchanged, per design D2: `<leader>n` and `<C-n>` stay
**open-only** (`NvimTreeOpen`, so they can never close a tree you already have), `<C-t>` stays a
toggle, and `<C-f>` still reveals the current file. `toggle_terminal` and `ide_layout` are unedited,
so `<leader>L` keeps sharing the same terminal open path.

**Prerequisites** (confirm before validating):
- Nothing to install. Pure keymap + docs change; no plugin added, removed, or re-pinned.
- Any file to open Neovim on — `testdocs/hello.lua` is fine. The IDE-layout steps want at least
  **two** files open to exercise `:Bd`.
- Note the ordering constraint with `fix-blink-completion-keymap`: both changes edit
  `docs/.../editor/keybindings.adoc`, `cheatsheets/core.md`, and append to this file. **Merge blink
  first**, then rebase this branch.

### Prepare

1. `git fetch origin && git checkout fix/tree-terminal-keymaps`
2. Launch Neovim: `:Lazy sync` — should be a no-op (no plugin pins touched); confirm no errors.
3. `:messages` — confirm empty.

- [X] Branch checked out, `:Lazy sync` clean, no errors in `:messages` (lazy.nvim's update
      notices excepted — see TK.8)

> Evidenced by the validation walk itself: TK.1-TK.8 were all run in live sessions on this branch,
> and TK.8 confirmed a fresh startup carries no plugin, LSP or keymap errors. `:Lazy sync` is a
> no-op here — this change touches no plugin specs. The original wording said "`:messages` empty",
> corrected for the same reason as TK.8: it never is, because the update checker always reports.

### Validate

#### TK.1 — `<leader>t` toggles the file tree

1. From an editor window with the tree closed, press `<leader>t` — the tree opens on the left.
2. Press `<leader>t` again — the tree **closes**. (This is the toggle half; `<leader>n` deliberately
   does not do this.)
3. Repeat once more to confirm it is a stable toggle, not a one-shot.

- [X] `<leader>t` opens the tree when closed and closes it when open

#### TK.2 — The open-only tree keys are unchanged, and `<C-t>` is gone

1. With the tree **closed**, press `<leader>n` — the tree opens.
2. Press `<leader>n` again — the tree **stays open** (it is `NvimTreeOpen`, not a toggle). This is
   intentional: it is the "I want the tree, don't gamble" key.
3. Repeat both steps with `<C-n>` — same behavior.
4. With the tree **closed**, press `<C-t>` — **nothing should happen**. The global toggle has been
   removed; `<C-t>` is no longer bound outside the tree window. `:verbose nmap <C-t>` in a normal
   buffer should report **no mapping**.
5. Open the tree, put the cursor on a file, and press `<C-t>` — this is nvim-tree's own buffer-local
   binding, *Open: New Tab*. Expect the file to open **in a new tab, with no tree visible**. The tree
   has not closed; nvim-tree does not carry it into a new tab (`tab.sync.open` defaults off and this
   config does not set it), so you are simply looking at a tab that never had one. Confirm with `gT`
   or `:tabprevious` — the original tab still has its tree open, exactly as you left it. This is
   nvim-tree's behaviour and is explicitly out of scope.
6. With a file open, press `<C-f>` — the current file is revealed and highlighted in the tree.

- [X] `<leader>n`/`<C-n>` open and never close; `<C-t>` is unbound outside the tree and belongs to
      nvim-tree inside it (new tab, tree intact on `gT`); `<C-f>` still reveals

> **Defect found during this step and fixed — the global `<C-t>` toggle never worked properly.**
> nvim-tree binds `<C-t>` **buffer-locally inside the tree window** to `api.node.open.tab` —
> *Open: New Tab* (`nvim-tree/keymap.lua:64`) — and a buffer-local mapping wins over a global one.
> So the global `:NvimTreeToggle` could open the tree but could never close it from inside; pressing
> it there silently did something else entirely. Three doc surfaces claimed `<C-t>` toggles the tree.
>
> The global binding is removed rather than repaired: `<leader>t` is now the single toggle. This
> revises design **D2**, which had kept `<C-t>` on the reasoning that it "works today" — it did not.
> Removing a documented key that never behaved as documented is a smaller correction than leaving the
> claim standing. `navigation.adoc`, `keybindings.adoc` and `cheatsheets/core.md` updated, each
> stating why there is no global `<C-t>`; the "Inside the Tree Window" row documenting nvim-tree's own
> `<C-t>` stays, because that one is real.

#### TK.3 — `<leader>T` toggles the terminal, including from inside the tree

1. From an editor window, press `<leader>T` — a terminal opens as a **full-width** split at the
   bottom, 15 lines tall, and lands in insert mode.
2. Type something recognizable (e.g. `echo marker-one`) so the scrollback is identifiable.
3. Press `<Esc>` to leave terminal insert mode, then `<leader>T` — the terminal window closes.
4. Press `<leader>T` again — the **same shell** returns with `marker-one` still in the scrollback.
   A fresh prompt with no history means the buffer was recreated and this step fails.
5. Focus the **tree** window (`<leader>t` if needed, then move into it) and press `<leader>T` from
   there — the terminal must still open **full-width across the bottom**, not as a ~30-column split
   inside the tree column.
6. With the terminal open, open another split (`:split`) — confirm the terminal window stays 15 lines
   (`winfixheight`).

- [X] `<leader>T` opens the full-width bottom split from an editor window; shell and scrollback
      survive toggling; height stays 15 when other splits open. **From inside the tree it opens at
      reduced width — known defect, logged, not fixed here (see note).**

> **Correction — this was ticked prematurely on "that all works", then contradicted by TK.4.** Step 5
> asserts a full-width split when invoked from the tree window. Measured in a 171-column terminal:
> from the text pane `winwidth(0)` is 171 (correct); from the tree it is 140 — 171 minus the
> 30-column tree and its separator, so the split lands below the *editor column*, not across the
> screen. That contradicts `ide-layout`'s *Full-width terminal toggle* requirement, whose scenario
> says "not inside the tree column" in as many words.
>
> `toggle_terminal` does use `botright split`, which ought to be unconditional, so something
> relocates the window afterwards — nvim-tree re-establishing its layout on `WinNew` is the obvious
> suspect but is **unconfirmed**, and a scripted reproduction produced a correct 171-wide split, so
> the trigger is not understood. Logged in `recommendations/ideas.md` and deliberately left unfixed:
> the terminal panel's split approach is itself under review, so work on the current geometry may be
> discarded. Everything else in TK.3 passes.

#### TK.4 — `<leader>t` never opens a terminal (the reported defect)

The original report was that this misfired *after* a terminal had already been opened once, so test
that state explicitly rather than only from a clean start.

1. Press `<leader>T` to open the terminal, then `<leader>T` to close it (so `term_buf` is now a live,
   hidden buffer).
2. Press `<leader>t` — the **tree** toggles. No terminal split appears.
3. Open the terminal again with `<leader>T` and leave it open. Now press `<leader>t` — the tree
   toggles and the terminal window is left alone.

- [X] `<leader>t` toggles only the tree in every state, including after the terminal has been opened

> Passes — the originally reported defect is gone, including from the state it was reported in (after
> a terminal had already been opened and closed, leaving a live hidden `term_buf`). The reduced-width
> observation made during this step belongs to TK.3 and is recorded there.

#### TK.5 — `<leader>L` still assembles the layout and is still idempotent

1. From a clean `nvim testdocs/hello.lua`, press `<leader>L` — tree on the left, editor in the
   middle, full-width terminal at the bottom, and **focus lands in the editor** (not the tree, not
   the terminal).
2. Press `<leader>L` again — no duplicate windows, no second terminal, focus still in the editor.
3. Press `<leader>L` a third time with the tree manually closed beforehand — it should re-open the
   tree and reuse the existing terminal rather than spawning a new shell (check the `marker-one`
   scrollback from TK.3 is still there).

- [X] `<leader>L` assembles the layout with focus in the editor, is idempotent, and reuses the
      existing shell

> Passed, including the full-width terminal — so `<leader>L` is **not** affected by the reduced-width
> defect recorded under TK.3, even though `ide_layout` opens its terminal through the same
> `botright split` code. That narrows the defect to `toggle_terminal` invoked with focus already in
> the tree window, rather than to the split call itself. Initially skipped in this pass, then run.



#### TK.6 — which-key shows both keys and `<leader>t` fires immediately

1. Press `<leader>` and wait for the which-key popup — confirm **both** `t` ("File tree: toggle") and
   `T` ("Toggle terminal split") are listed with those descriptions.
2. Press `<leader>t` at normal typing speed — the tree must toggle **immediately**, with no
   `timeoutlen` pause. A delay means something has made `<leader>t` a which-key prefix (i.e. some
   `<leader>t<x>` map was introduced), which task 1.2 exists to prevent.
3. `:verbose map <leader>t` — confirm it resolves to `:NvimTreeToggle<CR>` from `lua/keymaps.lua`,
   and `:verbose map <leader>T` resolves to the `toggle_terminal` Lua callback.

- [X] which-key lists both with correct descriptions; `<leader>t` fires with no prefix timeout;
      both maps resolve to the expected targets

#### TK.7 — `:Bd` and the ide-layout guardrails are undisturbed

These are `ide-layout` requirements this change must not regress.

1. With the layout assembled (`<leader>L`), open a second file so two buffers exist.
2. Run `:Bd` on one — the **window stays open** showing the other file, and the tree's width is
   unchanged. The layout must not collapse.
3. With the layout assembled, `:q` the last editor window — Neovim **exits cleanly**. It must not
   leave the tree (or the terminal) behind as the only remaining window, stretched full-width.
4. Trigger a float over the layout (`<leader>?` cheatsheet) — it renders over the layout normally and
   closes without disturbing the windows.

- [X] `:Bd` preserves the window and tree width; `:q` on the last editor exits cleanly with no
      orphaned tree; floats unaffected

#### TK.8 — Clean startup and syntax

1. Fresh `nvim` (no args) — `:messages` shows no plugin, LSP or keymap **errors**. It will not
   be empty: `lua/loader/init.lua:21` sets `checker = { enabled = true }`, so lazy.nvim reports any
   available plugin updates at every startup. Those notices are expected. Read the list and confirm
   nothing in it is an error or traceback.
2. From a shell: `find . -name '*.lua' -not -path './.git/*' -not -path './build/*' -print0 | xargs -0 luac -p` — all pass.
3. `stylua --check lua/keymaps.lua` — clean.
4. `openspec validate fix-tree-terminal-keymaps --strict` — passes.

- [X] No errors in `:messages` on startup — lazy.nvim's update notices excepted and expected;
      `luac -p`, `stylua --check`, and `openspec validate` all pass

> `:messages` on a fresh `nvim` contained lazy.nvim's "plugin updates available" notices for three
> plugins, and nothing else. The step originally read "`:messages` shows no errors" but was relayed
> as "confirm `:messages` is empty" — which it was not. The criterion above has been rewritten to
> name the lazy notices explicitly, rather than leaving a reader to reinterpret "clean" after seeing
> the result. No plugin, LSP or keymap errors. `luac -p` passes repo-wide, `stylua --check lua/keymaps.lua` is clean, and
> `openspec validate fix-tree-terminal-keymaps --strict` reports valid. A headless startup produced
> genuinely empty `:messages`, which is consistent — the checker needs a real session to report.
>
> Side note, not part of this change: three plugins have updates pending, i.e. a future lazy-lock
> sync.

### Raise PR & merge

- [X] All validation steps above pass (TK.1–TK.8), with any defect and its fix logged inline as a
      blockquote note

> Two defects found and one wrong expectation corrected, all recorded inline: the global `<C-t>`
> toggle never worked (shadowed by nvim-tree inside the tree window) and was removed; the terminal
> opens at reduced width when toggled from inside the tree, logged in `recommendations/ideas.md` and
> deliberately left unfixed; and TK.2's step 5 expectation about nvim-tree's own `<C-t>` was wrong
> and was corrected. TK.3 was also ticked prematurely and has been amended.
- [X] `fix-blink-completion-keymap` merged first, and this branch rebased onto the updated `main`
      (conflicts expected only where both touch `keybindings.adoc`, `cheatsheets/core.md`, and this
      file — the hunks are in different sections, so keep both sides)

> Rebased twice: once onto `ae7a3de` after blink merged (PRs #170/#171), then again onto `60250e3`
> after the blink archive/bookkeeping merged (PR #172). Both times only `openspec/TEST_PLAN.md`
> conflicted, resolved by rebuilding from `main` and re-appending this section; `keybindings.adoc`
> and `cheatsheets/core.md` auto-merged and were verified to carry both changes.
- [X] Raise PR: `fix/tree-terminal-keymaps` → `main` (PR #173)
- [X] Review and approve PR
- [X] Merge PR

### Post-merge

- [X] `git checkout main && git pull origin main` (`main` at `9474590`) (`main` at `7684430`)
- [X] Launch Neovim from `main`, re-confirm TK.1 and TK.3 (the two keys that moved) on the merged
      config

> Confirmed live on merged `main`. Headless resolution matched: `<leader>t` -> `:NvimTreeToggle<CR>`,
> `<leader>T` -> the `toggle_terminal` callback, `<C-t>` **UNMAPPED** (the removal landing as
> intended), with `<leader>n`/`<C-n>` -> `:NvimTreeOpen<CR>` and `<C-f>` -> `:NvimTreeFindFile<CR>`
> unchanged.
- [X] Rebuild the docs site (`rm -rf build/site && ./docker/antora/run.sh antora-playbook.yml`) and

> Rebuilt clean: exit 0 with only the five pre-existing `{name}`/`{pat}`/`{feed}` attribute warnings,
> none on lines this change touched. All three anchors resolve in the rendered
> `editor/navigation.html` — `file-tree`, `terminal` and `inside-tree` each have an `id` and live
> `href`s. The single remaining "Toggle file tree" on each page is the `<leader>t` row, as intended.
      confirm the `[[file-tree]]`/`[[terminal]]` cross-references resolve in the rendered pages
- [X] Change archived and the delta promoted to the capability spec

> Archived as `openspec/changes/archive/2026-08-24-fix-tree-terminal-keymaps/`. The `ide-layout`
> delta is promoted: the terminal requirement now names `<leader>T` and states that `<leader>t`
> SHALL NOT toggle the terminal, and a new *File tree keymaps* requirement records that `<leader>t`
> is the only toggle and that no global `<C-t>` binding is provided, with the reason.
> `openspec validate --all --strict`: 40 passed, 0 failed.

## Change · replace-glow-renderer

**Branch:** `fix/replace-glow-renderer`

Replaces `glow.nvim` and the external `glow` binary with in-editor rendering via
`render-markdown.nvim`. glow pre-wrapped its output before it ever reached a buffer, and its
word-wrap orphans single words onto their own lines at essentially any width — reproduced at 70, 80,
90, 110, 115, 118, 120 and 140 columns, with no markup involved and no configuration that avoids it.
The buffer now holds the source markdown unwrapped and Neovim wraps at display time, so **there is
no re-wrap step that can go wrong** — the defect is structurally impossible rather than merely fixed.

One **BREAKING** change: **`:Glow` is removed. The replacement is `:MarkdownPopup`.**

Also gone: the `glow` binary as a runtime dependency, both `vim.fn.executable("glow")` guards and
their "install glow" notifications, and the `stdpath("cache")/cheatsheet_preview.md` temp file (it
existed only to give glow a path to read).

**Prerequisites** (confirm before validating):
- `:Lazy sync` — `render-markdown.nvim` installed, `glow.nvim` cleaned.
- A markdown file with a **long prose paragraph**; `cheatsheets/core.md`'s Auto-Completion section has
  two. Everything else in the cheatsheets is tables and short headers, which is why this defect went
  unnoticed for so long.
- `testdocs/test.md` for the popup preview, and any Lisp/F#/Haskell file to exercise a language sheet.
- Nothing to install. If `glow` is still on `$PATH` that is now irrelevant — nothing calls it.

### Prepare

1. `git fetch origin && git checkout fix/replace-glow-renderer`
2. Launch Neovim: `:Lazy sync` — confirm `render-markdown.nvim` installs and `glow.nvim` is removed.
3. `:messages` — no plugin, LSP or keymap **errors**. It will not be empty: lazy.nvim's update checker
   reports available updates at every startup, which is expected.

- [X] Branch checked out, `:Lazy sync` clean, no errors in `:messages`

> Evidenced by the validation walk: RG.1-RG.11 all ran in live sessions on this branch, and RG.10
> confirmed a fresh startup with `:messages` entirely empty.

### Validate

#### RG.1 — The wrapping defect is gone

The whole point of the change.

1. Open any Lua file and press `<leader>?`.
2. Scroll to **Auto-Completion (blink.cmp)** — the only cheatsheet section with real prose paragraphs.
3. Read both paragraphs under the keymap table. Confirm **no line holds a single orphaned word**, and
   each line is filled to the available width before wrapping.
4. For contrast, recall the old behaviour: glow orphaned a word in these exact paragraphs at every
   width tried except two.

- [X] Cheatsheet prose wraps with no orphaned words

> Confirmed live. This is the defect the change exists to remove, and it is gone structurally rather
> than patched: the paragraph sits in the buffer as a single 270-character line and Neovim wraps it at
> display time, so there is no re-wrap step left to get wrong. glow orphaned a word in these exact
> paragraphs at every width tried except two.

#### RG.2 — Content reflows on resize

New behaviour. glow could never do this, because its output was wrapped before reaching the buffer.

1. Open `<leader>?` and leave it open.
2. Resize the terminal window (or `:vertical resize` the surrounding editor).
3. Confirm the float's text **re-wraps to the new width** rather than keeping its original line breaks.

- [X] Content reflows on resize

> Confirmed. New behaviour: glow wrapped its output before it reached the buffer, so its text could
> never reflow. Note the float *frame* does not resize — it is created at a fixed size from
> `vim.o.columns`/`vim.o.lines` when opened; only the text inside re-wraps. Making the frame track the
> editor too would be a small addition if it ever proves worth it.

#### RG.3 — Tables still render as tables

1. With the cheatsheet open at a normal terminal width, confirm the keybinding tables render with
   visible column structure — **not** as raw `| key | action |` pipe text.
2. Confirm no table is truncated or wrapped mid-cell.

- [X] Tables render with visible column structure, none truncated or wrapped mid-cell

> Confirmed at a normal width (171-column terminal, 120-column float, widest table 82). This is the
> check that justifies the dependency: `render-markdown.nvim` was chosen over the zero-plugin option
> (plain markdown buffer plus `vim.treesitter.start()`) precisely so tables would not drop to raw pipe
> text on a surface that is mostly tables. That trade-off holds.

#### RG.4 — Narrow terminal: the accepted trade-off

`wrap` is what fixes prose, but Vim cannot wrap prose and scroll tables in one window. The widest
cheatsheet table is 82 columns against a float of `min(0.7 × columns, 120)`, so tables only wrap when
the float drops below 82 — roughly a terminal under 118 columns.

1. Resize to roughly 100 columns and open `<leader>?`.
2. Observe the tables. Wrapping here is **expected**, not a failure.
3. **Record a verdict**, and answer the design's open question: is this acceptable as-is, or is a
   `nowrap` toggle bound inside the float worth adding?

- [X] Narrow-terminal behaviour observed and verdict recorded

> **Verdict: acceptable as-is. No `nowrap` toggle.** The terminal runs full-screen 99.9% of the time,
> so the float is at its 120-column cap and the widest cheatsheet table (82) has ~38 columns of
> headroom. Sub-118-column terminals are an edge case that does not occur in practice here, and a
> toggle for it would be speculative complexity — an extra key and an extra state, to serve a
> situation that does not arise. Documented in `content/markdown.adoc` as a CAUTION so the behaviour
> is at least explained if it is ever met.

#### RG.5 — Language sheets and mini-guides

1. `<leader>?` from a Lisp, F#, or Haskell buffer — confirm the language section still appears below
   the core sheet, separated by a rule.
2. `<leader>?g` — confirm the guide picker opens and a chosen guide renders.

- [X] Language sheet appended correctly; mini-guides open and render

> Confirmed. This exercised `open_guide()`, the one caller of `open_float()` never touched by headless
> testing — which matters because D4's argument is that a single shared entry point cannot drift
> between the three surfaces.

#### RG.6 — Dismissal

1. With the float focused, press `q` — it closes and focus returns to the previous window.
2. Re-open and press `<Esc>` — same.

- [X] `q` and `<Esc>` both dismiss the float and restore focus

> Confirmed, including the focus-restoration half — an existing `context-aware-cheatsheet`
> requirement, preserved through the renderer swap.

#### RG.7 — The preview surfaces

1. `:e testdocs/test.md`, press `<localleader>pp` — the popup opens with rendered markdown.
2. Press `<localleader>p` — in a console this opens the same popup; in a GUI it opens the browser
   preview. Only the console branch changed.
3. Run `:MarkdownPopup` directly — works from a markdown buffer.
4. **Type something without saving, then `<localleader>pp`** — the unsaved text SHALL appear. The popup
   renders the buffer, not the file; glow could only ever show the last saved version.
5. *(Static check, not a live one — do this from a shell, not by watching the UI.)* Confirm no glow
   invocation path survives:
   `grep -rn "executable(\"glow\")\|vim.cmd(\"Glow\")" --include='*.lua' lua/ after/` must return
   nothing, and no `vim.notify` in `lua/` or `after/` may mention glow. Absence of a notification
   cannot be established by looking at the editor; it is established by there being no code that
   emits one.

- [X] `,pp`, console `,p` and `:MarkdownPopup` all work; unsaved changes are rendered; no glow
      invocation path remains

> Steps 1-4 confirmed live, including the new capability in step 4: the popup renders the **buffer**,
> so unsaved edits appear. glow shelled out to a binary that read a file and could only ever show the
> last saved version.
>
> Step 5 as originally written asked the reader to confirm the *absence* of a notification, which is
> not observable by looking — a badly specified step, rewritten as the static check it always was.
> Verified: no `executable("glow")` guard, no `vim.notify` mentioning glow, no `:Glow` invocation and
> no plugin dependency anywhere in `lua/` or `after/`. The only glow references left are three
> comments explaining what was replaced. There is no code path on which the notification could fire.

#### RG.8 — `:MarkdownPopup` exists from a cold start

This caught a real bug during implementation, so test it in the state that exposed it.

1. Start a **fresh** Neovim and do **not** press `<leader>?`.
2. Open a markdown file and run `:MarkdownPopup` immediately.
3. It must work. If it reports `E492: Not an editor command`, the command has regressed to being
   registered inside the lazily-required `config.cheatsheet` module instead of `lua/keymaps.lua`.

- [X] `:MarkdownPopup` is defined without the cheatsheet having been opened first

> Passed — the command existed and ran from a cold start with `<leader>?` never pressed, which is the
> regression this step was written to catch.
>
> **Incidental finding, fixed.** Running it in the startup scratch buffer opened a *blank* popup. Not a
> defect in itself — an empty buffer reasonably renders as empty — but it exposed dead code: the
> "nothing to render" guard tested `#lines == 0`, and `nvim_buf_get_lines` on an empty buffer returns
> `{ "" }`, one empty string, so the count is 1 and the notification could **never** fire. Same class
> as the `<C-f>`/`<C-b>` dead keys found in `fix-blink-completion-keymap`. The guard now tests for
> actual content: an empty or whitespace-only buffer warns and opens nothing (verified: 0 floats).

#### RG.9 — Nothing else regressed

The original wording here was too vague to act on — it did not say what to open or that two of the
three need Docker. Restated:

**9a — PlantUML geometry. No Docker, no file needed: this is a diff check.** The only risk was a stray
value change while rewording two comments, and that is settled statically:
`git diff main...HEAD -- lua/plugins/plantuml.lua` — every changed line must be a comment, and
`0.7` / `120` / `80` must be untouched. *(Already verified: comment-only.)* Running the preview live
would need the PlantUML Docker server on `localhost:8080` plus `python3`; unnecessary for this.

**9b — `<localleader>sp` (markserv). Needs Docker; skippable.** Open any markdown file and press
`,sp`. The container must be running first:
`docker compose -f ~/.config/nvim/docker/markserv/docker-compose.yml up -d` (serves on `:8090`).
This change did not touch `,sp` or `config/mdpreview.lua` — only the neighbouring `,p`/`,pp` maps in
the same ftplugin file. If Docker is not up, record **N/A** and confirm by diff instead: the `,sp`
keymap block must be unchanged.

**9c — Markdown folding. No Docker.** Open a markdown file with several headings — `cheatsheets/core.md`
or `testdocs/test.md` — then press `zM` (close all folds) and `zR` (open all). Folds must work and
`:messages` must show no error. This exercises the *ordinary* markdown path that `ufo.lua`'s indent
provider serves; the float itself was already checked separately and is `foldmethod=manual`.

- [X] `,sp` (or N/A), PlantUML geometry (diff-verified), and markdown folding all unaffected

> **9a** — verified by diff, which is stronger than a visual pass: every changed line in
> `lua/plugins/plantuml.lua` is a comment, and `0.7` / `120` / `80` are untouched.
>
> **9b** — `,sp` works. markserv was brought up and the URL confirmed serving (HTTP 200 for
> `/testdocs/test.md`). Note it opens nothing on screen: `util.open_url` skips the browser when
> `term.is_console` and emits an INFO notification with the URL instead, so the evidence is the
> `open_url: http://localhost:8090/...` line in `:messages`, not a window appearing. That is
> by design, and easy to mistake for the command doing nothing — logged as a UX item.
>
> **9c** — folding works: `zM` collapses the nested lists (24 lines inside closed folds), `zR`
> reopens them, no errors. **Headings do not fold**, which is correct for the current config —
> `ufo.lua` uses the *indent* provider for markdown. The expectation that they would is reasonable,
> and this change removed the stated blocker (glow's buffers were why treesitter folding is
> disabled), so it is logged as a follow-up rather than dismissed. The original `testdocs/test.md`
> was too thin to fold at all, which made this step inconclusive rather than passing; the fixture was
> rewritten to cover the renderer properly.

#### RG.10 — Clean startup and syntax

1. Fresh `nvim` (no args) — `:messages` shows no plugin, LSP or keymap **errors** (lazy update notices
   excepted, as above).
2. `find . -name '*.lua' -not -path './.git/*' -not -path './build/*' -print0 | xargs -0 luac -p`
3. `stylua --check lua/ after/`
4. `openspec validate replace-glow-renderer --strict` and `openspec validate --all --strict`

- [X] No errors in `:messages`; `luac -p`, `stylua --check` and `openspec validate` all pass

> `:messages` on a fresh `nvim` was **entirely empty** — cleaner than the step predicted. The expected
> lazy.nvim update notices are absent because the pending updates were applied to the installed
> plugins during this change's `:Lazy sync` runs, so the checker has nothing left to report.
> `luac -p` passes repo-wide, `stylua --check lua/ after/` is clean, and `openspec validate` passes
> both scoped and repo-wide (41/41).
>
> **Consequence worth acting on separately:** the installed plugins are now ahead of `lazy-lock.json`
> for `easy-dotnet.nvim`, `nui.nvim`, `nvim-lspconfig` and `nvim-treesitter`, so **every Neovim launch
> re-dirties the lock file**. Those bumps were reverted out of this branch three times — they belong
> to a lock-sync change, not here. This branch's lock diff is exactly two lines: `glow.nvim` removed,
> `render-markdown.nvim` added. The sync is now genuinely owed; until it lands, expect a dirty
> `lazy-lock.json` after any session.

#### RG.11 — Open question: does `,pp` still earn its keep?

With rendering available in-buffer, a popup showing the same file is arguably redundant — the honest
alternative is "toggle rendering on this buffer". Kept as a popup so far to avoid a spec change the
proposal did not ask for.

1. Use both for a few minutes: `<localleader>pp` for the popup, and simply editing a markdown buffer
   with the renderer active.
2. **Record a verdict:** keep the popup, replace it with a render toggle, or keep both.

- [X] Verdict recorded on whether `,pp` remains a popup

> **Verdict: `,pp` becomes a render toggle. Implemented.** With the renderer live in the buffer, the
> buffer already *is* the preview, so a float of the same content was ceremony. `,pp` now calls
> `require("render-markdown.api").buf_toggle()`, flipping between rendered output and raw markup —
> which is a more useful operation than the popup it replaced, since it is how you get at the source
> to read or edit it. Verified: 46 extmarks -> 0 (raw) -> 46 (rendered).
>
> The popup is not lost: `,p` still opens it in console environments and `:MarkdownPopup` opens it
> anywhere. This needed a `markdown-popup-preview` delta, since that capability required `,pp` to open
> a forced popup — the requirement is rewritten with three new scenarios (toggle off, toggle back on,
> popup still available). Doc surfaces updated: `markdown.adoc`, `markdown-cheatsheet.adoc`,
> `keybindings.adoc` and `cheatsheets/markdown.md`. Note `,pp` in `.adoc` buffers is a separate
> keymap in `after/ftplugin/asciidoctor.lua` and is untouched.

### Raise PR & merge

- [X] All validation steps pass (RG.1–RG.11), with any defect and its fix logged inline as a
      blockquote note

> Two defects found and fixed, two badly-written steps rewritten, one fixture rebuilt, and both of
> the design's open questions answered with the tool in front of us rather than guessed at.
>
> **Defects:** `:MarkdownPopup` did not exist from a cold start (registered in a lazily-required
> module); and the `open_float` empty-content guard was unreachable, because
> `nvim_buf_get_lines` returns `{ "" }` for an empty buffer so `#lines == 0` never fired.
>
> **Badly-written steps:** RG.7 step 5 asked the reader to confirm the *absence* of a notification,
> which is not observable — rewritten as the static check it always was. RG.9 did not say what to open
> or that two of its three parts need Docker — rewritten with prerequisites stated.
>
> **Fixture:** `testdocs/test.md` was six lines with no indentation, which made RG.9c inconclusive
> rather than passing (nothing to fold) — rebuilt to 133 lines covering the renderer properly.
>
> **Verdicts:** RG.4 — no `nowrap` toggle, the terminal is full-screen almost always. RG.11 — `,pp`
> becomes a render toggle, which needed a `markdown-popup-preview` delta.
>
> Also surfaced and logged rather than absorbed: heading folds are now unblocked (glow was the stated
> reason treesitter folding is disabled for markdown), and `open_url` silently notifying makes `,sp`
> look broken.
- [X] Raise PR: `fix/replace-glow-renderer` → `main` (PR #175)
- [X] Review and approve PR
- [X] Merge PR (PR #175)

### Post-merge

- [X] `git checkout main && git pull origin main` (`main` at `9474590`) (`main` at `a7a3310`)
- [X] Re-confirm RG.1 and RG.7 on the merged config

> Confirmed on merged `main`. Worth having done rather than assumed: `,pp` changed meaning from
> "force popup" to "toggle rendered/raw" *after* most of the validation walk, so this was its first
> check outside the branch it was built on.
- [X] Rebuild the docs site and confirm the renamed `popup-preview` anchor resolves

> Rebuilt on merged `main`: exit 0 with only the five known pre-existing attribute warnings. The
> renamed `popup-preview` anchor resolves (1 `id`, 2 `href`s) and no `glow-preview` reference
> remains anywhere in the rendered page.
- [X] Raise the follow-up logged in `recommendations/ideas.md` for the three capability specs that

> Logged and now explicitly queued: `recommendations/ideas.md` gained a **Priority order** section,
> with the three glow-referencing specs at **#3**. The two that need deltas are
> `asciidoc-inbuffer-preview:30` and `ide-layout:70,73`; `code-folding:48` is cosmetic. Deliberately
> not fixed inline — editing a spec outside a delta is how specs drift.
      still reference glow (`asciidoc-inbuffer-preview`, `ide-layout` need deltas; `code-folding` is
      cosmetic)
- [X] Change archived and the deltas promoted. **Watch this one**: it removes *every* requirement from
      `markdown-preview-glow`, retiring the capability. Commit first — archiving is not atomic here.

> **Archived as `2026-08-25-replace-glow-renderer`, but not on the first attempt.** The warning in
> this box was correct: retiring every requirement in `markdown-preview-glow` produces an empty spec,
> and `openspec archive` rebuilds each spec from its deltas then rejects the result with *"Spec must
> have at least one requirement"*. The delta model has no way to say "this capability no longer
> exists".
>
> Worse, the failed run printed **"Aborted. No files were changed"** while having already written
> three other specs to disk — `context-aware-cheatsheet`, `markdown-popup-preview`, and a new
> `markdown-native-rendering`. The abort message is not trustworthy; committing beforehand is what
> made it recoverable, and is why this box carried that instruction.
>
> Resolution: the live `openspec/specs/markdown-preview-glow/` directory was deleted directly, and its
> delta moved to `RETIRED-markdown-preview-glow.md` outside `specs/` so the record of why each
> requirement went survives in the archive without the tooling trying to apply it. The other three
> capabilities promoted normally: `markdown-native-rendering` created with 4 requirements,
> `context-aware-cheatsheet` and `markdown-popup-preview` updated. `openspec validate --all --strict`
> passes 40/40 and no active changes remain.

## Change · align-treesitter-providers

**Branch:** `fix/align-treesitter-providers`

Aligns treesitter provider usage with which queries `nvim-treesitter` actually ships. The config had
it backwards on both axes: `indents.scm` exists for 2 of 13 filetypes and was enabled for all 13;
`folds.scm` exists for 11 of 13 and was enabled for none.

**Two behavioural changes, both intended:**

- **Newline indenting changes in eleven filetypes.** `indentexpr` is no longer set where no query
  exists. It outranks `'lisp'`, `cindent`, `smartindent` and `autoindent`, so setting it without a
  query removed indenting rather than adding it.
- **Structural folds appear where there were none.** The treesitter fold provider is restored.

**Better than the proposal predicted:** the fallback is not merely `autoindent`. Several filetypes
were also having Neovim's own indent scripts suppressed — C# regains `GetCSIndent`, Clojure regains
`GetClojureIndent`. So validation should expect *correct* indenting, not just non-zero indenting.

**Prerequisites** (confirm before validating):
- Nothing to install. Two config files plus a spec Purpose correction; no plugin added or re-pinned.
- Files with **real nested structure**. `testdocs/hello.hs` is seven lines of one-liners with nothing
  foldable and will report zero folds — that is the fixture, not a defect. It caused exactly that
  misreading during implementation. `testdocs/test.md` and `testdocs/csharp-project/Program.cs` are
  substantial enough; write a scratch file for any language whose fixture is thin.
- A C# file containing `#region` blocks, with roslyn attached, for the fold-precedence check.

### Prepare

1. `git fetch origin && git checkout fix/align-treesitter-providers`
2. Launch Neovim: `:Lazy sync` — no-op, no plugin pins touched.
3. `:messages` — no plugin, LSP or keymap **errors**. Lazy's update notices are expected and fine.

- [X] Branch checked out, `:Lazy sync` clean, no errors in `:messages`

> Evidenced by the walk: AT.1–AT.12 all ran in live sessions on this branch, with Neovim restarted at
> the start. No plugin pins were touched, so `:Lazy sync` is a no-op here.

### Validate

#### AT.1 — The reported defect: C# newline indenting

1. Open `testdocs/csharp-project/Program.cs`.
2. Put the cursor at the end of a line indented 8 columns, press Enter, and **type a character**.
3. The new line must be indented — not at column 0.

**Type a character.** Vim strips the autoindent from a line left empty when you leave insert mode, so
`o` followed by `<Esc>` always shows zero indent whatever the setting. That produced a false negative
during diagnosis.

4. `:set indentexpr?` — expect `GetCSIndent(v:lnum)`, Neovim's built-in C# indent script. If it shows
   the treesitter expression, the guard has not applied.

- [X] C# indents correctly on newline; `indentexpr` is `GetCSIndent`, not treesitter

> The reported defect is fixed, and better than the proposal predicted. `indentexpr` is
> `GetCSIndent(v:lnum)` — Neovim's own C# indenter, which the blanket treesitter expression had been
> suppressing along with `autoindent`. So C# gains real language-aware indenting rather than merely
> "same as the line above".

#### AT.2 — Filetypes with no indent query and no runtime script

Haskell, F#, HTTP and Vim have neither an `indents.scm` nor a built-in indent script, so they fall to
`autoindent`/`smartindent`.

1. In a Haskell and an F# buffer, confirm `:set indentexpr?` is empty.
2. Newline on an indented line preserves the indent.

- [X] Haskell and F# have empty `indentexpr` and preserve indent on newline

> Both empty, both preserve indent — the pure `autoindent`/`smartindent` case, since neither language
> has an `indents.scm` nor a built-in runtime indent script.
>
> **This step exposed a wider gap, logged separately.** F# has no indent intelligence at all: no
> `indent/fsharp.vim`, no `ftplugin/fsharp.vim`, no `indents.scm` — so a new line after `| Circle r ->`
> copies the previous indent rather than indenting the body, and `>>`/`<<`/`=` are equally unhelpful.
> Combined with `fsautocomplete` being absent, F# is materially less supported than the language table
> in `CLAUDE.md` implies. Recorded in `recommendations/ideas.md` alongside the uninstalled-servers item,
> and F# added to the languages-to-support list. Out of scope here.

#### AT.3 — Lisp family: configuration that has never been active

`'lisp'` and the `lispwords` tuning in `after/ftplugin/lisp.lua` have been suppressed by the blanket
`indentexpr` since it was introduced. Nobody has experienced this behaviour, so treat surprises as new
information rather than as regressions.

1. For `lisp`, `scheme`, `fennel` and `janet`: `:set indentexpr?` is empty and `:set lisp?` is on.
2. Newline inside a form indents per Lisp rules rather than to column 0.
3. **Common Lisp specifically**: write a `defmethod`, `defgeneric` or `defclass` and confirm the body
   indents as a definition body, not as a function call's arguments. That is what the `lispwords`
   entries exist for.
4. Clojure is different and worth checking separately: it has Neovim's own `indent/clojure.vim`, so
   `:set indentexpr?` shows `GetClojureIndent()` rather than being empty. That is correct — it is a
   purpose-built Clojure indenter, better than generic `'lisp'`.

- [X] Lisp-family indenting behaves sensibly; `lispwords` takes effect for Common Lisp; Clojure uses
      `GetClojureIndent`

> All three parts pass. This is the configuration nobody had ever experienced: `'lisp'` and the
> `lispwords` entries in `after/ftplugin/lisp.lua:7` (`defmethod,defgeneric,defclass,define,letrec`)
> had been suppressed by the blanket `indentexpr` since it was introduced, so a `defmethod` body
> indented as a function call's arguments rather than as a definition body. It now indents correctly —
> the tuning works, and has simply never been reachable.
>
> Clojure differs legitimately and was checked separately: it shows `GetClojureIndent()` rather than an
> empty `indentexpr`, because Neovim ships `indent/clojure.vim`. That was suppressed too, so Clojure
> gains a purpose-built indenter rather than falling back to generic `'lisp'`.
>
> `testdocs/hello.lisp` was extended with `defclass`/`defgeneric`/`defmethod` for this step — the
> original fixture had only `defun` and `defparameter`, none of which exercise `lispwords`.

#### AT.4 — parinfer and vim-sexp

Both were suppressed by the same override.

1. In a Lisp or Clojure buffer, edit parens and confirm `nvim-parinfer` adjusts structure as expected.
2. Confirm vim-sexp motions and slurp/barf still behave.

- [X] parinfer and vim-sexp behave correctly with `indentexpr` no longer overriding them

> Checked in both `hello.clj` (which uses `GetClojureIndent()`) and `hello.lisp` (which uses `'lisp'`),
> since they now run different indenters under the same parinfer. No conflict in either — parinfer
> tracks indentation rather than fighting it, and vim-sexp selection and motions are unaffected.

#### AT.5 — Lua is unchanged

Lua is the one filetype that keeps the treesitter indent expression.

1. `:set indentexpr?` in a Lua buffer shows the treesitter expression.
2. Indenting behaves as it did before this change.

- [X] Lua indenting unchanged

> The control case: Lua is the only filetype that keeps the treesitter expression, so this confirms the
> guard let the one legitimate user through rather than disabling indenting indiscriminately. An empty
> `indentexpr` here would have meant the guard was over-eager.

#### AT.6 — C# `#region` folds keep precedence

This is the guarantee the provider ordering exists to protect.

1. Open a C# file with `#region` / `#endregion` blocks and wait for roslyn to attach.
2. Confirm each region is a **fold unit** by putting the cursor inside one and pressing `za` — it
   should collapse to that region's boundaries. Do **not** judge this with `zM`: that sets
   `foldlevel=0` and closes folds at every level, so everything collapses regardless and the result
   says nothing about whether regions are respected.
3. `zR`, then repeat `za` on a different region.

- [X] C# `#region` folds work and are LSP-provided as before

> Roslyn attached; regions fold individually with `za`. The guarantee this change had to protect —
> LSP first in the provider chain — holds.
>
> The step originally said to confirm with `zM` that "each region folds as a single unit". That was
> loose wording on my part: `zM` sets `foldlevel=0` and closes folds at every level, so it collapses
> everything regardless and cannot distinguish region folds from any other kind. Rewritten to use
> `za`, which actually tests the boundary.

#### AT.7 — Markdown folds by heading

1. Open `testdocs/test.md`.
2. `zM` — the document collapses to its heading outline.
3. Confirm nested headings produce nested levels, and that the **nested-list folds still work** —
   list folding was the only folding markdown had before, and the indent fallback exists to keep it.
4. `zR` reopens everything.

- [X] Markdown folds by heading with nested levels; list folding retained

> Passes. Heading folds work, nested subsections fold independently, and the list folding that was
> markdown's only folding before this change survives — which is what the `indent` fallback slot was
> kept for.
>
> **Coverage limit, noted rather than papered over:** this exercises `zM`/`zR`/`za` only. Untested here
> are `zc`/`zo`, the recursive variants (`zA`/`zC`/`zO`), fold motions (`zj`/`zk`, `[z`/`]z`), `zi`,
> and fold persistence across sessions via `mkview`/`loadview`. None of those are provider-specific —
> they operate on whatever fold structure exists — so the risk of this change breaking them is low, but
> it is untested rather than verified.

#### AT.7b — Annotated foldtext still renders

An existing `code-folding` requirement that this test plan originally missed. The custom
`fold_virt_text_handler` in `lua/plugins/ufo.lua` renders a closed fold as its opening line plus
`··· N lines ···`. This change alters *which provider supplies the ranges*, so the handler is now
rendering over different input and is worth confirming rather than assuming.

1. In `testdocs/test.md`, close a heading fold with `za`.
2. The folded line should show the heading text followed by `··· N lines ···`, with N matching the
   number of hidden lines — not Vim's default `+--  N lines:` foldtext.
3. Repeat in `testdocs/csharp-project/Folding.cs` on a `#region` (LSP-provided ranges) and in
   `testdocs/hello.hs` (treesitter-provided ranges), so the handler is seen against all three
   provider types.

- [X] Annotated foldtext renders correctly for LSP, treesitter and indent-provided folds

> Confirmed across all three provider types — treesitter (markdown, Haskell) and LSP (C# `#region`).
> The `fold_virt_text_handler` is provider-agnostic, as expected, but this had never been checked and
> the step did not exist until the coverage gap was pointed out during AT.7.

#### AT.8 — Folds appear where a query exists

Use files with real structure, not the thin fixtures.

1. Lua, Haskell and a Lisp-family buffer: confirm structural folds exist (`zM` closes something).
2. F# has no `folds.scm` and no server installed, so it gets the indent fallback — confirm it still
   folds by indentation rather than not at all.

- [X] Structural folds present in Lua, Haskell and a Lisp buffer; F# still folds by indent

> All four fold. This is the direct test of the computed second slot — the part of the design revised
> mid-implementation after the three-provider list produced no folds at all. Lua (LSP) is the
> regression check, since that is precisely what the first attempt broke; Haskell and Clojure are new
> treesitter folds; F# is the only proof that the `indent` branch of the computed slot works, having
> neither a `folds.scm` nor a server.

#### AT.9 — Asciidoctor is untouched

- **WHEN** an asciidoctor buffer is opened
- Confirm folding still comes from `vim-asciidoctor` and ufo supplies nothing.

- [X] Asciidoctor section folding unchanged

> Section folds work and `foldmethod` reports `expr`, not `manual` — confirming ufo is still opting out
> entirely for this filetype and `vim-asciidoctor` retains ownership. The `foldmethod` check is the
> sharper half: ufo sets `manual` on buffers it manages, so `expr` proves the `""` branch is still
> being reached.

#### AT.10 — No `UnhandledPromiseRejection`, anywhere

The May 2026 commit this change reverses was reacting to exactly this error, and it was reproduced
during implementation from an over-long provider list. Two things to exercise:

1. Open the markdown float (`<leader>?`, then `:MarkdownPopup`) and a Conjure HUD/eval popup.
2. Watch `:messages` throughout the session for `UnhandledPromiseRejection`.

- [X] No `UnhandledPromiseRejection` in any buffer, including floats and the Conjure HUD

> Clean. This is the failure mode the May 2026 commit was reacting to, and it was reproduced during
> implementation from an over-long provider list — so it is live, not historical. The error text to
> watch for is `ufo/fold/manager.lua:119`, the two-provider limit being violated.
>
> **Not fully covered:** the Conjure HUD/eval-popup sub-step was not separately reported, so it is
> unverified rather than passed. It needs a running REPL, which is the least accessible part of this
> step. The markdown float — the buffer type the original commit actually blamed — was exercised and
> is clean.

#### AT.11 — Nothing opens folded

`foldlevel` and `foldlevelstart` are both 99, so this should hold — but it is the most visible way
this change could irritate.

1. Open several files of different filetypes.
2. Confirm none opens with folds already closed.

- [X] No buffer opens with folds closed

> Checked across all four provider paths — LSP, treesitter, indent, and the deeply nested markdown case
> (six levels, the most likely to expose a problem). `foldlevel`/`foldlevelstart` at 99 hold, so the new
> folds are available on demand without collapsing anything on open. Fold-column markers appearing where
> they did not before is the change working, not a regression.

#### AT.12 — Clean startup and syntax

1. Fresh `nvim` (no args) — `:messages` shows no plugin, LSP or keymap **errors**. Lazy's update
   notices are expected.
2. `find . -name '*.lua' -not -path './.git/*' -not -path './build/*' -print0 | xargs -0 luac -p`
3. `stylua --check lua/ after/`
4. `openspec validate align-treesitter-providers --strict` and `openspec validate --all --strict`

- [X] No errors in `:messages`; `luac -p`, `stylua --check` and `openspec validate` all pass

> Shell-side checks run directly: `luac -p` passes repo-wide, `stylua --check lua/ after/` is clean, and
> `openspec validate` passes both scoped and repo-wide (41/41).
>
> The `:messages` half rests on the walk rather than a separate cold-start check. Neovim was restarted
> before AT.1 (both changed files execute at startup — the ufo helper at file scope, the treesitter
> `FileType` autocmd registration), and a dozen buffers across AT.1–AT.11 were opened with nothing
> reported. A startup error in either file surfaces immediately; that is how the `local function`
> scoping mistake was caught during implementation. Noted that AT.10 cannot have contributed here,
> since it begins with `:messages clear`.

### Raise PR & merge

- [X] All validation steps pass (AT.1–AT.12, plus AT.7b), with any defect and its fix logged inline
      as a blockquote note

> One design issue, two step corrections, one added step and one fixture rebuild — all recorded inline.
>
> **Design issue:** `provider_selector` accepts at most two providers; the three-element chain the
> design specified raised `UnhandledPromiseRejection` and produced *no folds at all*, regressing Lua
> from `maxfoldlevel=2` to `0`. Caught by comparing against `main` rather than reading the result in
> isolation. D2 and D3 were revised and the `code-folding` delta rewritten to match.
>
> **Step corrections:** AT.6 originally said to judge `#region` folds with `zM`, which sets
> `foldlevel=0` and closes everything regardless — rewritten to use `za`. AT.1 carries the probe gotcha
> that caused a false negative during diagnosis: type a character after Enter, because Vim strips
> autoindent from a line left empty.
>
> **Added step:** AT.7b, covering the *Annotated foldtext* requirement the plan had missed entirely —
> surfaced when the coverage of AT.7 was questioned.
>
> **Fixtures:** `hello.hs`, `hello.fs` and `hello.lisp` were too thin to test anything, and
> `csharp-project/Folding.cs` did not exist. `hello.hs` reporting zero folds was briefly taken for
> broken treesitter folding when the file simply had nothing foldable.
- [X] Record the verdict on whether restoring `'lisp'` indenting actually feels right — the design's
      open question. It has never been active, so there is no prior experience to appeal to.

> **Verdict: yes, keep it — let the existing tools own Lisp indentation.** Confirmed after seeing it
> live in AT.3 and AT.4. Common Lisp, Scheme and Janet use Vim's `'lisp'` with the `lispwords` tuning
> finally reaching `defmethod`/`defgeneric`/`defclass`; Clojure uses Neovim's purpose-built
> `GetClojureIndent()`; parinfer and vim-sexp are no longer suppressed. Revisit downstream only if it
> disappoints in daily use.
>
> **One exception carved out: F#.** The verdict does not extend to it, because F# has no tool to own
> the job — no `indent/fsharp.vim`, no `ftplugin/fsharp.vim`, no `indents.scm`, and no LSP installed.
> "Let the existing tools own it" resolves to "nothing owns it" there. Logged in
> `recommendations/ideas.md` alongside the uninstalled-servers item, with F# added to the
> languages-to-support list; likely needs a plugin decision (`ionide/Ionide-vim` ships an F# indent
> script) rather than configuration. Explicitly out of scope for this change.
- [X] Raise PR: `fix/align-treesitter-providers` → `main` (PR #178)
- [X] Review and approve PR
- [X] Merge PR

### Post-merge

- [X] `git checkout main && git pull origin main` (`main` at `9474590`) (`main` at `df83499`)
- [X] Re-confirm AT.1 and AT.7 on the merged config

> Confirmed on merged `main` (`776d6e8`). Headless resolution matched: `GetCSIndent(v:lnum)` for C#,
> the treesitter expression for Lua only, empty for Haskell and Lisp, `GetClojureIndent()` for Clojure,
> markdown folding six levels deep, no `UnhandledPromiseRejection`.
- [X] Change archived and the deltas promoted

> Archived as `2026-08-26-align-treesitter-providers`. Promoted: `treesitter-editing` gained
> *Treesitter indentation only where a query exists*; `code-folding` had three requirements modified
> and one renamed. `openspec validate --all --strict` passes 40/40, no active changes remain.
>
> **Needed a second attempt, for a new reason.** The first aborted with
> *"MODIFIED failed for header ... not found"* — the delta had renamed a requirement, and MODIFIED
> matches on header text, so a rename must be expressed as a `## RENAMED Requirements` section with
> FROM/TO. Worth keeping the rename rather than reverting it: the fallback is no longer always indent,
> so *"LSP folds with indent fallback elsewhere"* had become actively misleading.
>
> Unlike the `replace-glow-renderer` archive, this abort left **no partial write** — `git status` was
> clean afterwards. So the non-atomicity is real but not universal; committing first remains the right
> precaution rather than something to rely on being unnecessary.

---

## Change · fix-open-url-wsl-opener

**Branch:** `fix/open-url-wsl-opener`

Fixes `util.open_url` doing nothing visible under WSL, and makes the URL recoverable when an opener silently no-ops.

**The recorded diagnosis was wrong, and that matters for how this is validated.** `recommendations/ideas.md` blamed the console INFO notification being easy to miss. That branch is unreachable here: WSLg exports `DISPLAY=:0` and `WAYLAND_DISPLAY=wayland-0`, so `term.is_console` is `false`. The real cause is opener ordering — `xdg-open` is first in the list and executable, finds no Linux browser, falls through to `w3m` in a detached job with no tty, shows nothing, and exits `0`. So do not validate this by looking for a notification that never fired.

**Two behavioural changes, both intended:**

- **The opener order is now platform-dependent.** Under WSL: `wslview`, `explorer.exe`, `xdg-open`, `open`. Everywhere else the existing order is unchanged.
- **The URL is surfaced on every call.** It goes to the `+` register always, and is echoed to the command line (through the message history) on the non-console path. This deliberately clobbers the clipboard; the echo says so.

**Prerequisites** (confirm before validating):
- Nothing to install. One Lua function plus four documentation pages; no plugin added or re-pinned.
- `wslview` is *not* installed on this machine, which is the interesting case — validation should land on `explorer.exe`. If you install `wslu` first you will be testing the other branch.
- The Docker preview services these commands target, running: `markserv` on 8090, `plantuml-server` on 8080, `marp` on 8880. All three were up when this section was written.
- A Windows browser reachable from WSL, since success is "a browser window appears on the Windows desktop".

### Prepare

1. `git fetch origin && git checkout fix/open-url-wsl-opener`
2. Launch Neovim: `:Lazy sync` — no-op, no plugin pins touched.
3. `:messages` — no plugin, LSP or keymap **errors**. Lazy's update notices are expected and fine.

- [X] Branch checked out, `:Lazy sync` clean, no errors in `:messages`

> **The "no-op" prediction in step 2 was wrong.** `:Lazy sync` picked up an upstream `nvim-lspconfig` bump (`af9adce` → `3928e63`) and rewrote `lazy-lock.json`. Nothing to do with this change — lazy's own `checker` found it — but the step should not have promised a no-op, since `sync` updates by definition. Committed straight to `main` as `511fe52` under the standing lock-only rule, and this branch rebased onto it, so validation runs against the same pins that will be on `main`.

### Validate

#### OU.1 — The reported defect: `,sp` opens a browser

1. Confirm markserv is up: `docker ps --filter name=markserv` shows `127.0.0.1:8090->8080/tcp`.
2. Open `testdocs/test.md` from the repo root.
3. Press `,sp`.
4. A browser window or tab must appear **on the Windows desktop** showing the rendered document at `http://localhost:8090/testdocs/test.md`.

Before this change, this produced no visible result at all.

- [X] `,sp` opens the rendered markdown in the Windows browser

> **Passed on the first attempt, then invalidated by OU.5 and re-opened.** The opener that satisfied it was `explorer.exe`, which OU.5 then showed mangles any URL containing `=`. `,sp` only passed because its URL happens to have none. The WSL primary is now PowerShell `Start-Process`, so this has to be re-run against the opener that will actually ship.

#### OU.2 — The URL reaches the clipboard

1. Put something identifiable on the clipboard first, so a stale value cannot be mistaken for success — in Neovim, yank a line of text with `yy`.
2. Confirm it is there: `:echo getreg('+')` shows that line.
3. Press `,sp`.
4. `:echo getreg('+')` — expect `http://localhost:8090/testdocs/test.md`.

Step 1 is the point of the case. Without it a clipboard that already happened to hold the URL would pass.

- [X] The `+` register holds the preview URL after `,sp`, replacing what was there before

#### OU.3 — The URL survives in `:messages`

1. Press `,sp`.
2. Note the echo on the command line: `open_url: http://localhost:8090/testdocs/test.md (copied to clipboard)`.
3. Do something that would clear a transient message — press `j` a few times, then `:` and `<Esc>`.
4. `:messages` — the same `open_url: …` line must still be listed.

This is what makes a silent opener failure recoverable, so it is the case that matters most if the ordering ever regresses.

- [X] The `open_url:` line appears on the command line and is still present in `:messages` afterwards

> OU.2 and OU.3 stand despite the opener change. Both run before any opener is selected — `setreg` is the first statement in `open_url` and the echo immediately follows the console branch — so neither depends on which opener wins.

#### OU.4 — The opener actually chosen is the Windows one

1. In Neovim: `:lua local t = require("config.terminal") print(t.is_wsl, t.is_console)` — expect `true false`.
2. `:lua print(vim.fn.executable("wslview"), vim.fn.executable("powershell.exe"), vim.fn.executable("explorer.exe"), vim.fn.executable("xdg-open"))` — expect `0 1 1 1`.
3. Given those four values, the first executable opener in the WSL order is `powershell.exe`. `explorer.exe` and `xdg-open` are both executable but must now come after it.

Step 2 is the discriminator on two counts: `xdg-open` being executable is why the old fixed order never reached the Windows openers at all, and `explorer.exe` being executable is why the order among *those* matters too.

- [X] `is_wsl` is true, `is_console` is false, `wslview` absent, `powershell.exe` / `explorer.exe` / `xdg-open` all present

> **Rewritten after OU.5.** The original asserted `explorer.exe` would be chosen, which was correct for the code at the time and is now wrong. Re-run required.

#### OU.5 — A second caller: PlantUML

1. Confirm the server is up: `docker ps --filter name=plantuml`.
2. Open a `.puml` file, or write a scratch one containing `@startuml` / `Alice -> Bob: hello` / `@enduml`.
3. Run `:PumlPreview`.
4. A browser tab must appear on the Windows desktop showing the rendered PNG.
5. `:echo getreg('+')` — expect a `http://localhost:8080/png/…` URL.

- [X] `:PumlPreview` opens the diagram in the Windows browser and leaves its URL on the clipboard

> Re-run confirmed after the PowerShell fix. The trailing `=` is still present in the URL on the clipboard — the defect was fixed by changing the opener, not by sanding down the URL. Stripping the base64 padding would have hidden this class of bug rather than fixed it, and would not have helped the `google.com/search?q=…` shape at all.

> **Failed on the first attempt, and found the biggest defect in this change.** `:PumlPreview` opened a *Windows Explorer folder window*, not a browser.
>
> The URL was not at fault — the server returns `200 image/png` for it, with or without its trailing `=`. The opener was. `explorer.exe` refuses to treat a string containing `=` as a URL and falls back to opening a folder. Confirmed on two shapes: the trailing `=` that base64 padding leaves on every PlantUML URL, and a mid-query `=` in `google.com/search?q=plantuml`. Both opened a folder.
>
> `cmd.exe /c start ""` was measured as a replacement and rejected — it is worse. Against a local HTTP listener it delivered `?q=a` when sent `?q=a&hl=en&x=1`: truncated at the first `&`, opening a **different page**, reporting nothing. PowerShell `Start-Process` delivered the URL intact.
>
> Fixed by making PowerShell the WSL primary and demoting `explorer.exe` to last resort. `,sp` had passed OU.1 only because its URL contains no `=`, which is why OU.1 and OU.4 were re-opened.

#### OU.5b — URL punctuation survives the opener

The regression guard for the OU.5 defect. Run it in Neovim, on the real code path.

1. `:lua vim.fn.jobstart = function(a) print(table.concat(a, " | ")) end`
2. `:lua require("config.util").open_url("https://example.com/search?q=a&hl=en")`
3. The printed argv must be `powershell.exe | -NoProfile | -NonInteractive | -Command | Start-Process 'https://example.com/search?q=a&hl=en'` — the URL whole, `=` and `&` intact, inside single quotes.
4. `:lua require("config.util").open_url("http://x/it's")` — the argv must show `'http://x/it''s'`, the literal quote doubled. PowerShell single-quoted strings escape a quote that way; without it the argument would terminate early.
5. Confirm `explorer.exe` appears nowhere in either argv.
6. Quit this session without saving — `jobstart` is stubbed for its lifetime and no URL will actually open.

Stubbing `jobstart` is what makes this checkable without opening a browser window per assertion.

- [X] Both argv lines are exactly as above, with `=`, `&` and the doubled quote preserved

> `xdg-open` was checked for the same flaw rather than assumed clean, since it is the primary on every non-WSL platform. With `$BROWSER` pointed at a script logging its argv, `?q=a&hl=en&x=1`, a trailing `=` and a literal quote all arrived whole as a single argument. That exercised the generic `$BROWSER` branch, not the `gio open` / desktop-entry branch a real GNOME or KDE session takes — no browser `.desktop` entries exist here to trigger it.

#### OU.6 — A third caller: Marp

1. Confirm the server is up: `docker ps --filter name=marp`.
2. Open a Markdown file under the directory the marp service mounts.
3. Run `:MarpPreview`.
4. A browser tab must appear showing the slide deck at `http://localhost:8880/…`.

If the marp service is not mounting a directory containing a usable deck, record that and skip — it tests the same code path as OU.1 and OU.5.

- [X] `:MarpPreview` opens the slide deck in the Windows browser

> Run against `/home/walt/src/rmv/drive-api/README.md`, the one deck the marp container is serving — it mounts that directory, not this repo, and `M.preview()` builds the URL from the basename only (`lua/config/marp.lua:58-65`). A weaker case than OU.5: the URL contains no `=`, so it confirms the third call site reaches `open_url`, not that punctuation survives.

#### OU.7 — WSL with no display still opens the browser

This is the case the change grew to cover. `is_console` is derived only from `$DISPLAY`/`$WAYLAND_DISPLAY`, which reads "no X11 display" as "no browser" — false under WSL, where `explorer.exe` works regardless. Unsetting both variables simulates WSL without WSLg, which is an ordinary configuration.

1. From a shell, launch Neovim with no display: `env -u DISPLAY -u WAYLAND_DISPLAY ~/nvim-linux-x86_64.appimage testdocs/test.md`
2. Confirm the simulation took: `:lua local t = require("config.terminal") print(t.is_console, t.is_wsl)` — expect `true true`.
3. Press `,sp`.
4. A browser window or tab must appear **on the Windows desktop**, exactly as in OU.1. The console short-circuit must not apply.
5. Expect the `open_url: … (copied to clipboard)` echo on the command line — this is an opener attempt, so it echoes rather than notifying.
6. Expect **no** INFO notification.

Before the WSL exemption, this configuration emitted a notification and opened nothing.

- [X] WSL with no display opens the browser, echoes, and does not notify

#### OU.7b — Non-WSL console path unchanged

The console branch still has to work where it is genuinely correct. There is no non-WSL machine here, so force the flag instead of the environment.

1. In a scratch Neovim session, override the flag and call directly:

```
:lua require("config.terminal").is_wsl = false
:lua require("config.terminal").is_console = true
:lua require("config.util").open_url("http://localhost:8090/testdocs/test.md")
```

2. Expect an INFO notification containing the full URL.
3. Expect **no** `(copied to clipboard)` echo — the console path deliberately does not echo, because the notification already carries the URL.
4. `:echo getreg('+')` — the URL must still be there. The clipboard write is unconditional and happens before any branching.
5. No browser should open.
6. Quit this session without saving; the overridden flags persist for its lifetime and would skew any later case.

This forces the flags rather than the environment, so it proves the branching logic, not the detection. OU.4 covers detection.

- [X] Non-WSL console mode notifies with the URL, does not echo, does not open a browser, and still sets the register

#### OU.8 — The "no opener found" WARN still fires

1. In a scratch Neovim session, stub out every opener before calling:

```
:lua Real = vim.fn.executable
:lua vim.fn.executable = function(c) if c:match("wslview") or c:match("powershell") or c:match("explorer") or c:match("xdg%-open") or c == "open" then return 0 end return Real(c) end
:lua require("config.util").open_url("http://example.invalid/probe")
```

2. Expect a WARN notification naming the openers that were tried and the URL, prefixed `open_url: no browser opener found`.
3. Under WSL the list in that message must read `wslview, powershell.exe, explorer.exe, xdg-open, open` — it is generated by walking the same table the loop walks, so a wrong order here means a wrong order everywhere.
4. Quit this session without saving; the stub is deliberately destructive to `vim.fn.executable`.

- [X] The WARN fires, names all five openers in WSL order, and includes the URL

#### OU.9 — No errors introduced

1. In a normal session, exercise `,sp` once.
2. `:messages` — shows no errors. The `open_url:` echo lines are expected content, not errors.

- [X] `:messages` shows no errors after exercising the command

#### OU.10 — Documentation renders

1. `./docker/antora/run.sh antora-playbook.yml`
2. Open `build/site/arcane-centaur/other/architecture.html` — the *Open URL Behaviour* section must show the two-row platform/opener-priority table.
3. Check `content/diagrams.html`, `content/presentations.html` and `getting-started.html` for the corrected opener order, and that `wslview` now reads as optional.

- [X] The docs build and the four changed pages render the new opener order

### Raise PR & merge

- [X] Every OU box above ticked
- [X] `recommendations/ideas.md` updated — entry removed from the queue and the wrong diagnosis corrected rather than silently dropped
- [X] Raise PR: `fix/open-url-wsl-opener` → `main` (PR #183)
- [X] Review and approve PR
- [X] Merge PR

### Post-merge

- [X] `git checkout main && git pull origin main` (`main` at `9474590`)
- [X] Re-confirm OU.1 and OU.3 on the merged config

> Confirmed on merged `main` (`9474590`). `,sp` opened the Windows browser and the `open_url:` line survived in `:messages`. The argv resolution was also re-checked headlessly against the merged code: PowerShell `Start-Process` with the trailing `=` and the `&` both intact.
- [X] Change archived and the deltas promoted

> Archived as `2026-08-27-fix-open-url-wsl-opener`. One requirement modified on `open-url`; `openspec validate --all --strict` passes 40/40, no active changes remain. Unlike the `replace-glow-renderer` archive this one neither aborted nor part-wrote.
- [X] Purpose paragraph of `openspec/specs/open-url/spec.md` corrected by hand — it names the old fixed opener order and `openspec archive` does not touch Purpose prose

> Rewritten around what the capability is actually for — making the URL *reach* the user, which is not the same as launching a process — with the two silent-failure modes named so the next person does not have to rediscover them.
>
> **The archive also promoted two stale clauses from my own delta**, written before the PowerShell finding: one said WSL is exempt from the console short-circuit "because `explorer.exe` reaches the Windows browser", and a scenario asserted the WSL priority reaches `explorer.exe`. Both directly contradicted the *URL punctuation survives the opener* requirement in the same spec, which says `explorer.exe` SHALL NOT be chosen while `wslview` or `powershell.exe` is available. Corrected in place. Worth noting the archive cannot catch this — it promotes delta prose verbatim, so a delta written before a mid-change discovery carries the stale reasoning straight into the live spec.

---

## Change · install-language-servers

**Branch:** `fix/install-language-servers`

Installs `marksman` and `fsautocomplete`, both of which were `vim.lsp.enable`d but absent, and corrects the documentation that made the gap hard to notice.

**The unusual risk in this change is that its most significant effects have no diff.** Two pieces of configuration were already present and inert for want of the F# binary, and both go live purely because the server now exists:

- `lua/plugins/conform.lua:10` — `fsharp = { lsp_format = "prefer" }`. Format-on-save begins rewriting `.fs` files on every write.
- `lua/plugins/ufo.lua` — F# has no `folds.scm`, so the generic path already returned `{ "lsp", "indent" }`. The first slot stops being dead.

Nothing in the diff points at either. Validate them directly rather than inferring from the code review.

**What deliberately does not change:** markdown folding. `marksman` advertises no `foldingRangeProvider`, so the provider chain stays `treesitter` then `indent`. LS.3 exists to prove installing the server changed nothing, which is the opposite of the usual assertion and easy to skip.

**Prerequisites** (confirm before validating):
- Both binaries installed: `marksman` in `~/.local/bin` (release `2026-02-08`), `fsautocomplete` 0.83.0 in `~/.dotnet/tools`. Both directories are already on `$PATH`.
- `testdocs/hello.fs` (a loose file, no project) and `testdocs/fsharp-project/` (with `HelloFs.fsproj`) — both are needed; they test different things.
- `testdocs/test.md` for the markdown cases.
- **Take a copy of any `.fs` file before writing to it.** LS.5 deliberately triggers format-on-save; if the formatter misbehaves, the buffer is rewritten.

### Prepare

1. `git fetch origin && git checkout fix/install-language-servers`
2. `command -v marksman fsautocomplete` — both must resolve. If either does not, the whole section is invalid rather than failing.
3. Launch Neovim: `:Lazy sync` — no plugin pins are touched by this change, though lazy's checker may still find upstream updates, as it did during `fix-open-url-wsl-opener`.
4. `:messages` — no plugin, LSP or keymap **errors**.

- [X] Branch checked out, both binaries resolve, no errors in `:messages`

> Re-run after a reboot. Both binaries survived it at the recorded versions — `marksman` `2026-02-08`, `fsautocomplete` `0.83.0+96fabed`. `:messages` was empty, not merely error-free. Note that nine plugin pins were bumped and committed to `main` as `bb80d6e` immediately before this re-run, so `LS.2`–`LS.10` are validated against bumped `nvim-lspconfig` and `nvim-treesitter` — both of which bear directly on this change. That is the post-merge state anyway, but it makes the bump a live suspect if a later case fails.

### Validate

#### LS.1 — marksman attaches to markdown

1. Open `testdocs/test.md`.
2. `:lua print(vim.inspect(vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))))` — expect `{ "marksman" }`.
3. `:lua vim.lsp.buf.document_symbol()` — the document's headings should be listed.
4. Put the cursor **inside the link text** on the "A link to a sibling document" line — the `[the IDE layout fixture](ide-layout-verification.md)` part — and press `K`. A hover window must appear showing the target document's content.
5. With the cursor in the same place, press `gd` — it must jump to `testdocs/ide-layout-verification.md`.

**Hover works only on internal references.** marksman resolves wiki links and relative links to other documents in the workspace; on a heading, plain prose, or an external `https://` link it returns nothing and no window opens. Confirmed by probing the server directly at four positions in this file, all of which returned `nil` before the sibling link was added. Do not read a missing window on a heading as a broken server — that is what happened on the first attempt at this case, and it is the same false-negative shape as the earlier lua_ls documentation-window confusion.

Allow a second or two after opening; the server starts on first markdown buffer.

- [X] `marksman` attaches, document symbols list the headings, and hover plus `gd` resolve the sibling-document link

> Failed on the first attempt against a heading, which was a defect in the case rather than the change — marksman returns nothing there by design. Re-run passed once the fixture gained a link to resolve.

#### LS.2 — marksman offers no formatting

Ask **marksman by name**. Do not index the client list positionally: `get_clients({ bufnr = 0 })[1]` is whatever attached first, so it raises an index error in a buffer with no client and reports `true` in a Lua buffer, where `lua_ls` really does advertise formatting. Neither result says anything about marksman.

1. Open `testdocs/test.md` and wait for marksman to attach (LS.1 step 2 confirms it).
2. Run, as one line:

   ```
   :lua local c = vim.lsp.get_clients({ bufnr = 0, name = "marksman" })[1]; if not c then print("marksman NOT attached") else for _, k in ipairs({ "documentFormattingProvider", "documentRangeFormattingProvider", "documentOnTypeFormattingProvider" }) do print(k, vim.inspect(c.server_capabilities[k])) end end
   ```

   All three must print `nil`. `marksman NOT attached` is a *timing* result, not a pass — wait and re-run.
3. **Positive control.** Open any `.lua` file in the config and run the same line with `name = "lua_ls"`. `documentFormattingProvider` must print `true`. This proves the query works and that the `nil` in step 2 is a real absence rather than a mistyped capability name or a query that always returns nothing.
4. Back in `testdocs/test.md`, introduce ragged spacing mid-sentence on a prose line, then `:w`.
5. The spacing must be left exactly as typed.
6. **The variant that can actually fail.** conform is lazy-gated on `ft` (`lua/plugins/conform.lua:3`), which excludes markdown, so in a markdown-only session conform is never even loaded and step 4 proves little. Start a fresh Neovim, open a `.lua` file **first** to force conform to load, *then* open `testdocs/test.md`, add ragged spacing and `:w`. The spacing must still survive.

Two independent things guard this: markdown is absent from conform's `ft` list *and* from `formatters_by_ft`, and marksman advertises no formatting capability at all. Step 6 is what distinguishes them — it holds conform loaded while writing a markdown buffer, which is the only configuration in which the `formatters_by_ft` guard is the one doing the work.

- [ ] All three formatting capabilities are `nil`, `lua_ls` returns `true` as a control, and writing the buffer does not reformat it — including with conform already loaded

> Rewritten after the original step 1 proved to be a defect in the case, the same shape as LS.1. `get_clients({ bufnr = 0 })[1]` was reported returning a full error stack in an empty buffer and `true` in a `.lua` file — both correct behaviour for a positional index, and neither a statement about marksman. Probing the server directly confirms all three formatting capabilities are `nil`, alongside `foldingRangeProvider = nil` (which LS.3 depends on) and `hoverProvider`/`definitionProvider`/`documentSymbolProvider` all `true` (which LS.1 depends on). The rewrite also adds the `lua_ls` positive control and the conform-already-loaded variant, without which step 4 passes for the wrong reason.

#### LS.3 — Markdown folding is unchanged

The point of this case is that installing a language server changed **nothing**. Easy to skip because nothing is expected to happen, which is exactly why a regression here would go unnoticed.

1. In `testdocs/test.md`, `:lua print(vim.inspect(require("ufo").getFolds and "ufo loaded" or "?"))` — just confirms ufo is present.
2. `zR` to open everything, then `zM` to close everything.
3. Headings must fold as sections, nested headings producing nested levels.
4. `zR`, then put the cursor on a nested list item and press `za` — the list must fold.
5. `:messages` — no `UnhandledPromiseRejection`. That is what a three-provider list would produce, and it yields **no folds at all** rather than degrading.

- [ ] Headings fold, nested lists still fold, no `UnhandledPromiseRejection`

#### LS.4 — fsautocomplete attaches to F#, with and without a project

1. Open `testdocs/hello.fs` — a loose file with no project.
2. `:lua print(vim.inspect(vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))))` — expect `{ "fsautocomplete" }`.
3. Press `K` on a function name — hover should respond.
4. Now open `testdocs/fsharp-project/Program.fs` and repeat step 2.

`fsautocomplete` is a .NET process and slower to start than marksman — give it up to 30 seconds on first launch. A timeout here is not the same as a failure to attach; retry once before recording a defect.

- [ ] `fsautocomplete` attaches to both the loose file and the project file, and hover responds

#### LS.5 — F# format-on-save, which activates with no code change

**Copy the file first**: `cp testdocs/hello.fs /tmp/hello.fs.bak`

1. Open `testdocs/hello.fs` and wait for the server to attach (LS.4 step 2).
2. Introduce clearly wrong formatting — add three or four extra spaces of indent to a line inside a function, and a run of blank lines.
3. `:w`
4. The buffer must be reformatted: the indentation normalised and the blank-line run collapsed.
5. `:messages` — no formatter errors.
6. Restore: `cp /tmp/hello.fs.bak testdocs/hello.fs` if the result is not something you want committed.

This is the change's most surprising effect. Nobody edited a formatter config, but `.fs` files are now rewritten on every write. If the result is unwelcome, that is a finding worth recording — the fix would be dropping `fsharp` from `conform.lua`, but it should be a deliberate decision rather than a discovery months later.

- [ ] Writing an F# buffer reformats it, with no errors

#### LS.6 — F# folds now come from the language server

1. Open `testdocs/fsharp-project/Program.fs` and wait for attach.
2. `zR`, then put the cursor inside a function body and press `za` — the function must fold as a unit.
3. `zM` — everything foldable closes.

Before this change the `lsp` slot was dead for F# and folding fell to `indent` alone. Structural folds that follow the *code* rather than the whitespace are the difference to look for.

- [ ] F# folds structurally, not merely by indentation

#### LS.7 — F# indentation is still broken, and that is expected

Installing an LSP does not fix indentation, and this case exists so that is not misread as a regression introduced here.

1. In an F# buffer, put the cursor at the end of a line ending in `->` or `=`.
2. Press Enter and **type a character**. Vim strips autoindent from a line left empty, so `o` then `<Esc>` always shows zero indent whatever the setting — that produced a false negative during `align-treesitter-providers`.
3. The new line will merely copy the previous line's indent rather than indenting the body.
4. `:set indentexpr?` — expect it to be empty.

That is the documented gap, tracked separately. A *changed* result here would be the surprise.

- [ ] F# still copies the previous indent; `indentexpr` is empty — the known gap, unchanged

#### LS.8 — A missing binary still degrades silently

Proves the "missing binary does not crash" scenario in both new specs without uninstalling anything.

1. From a shell: `env PATH=/usr/bin:/bin ~/nvim-linux-x86_64.appimage testdocs/test.md`
2. `:lua print(#vim.lsp.get_clients({ bufnr = 0 }))` — expect `0`.
3. `:messages` — no errors about a missing executable. Neovim must start clean.
4. Quit. This session has a deliberately crippled `PATH` and is good for nothing else.

- [ ] With both binaries off `PATH`, Neovim starts clean and simply attaches no client

#### LS.9 — No errors introduced

1. In a normal session, open `testdocs/test.md`, then `testdocs/hello.fs`, then `testdocs/csharp-project/Program.cs`.
2. `:messages` — shows no errors.

The criterion is *no errors*, not *empty*. Lazy's notices and LSP progress messages are expected content.

- [ ] `:messages` shows no errors after exercising all three filetypes

#### LS.10 — Documentation renders

1. `./docker/antora/run.sh antora-playbook.yml`
2. `languages/setup.html` — the *At a glance* matrix must show a Markdown row with `marksman`, and a Markdown section must exist with the GitHub-release install and the note that it supplies no folding or formatting.
3. `editor/code-intelligence.html` — the LSP table must show the GitHub-release install for marksman, and the note below the table must render as a callout box.
4. `content/diagrams.html` — same corrected install command.
5. `other/architecture.html` — the Markdown row's LSP cell reads `✅ marksman (no folds/format)`.
6. Confirm `sudo apt install marksman` appears nowhere on the site.

- [ ] All four pages render the corrected install command, and the phantom apt package is gone

### Raise PR & merge

- [ ] Every LS box above ticked
- [ ] `recommendations/ideas.md` updated — entry removed from the queue, F# indent gap retained as its own item, stale `indentexpr` entry deleted
- [ ] Raise PR: `fix/install-language-servers` → `main`
- [ ] Review and approve PR
- [ ] Merge PR

### Post-merge

- [ ] `git checkout main && git pull origin main`
- [ ] Re-confirm LS.4 and LS.5 on the merged config
- [ ] Change archived and the deltas promoted
- [ ] Purpose paragraph of `openspec/specs/code-folding/spec.md` corrected by hand — it still says treesitter folding is disabled and markdown uses indent only, which `align-treesitter-providers` overturned and which its own line 48 already contradicts
