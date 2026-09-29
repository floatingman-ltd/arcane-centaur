# Tried and backed out

Things this configuration adopted, or set out to adopt, and then removed, replaced or disabled because they did not work for our usage. The point is to stop the same idea being tried again without knowing how it went last time.

Each entry says what was tried, when, why it came out, what replaced it, and what would have to change before it is worth another look. Commit hashes are the evidence; where a commit records no reason, the entry says so rather than supplying one.

Not in scope:

- **Declined decisions** — things considered and never done. Those are in `ideas.md` under *Declined*.
- **Routine upgrades** where nothing failed. Those are covered briefly at the end, under *Replaced by choice*, only so the history is in one place.

## Failed in use

### rest.nvim — HTTP client

- **Tried:** 2026-03-25, `rest-nvim/rest.nvim` v3 (`41ed231`).
- **Why it came out:** it would not install. v3 pulls `nvim-nio`, `mimetypes` and `xml2lua` from LuaRocks through its rockspec, and the build of its `tree-sitter-http` rock failed. Three fixes were tried the same afternoon: `73cc013` excluded that rock and added `nvim-nio`/`fidget.nvim` as lazy dependencies, `5cd9989` moved to rockspec-based dependencies for v3, and `1d4c8d2` gave up.
- **Replaced by:** `mistweaverco/kulala.nvim`, which had no LuaRocks dependencies and installed as a plain git plugin.
- **Revisit if:** kulala has to be replaced (its upstream repository is gone as of 2026-09-29; see `ideas.md`, *Things to keep an eye on*). rest.nvim is still the closest drop-in for `.http` files, but retrying it means first proving its LuaRocks build works under Neovim 0.12, since that is exactly the part that failed.

### glow.nvim — Markdown preview

- **Tried:** in use until 2026-08-25, including as the renderer for the cheatsheet float (`4309af0`).
- **Why it came out:** glow orphans single words when wrapping prose — on overflow it emits the word alone, then re-wraps the rest as though it were not there. Reproduced at widths 70, 80, 90, 110, 115, 118, 120 and 140, independent of markup. A 120→115 width workaround was built, validated live, failed, and was dropped. `glow -w 0` disables wrapping, but glow.nvim hardcodes `-w` and renders through `nvim_open_term`, whose grid would then hard-wrap mid-word instead (`597183c`).
- **Replaced by:** `render-markdown.nvim`, which renders in a normal buffer so Neovim owns the wrapping, and draws tables as boxes (`replace-glow-renderer`, archived 2026-08-25; spec references retired by `retire-glow-spec-references`).
- **Revisit if:** glow.nvim stops hardcoding `-w`, or glow fixes its wrapping. Neither was checked after the replacement.

### nvim-treesitter-textobjects on the `master` branch

- **Tried:** added with `01-add-treesitter-textobjects`.
- **Why it came out:** removed 2026-07-07 (`5a98831`). On Neovim 0.12 the `master` query path reaches `nvim-treesitter/tsrange.lua`, which calls `:start()` on a removed API, so `vaf`/`vif`/`daf`/`]f`/`[f` silently did nothing. Migrating to `main` was judged disproportionate at the time.
- **Replaced by:** the same plugin on `main`. `migrate-treesitter-main` (`bf40acd`, 2026-07-24) moved nvim-treesitter and textobjects to `main` together and restored the text objects.
- **Lesson:** a plugin that crashes on 0.12 is usually fixed on its `main`/`master` ahead of any tagged release, so pinning to a release can be what keeps it broken. This is now a standing note in `CLAUDE.md`.

### Treesitter highlighting for Markdown on `master`

- **Tried:** default treesitter highlighting for `markdown`/`markdown_inline`.
- **Why it came out:** disabled 2026-07-03 (`6347340`). The compiled parsers were ABI-mismatched with `master` nvim-treesitter and crashed with a `nil range` error in `languagetree.lua`. Neovim fell back to regex highlighting.
- **Restored:** the disable list is gone as of the `main` migration (`bf40acd`, 2026-07-24).

### nvim-ufo with an unconditional treesitter fold provider

- **Tried:** treesitter as a ufo fold provider from `add-code-folding` (`21ea7c5`, 2026-05-21).
- **Why it came out:** removed 2026-05-27 (`1912875`). It threw `UnhandledPromiseRejection` on special and temporary buffers, including the glow preview window. `fc9ae1f` had already caught `UfoFallbackException` for Markdown buffers the day after folding was added.
- **Replaced by:** LSP with an indent fallback, and indent-only for Markdown. Since `align-treesitter-providers` (`df83499`, 2026-08-26) treesitter is back, but only for languages that ship a `folds.scm`, computed at runtime.
- **Constraint found on the way:** `provider_selector` accepts at most two providers. A third throws and ufo then produces no folds at all rather than degrading (comment at the top of `lua/plugins/ufo.lua`).

### markview.nvim for AsciiDoc

- **Tried:** 2026-07-01, alongside `vim-asciidoctor` (`248240d`).
- **Why it came out:** deferred the same day (`de7d638`). AsciiDoc rendering needs `cathaysia/tree-sitter-asciidoc`, which nvim-treesitter does not carry.
- **Replaced by:** nothing. `vim-asciidoctor` provides syntax and folding; there is no in-buffer render and no `<localleader>mv`.
- **Revisit if:** that grammar becomes available through nvim-treesitter. The `asciidoc-inbuffer-preview` spec still describes the capability as intent (see `ideas.md`, *Things that seem broken*).

