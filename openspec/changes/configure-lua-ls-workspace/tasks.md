## 1. Server configuration

- [x] 1.1 Add a `settings` table to the `lua_ls` registration in `lua/config/lsp.lua`, with `runtime.version = "LuaJIT"`, `diagnostics.globals = { "vim", "pandoc" }`, `workspace.library = { vim.env.VIMRUNTIME }`, `workspace.checkThirdParty = false`, and `telemetry.enable = false`
- [x] 1.2 Comment why `pandoc` is in the globals list — Pandoc filters under `docker/md2pdf/` and `scripts/` are a different host program, not Neovim Lua
- [x] 1.3 Comment why the library is `$VIMRUNTIME` rather than `nvim_get_runtime_file("", true)`, so the narrower choice is not silently "corrected" later
- [x] 1.4 Syntax-check: `find . -name '*.lua' -print0 | xargs -0 luac -p`

## 2. Verify the diagnostics actually cleared

- [x] 2.1 Confirm `lua_ls` still attaches to a `.lua` buffer and the shared keymaps work
- [x] 2.2 Scan every tracked Lua file and record the total diagnostic count — expect **8**, against a baseline of 661, and expect every one of the eight to be a real finding rather than a suppressed category
- [x] 2.3 Confirm zero `Undefined global \`vim\`` across the tree
- [x] 2.4 Confirm zero `Undefined global \`pandoc\`` across the three filter files
- [x] 2.5 Confirm hover on a `vim.*` call returns a signature from `$VIMRUNTIME`, which is the evidence the library is loaded rather than the global merely silenced
- [x] 2.6 Measure `lua_ls` time-to-first-diagnostic and compare against the baseline, so the library's cost is a number rather than an assumption
  > Measured 2026-09-11. Attach ~80 ms either way. First diagnostic ~3.4 s with the library against ~0.9 s without. One-off per session: second and third files in the same session returned diagnostics in 101 ms each, against 3546 ms for the first.

## 3. Record what this surfaced

- [x] 3.1 Add the six findings to `recommendations/ideas.md` under *Things that seem broken*: four missing nil checks in `lua/config/http_preview.lua`, a parameter type mismatch in `lua/config/claude_cli.lua`, and a `uv_tcp_t`/`uv_stream_t` optional-type assignment
- [x] 3.2 Record the two that predate this change and are unaffected by it: the undefined type alias in `lua/plugins/fzf-lua.lua` and the unused local in `testdocs/hello.lua`
- [x] 3.3 State in that entry that the findings were invisible before this change, so nobody reads them as a regression it introduced

## 4. Validation

- [x] 4.1 Add a `## Change · configure-lua-ls-workspace` section to `openspec/TEST_PLAN.md` with branch name, prerequisites, and numbered `Prepare` / `Validate` / `Raise PR & merge` / `Post-merge` subsections
- [x] 4.2 Walk every step in a live Neovim session — the headless scan proves the counts but says nothing about how the list reads in a real buffer
- [x] 4.3 Confirm in a live session that the diagnostics list is now usable: open `lua/config/http_preview.lua` and check the four nil-check findings are visible without scrolling past noise
- [x] 4.4 Tick each `- [ ]` in the TEST_PLAN section only once genuinely confirmed, logging any defect and its fix inline as a blockquote note

## 5. Close out

- [ ] 5.1 Raise the PR once every validation step is ticked
- [ ] 5.2 Remove the `lua_ls` noise entry from `recommendations/ideas.md`, per that file's rule that shipped work is deleted rather than archived — but keep the six surfaced findings, which are not shipped
- [ ] 5.3 Archive the change (`openspec archive`); `lua-lsp` already has a real Purpose, so no placeholder needs writing this time
