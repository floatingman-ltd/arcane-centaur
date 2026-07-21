## 1. Choose target release

- [x] 1.1 Identified v0.1.* as the stable series; prebuilt Linux x86_64 binaries ship from v0.0.29+; using `version = "v0.1.*"` for lazy.nvim version-pinning.
- [x] 1.2 Build step remains `make` for v0.1.x; `providers` opts schema unchanged from current config.

## 2. Upgrade avante and drop dressing

- [x] 2.1 Changed `version = "v0.0.27"` → `version = "v0.1.*"`.
- [x] 2.2 `build = "make"` unchanged (documented for this series).
- [x] 2.3 Removed `"stevearc/dressing.nvim"` from `dependencies`; kept plenary, nui, web-devicons.
- [x] 2.4 Rewrote header comment (dropped "do not update" warning; noted v0.1.*, dressing removal, Ollama-only + how to re-enable claude via API key).
- [x] 2.5 Set the ollama provider model to `qwen2.5:0.5b` (small, limited-RAM) @ 127.0.0.1:11434.
- [x] 2.6 Removed the `claude` provider block and `<leader>ac` keymap — avante is Ollama-only (Anthropic subscription-OAuth ToS; avoid API-key dependency). Kept `<leader>aa`/`<leader>ao`. (CLI claude features `<leader>gcs`/`<leader>gce` and `<leader>?l`/`<leader>?a` are untouched — separate `claude-cli-integration`.)

## 3. Build and clean

- [x] 3.1 Run `:Lazy update` for avante.nvim, then run `make` (or `:AvanteBuild`).
- [x] 3.2 Run `:Lazy clean` and confirm `dressing.nvim` is removed.

## 4. Validation

- [x] 4.1 Confirm avante loads at new version with no errors.
- [x] 4.2 `<leader>aa` opens avante with current provider.
- [x] 4.3 `<leader>ao` switches to ollama and opens (clean error if service offline).
- [x] 4.4 `<leader>ac` is unmapped (claude provider removed) — only `<leader>aa`/`<leader>ao` exist; no API key needed. (TEST_PLAN §5.4)
- [x] 4.5 `:DiffviewOpen` still works (plenary intact).
- [x] 4.6 `vim.ui.select` / `vim.ui.input` still function via native fallback.
- [x] 4.7 Lua syntax check passes.

## 5. Documentation

- [x] 5.1 `architecture.adoc` updated (v0.1.*, dressing removed, Ollama-only backend).
- [x] 5.2 `CLAUDE.md` avante line updated to Ollama-only + small model + claude-disabled note.
- [x] 5.3 `ai-tools.adoc` (+cheatsheet) and `getting-started.adoc` updated: Ollama-only, `qwen2.5:0.5b` pull via HTTP API, disabled-claude section + API-key re-enable.