### cl_lsp — Common Lisp language server

- **Tried:** registered in `lua/config/lsp.lua` from the early configuration.
- **Why it came out:** dropped 2026-05-07 in the move from `require('lspconfig')` to `vim.lsp.config`/`vim.lsp.enable` (`05a1851`), because `cl_lsp` is not in lspconfig's server list. Stale doc references were cleared the same day (`01c3eea`).
- **Replaced by:** nothing. Common Lisp runs through Conjure + Swank with no LSP.

### Anthropic provider in avante.nvim

- **Tried:** avante's Claude provider with the `<leader>ac` map.
- **Why it came out:** disabled 2026-07-10 (`d8e4a05`). It authenticated with subscription OAuth, which carries a terms-of-service risk.
- **Replaced by:** avante is Ollama-only. Claude is reached through the `claude` CLI (`lua/config/claude_cli.lua`) and `claudecode.nvim`, both on Claude Code's own auth.
- **Revisit if:** an API key is wanted; `ai/ai-tools.adoc` describes the re-enable.

### Native Ollama as a fallback for a broken Docker

- **Tried:** documented as a way round a Docker defect during avante validation.
- **Why it came out:** dropped 2026-07-10 (`5a624b9`). Services stay in containers; a broken Docker is fixed, not bypassed. The defect was traced to the containerd overlayfs snapshotter (`12f58e1`).
- **Now:** the containers-first rule in `CLAUDE.md`.

### Renamed mount in the containerised `terraform` wrapper

- **Tried:** mounting the working directory at `/work` (`-w /work`) inside the `hashicorp/terraform` container.
- **Why it came out:** measured failing on 2026-09-11. A native process calling the containerised CLI passes absolute host paths, which do not exist under a renamed mount. Without `--user`, files written by the container are root-owned on the host.
- **Replaced by:** `-v "$PWD:$PWD" -w "$PWD"` plus `--user`, recorded in `CLAUDE.md`. Work is on the `add-terraform-support` branch.

### Python Confluence publisher

- **Tried:** a Python script located through `CONFLUENCE_PUBLISH_SCRIPT` and `find_publish_script()`.
- **Why it came out:** replaced 2026-03-26 (`dac69ae`) so that publishing needs no Python. The commit records the goal, not a specific failure.
- **Replaced by:** `lua/config/confluence.lua` in pure Lua, driving pandoc and `curl` through `vim.system()`.

### Upstream dependencies that went away

- **dressing.nvim:** dropped 2026-07-01 as avante's dependency because upstream archived it (`add671a`). `vim.ui.select`/`vim.ui.input` fall back to Neovim's native versions, which are fine on 0.12.
- **avante.nvim pinned to v0.0.27:** held there because releases after it had no Linux binaries; lifted to `v0.1.*` on 2026-07-01 once binaries were published again (`add671a`).
- **kulala.nvim:** upstream repository returns 404 as of 2026-09-29. Still in use, from a local copy at `~/.local/share/nvim/vendor/kulala.nvim` (`f0ca665`). Replacement options are in `ideas.md`.

## Proposed and abandoned

- **`add-jira-workflow` and `document-confluence-workflow`:** archived unimplemented on 2026-05-22 (`1a213bb`) as "non-starters with no implementation progress". The commit gives no further reason. `lua/config/jira.lua` predates the archive (`69dc783`, 2026-04-15), so the Jira capability exists outside the OpenSpec change that was abandoned.
- **Learning series in this repository:** the Lisp, Janet and Ollama learning pages were extracted to the `errant-familiar` repository on 2026-06-22 (`37574c4`). Their specs were dropped and every remaining pointer removed rather than repointed on 2026-07-27 (`1a54884`, `13b76a4`, `b4f2690`).

## Replaced by choice

Early swaps where no commit records a failure. Listed so the history is in one place; do not read a reason into them.

| Was | Now | When | Commit | Recorded reason |
|---|---|---|---|---|
| NERDTree (`preservim/nerdtree`, `nerdtree-git-plugin`) | nvim-tree | 2026-03-10 | `0aa7a2f` | "nerdtree is superceded by NVIM-tree" — nothing further |
| telescope.nvim | fzf-lua | 2025-09-02 moved aside; deleted 2026-03-10 | `45e1a45`, `0659125` | none |
| leaf.nvim (light), then Solarized light | TokyoNight | 2026-03-05 | `2c621b2`, `77588f5` | none; Solarized lasted the day |
| kitty and WezTerm recommendations | GNOME Terminal default, TTY console secondary | 2026-03-05 | `8e38af0`, `b7b877b` | none |
| `j`/`k` for completion navigation | `<C-n>`/`<C-p>` | 2026-03-12 | `9290671` | none |
| `<C-/>` comment maps | `gc`/`gcc` only | 2026-05-14 | `644da34` | use the defaults only |
| GitHub Copilot, OpenCode | Claude (CLI, claudecode.nvim, skills) | 2026-06-03 | `95acd42` | consolidate on Claude |
| nvim-cmp and five sources | blink.cmp v1 | 2026-07-01 | `341a80a` | modernisation (`03-migrate-completion-blink`) |
| vim-airline, vim-surround, vim-commentary, vim-sensible | lualine, nvim-surround, native `gc`, nothing | 2026-07-01 | `ce92c8b` | modernisation (`04-modernize-editing-plugins`) |
