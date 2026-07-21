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
- [X] Confirm the `dotnet` SDK is installed: `dotnet --version` (list all with `dotnet --list-sdks`). **The sample F#/C# projects target `net8.0`** — either install the `net8.0` runtime/SDK, or bump `<TargetFramework>` in `testdocs/fsharp-project`/`testdocs/csharp-project` to your installed version; a mismatch means the F#/C# LSP can't resolve the project (no completions).
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
- [ ] Install **ripgrep** (`rg`) — required by todo-comments.nvim's search commands for Change 06 §6.5 (`<leader>xt` / `<leader>xT`), and used by fzf-lua generally: `sudo apt install ripgrep` (Debian/Ubuntu; or `brew install ripgrep` / `sudo dnf install ripgrep`). Verify: `rg --version`
- [ ] Install the **`fzf`** binary — fzf-lua wraps the `fzf` fuzzy finder (no pure-Lua fallback); needed by `<leader>xT` (`:TodoFzfLua`) in Change 06 §6.5 and any fzf-lua picker: `sudo apt install fzf` (Debian/Ubuntu; or `brew install fzf` / `sudo dnf install fzf`). Verify: `fzf --version`
- [ ] Install **universal-ctags** (`ctags`) — a **soft/optional dependency** (documented in `getting-started.adoc` §System Dependencies): the config never invokes it, but it generates the `tags` file that tag navigation reads — needed here to exercise Change 06 §6.6 (`]t`/`[t`). `sudo apt install universal-ctags` (Debian/Ubuntu; or `brew install universal-ctags`). Verify: `ctags --version`
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

- [X] `git checkout main && git pull origin main`
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

- [X] `git checkout main && git pull origin main`
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

- [X] `git checkout main && git pull origin main`
- [X] Launch Neovim: `:Lazy sync` — confirm clean

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

- [ ] fzf-lua picker and Trouble panel both list todo comments

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
