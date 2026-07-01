## 1. Choose target release

- [x] 1.1 Identified v0.1.* as the stable series; prebuilt Linux x86_64 binaries ship from v0.0.29+; using `version = "v0.1.*"` for lazy.nvim version-pinning.
- [x] 1.2 Build step remains `make` for v0.1.x; `providers` opts schema unchanged from current config.

## 2. Upgrade avante and drop dressing

- [x] 2.1 Changed `version = "v0.0.27"` → `version = "v0.1.*"`.
- [x] 2.2 `build = "make"` unchanged (documented for this series).
- [x] 2.3 Removed `"stevearc/dressing.nvim"` from `dependencies`; kept plenary, nui, web-devicons.
- [x] 2.4 Rewrote stale header comment (dropped "do not update" warning; noted v0.1.*, dressing removal).
- [x] 2.5 `providers` opts (ollama llama3.2:3b @ 127.0.0.1:11434, claude haiku via ANTHROPIC_API_KEY) and keymaps unchanged.

## 3. Build and clean

- [ ] 3.1 Run `:Lazy update` for avante.nvim, then run `make` (or `:AvanteBuild`).
- [ ] 3.2 Run `:Lazy clean` and confirm `dressing.nvim` is removed.

## 4. Validation

- [ ] 4.1 Confirm avante loads at new version with no errors.
- [ ] 4.2 `<leader>aa` opens avante with current provider.
- [ ] 4.3 `<leader>ao` switches to ollama and opens (clean error if service offline).
- [ ] 4.4 `<leader>ac` switches to Claude API and opens.
- [ ] 4.5 `:DiffviewOpen` still works (plenary intact).
- [ ] 4.6 `vim.ui.select` / `vim.ui.input` still function via native fallback.
- [x] 4.7 Lua syntax check passes.

## 5. Documentation

- [x] 5.1 `docs/modules/ROOT/pages/other/architecture.adoc` updated (v0.1.*, dressing removed, plenary note).
- [x] 5.2 `CLAUDE.md` avante description has no version pin or dressing reference — no change needed.
